# frozen_string_literal: true

require_relative 'user'

module Twitch
  module Chat
    ## Data class for a single message in a chat
    class Message
      attr_reader(
        :type, :params, :command, :id, :sent_at, :channel, :text, :user,
        :bits, :error, :raw
      )

      def initialize(msg)
        @raw = msg

        raw_additional_info, @prefix, @command, raw_params = msg.match(
          /^(?:@(\S+) )?(?::(\S+) )?(\S+)(.*)/
        ).captures
        @additional_info = parse_additional_info raw_additional_info
        @id = parse_id
        @sent_at = parse_sent_at
        @bits = parse_bits
        @params = parse_params raw_params
        @user = parse_user
        @channel = parse_channel
        @error = parse_error
        @text = parse_text
        @type = parse_type
      end

      def error?
        !@error.nil?
      end

      private

      def parse_additional_info(raw_additional_info)
        return unless raw_additional_info

        raw_additional_info
          .split(';')
          .map { |key_value| key_value.split('=', 2) }
          .to_h
      end

      %w[id bits].each do |field|
        define_method "parse_#{field}" do
          @additional_info[field] if @additional_info
        end
      end

      def parse_sent_at
        if @additional_info && (sent_at = @additional_info['tmi-sent-ts'])
          Time.at Integer(sent_at) / 1000
        else
          Time.now
        end
      end

      def parse_params(raw_params)
        raw_params = raw_params.strip

        params = []
        if (match = raw_params.match(/(?:^:| :)(.*)$/))
          params = match.pre_match.split
          params << match[1]
        else
          params = raw_params.split
        end

        params
      end

      def parse_user
        return unless @prefix

        name = @prefix[/^(\S+)!/, 1]

        return unless name

        User.new name, @additional_info
      end

      def parse_channel
        @params.find { |param| param.start_with?('#') }&.delete('#')
      end

      def parse_error
        @command.to_i if numeric_reply? && @command[/[45]\d\d/]
      end

      def parse_text
        if error?
          @error.to_s
        elsif regular_command?
          @params.last
        end
      end

      def numeric_reply?
        !@command.match(/^\d{3}$/).nil?
      end

      def regular_command?
        !numeric_reply?
      end

      TYPES = Hash.new(:not_supported).merge!(
        'PRIVMSG' => -> { parse_message_type },
        'MODE' => :mode,
        'PING' => :ping,
        'ROOMSTATE' => -> { parse_roomstate_type },
        'NOTICE' => -> { parse_notice_type },
        # You are in a maze
        '372' => :authenticated,
        # 'End of /NAMES list'
        '366' => :join,
        # https://dev.twitch.tv/docs/irc/commands#reconnect-twitch-commands
        'RECONNECT' => :reconnect
      ).freeze

      private_constant :TYPES

      def parse_type
        result = TYPES[@command]

        return result unless result.is_a? Proc

        instance_exec(&result)
      end

      def parse_message_type
        if user.name == 'twitchnotify'
          case text
          when /just subscribed!/ then :subscribe
          else :not_supported
          end
        elsif bits
          :bits
        else
          :message
        end
      end

      def parse_roomstate_type
        parse_roomstate_integer_type('slow', :slow_mode, off_value: '0') ||
          parse_roomstate_integer_type(
            'followers-only', :followers_mode, off_value: '-1'
          ) ||
          parse_roomstate_boolean_type('subs-only', :subscribers_mode) ||
          parse_roomstate_boolean_type('r9k', :r9k_mode) ||
          :not_supported
      end

      def parse_roomstate_boolean_type(key, name)
        value = @additional_info[key]
        return unless value

        case value
        when '1' then name
        when '0' then :"#{name}_off"
        else raise "Unsupported value of `#{key}`"
        end
      end

      def parse_roomstate_integer_type(key, name, off_value:)
        value = @additional_info[key]
        return unless value

        value == off_value ? :"#{name}_off" : name
      end

      def parse_notice_type
        case @params.last
        when /Login authentication failed/ then :login_failed
        else :not_supported
        end
      end
    end
  end
end

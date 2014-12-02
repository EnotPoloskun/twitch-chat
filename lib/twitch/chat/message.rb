module Twitch
  module Chat
    class Message
      attr_reader :type, :message, :user, :params, :command, :raw, :prefix, :error, :channel, :target

      def initialize(msg)
        @raw = msg

        @prefix, @command, raw_params = msg.match(/(^:(\S+) )?(\S+)(.*)/).captures.last(3)
        @params = parse_params(raw_params)
        @user = parse_user
        @channel = parse_channel
        @target  = @channel || @user
        @error = parse_error
        @message = parse_message
        @type = parse_type
      end

      def error?
        !@error.nil?
      end

      def numeric_reply?
        !!@command.match(/^\d{3}$/)
      end

    private

      def parse_params(raw_params)
        raw_params = raw_params.strip

        params     = []
        if match = raw_params.match(/(?:^:| :)(.*)$/)
          params = match.pre_match.split(" ")
          params << match[1]
        else
          params = raw_params.split(" ")
        end

        params
      end

      def parse_user
        return unless @prefix
        nick = @prefix[/^(\S+)!/, 1]

        return nil if nick.nil?
        nick
      end

      def parse_channel
        if @params.first.to_s.start_with?('#')
          @params.first.gsub('#', '')
        end
      end

      def parse_error
        @command.to_i if numeric_reply? && @command[/[45]\d\d/]
      end

      def parse_message
        if error?
          @error.to_s
        elsif regular_command?
          @params.last
        end
      end

      def numeric_reply?
        !!@command.match(/^\d{3}$/)
      end

      def regular_command?
        !numeric_reply?
      end

      def parse_type
        case @command
          when 'PRIVMSG' then :message
          when 'MODE' then :mode
          when 'PING' then :ping
          when 'JOIN' then :join
          when 'PART' then :part
          else :not_supported
        end
      end
    end
  end
end

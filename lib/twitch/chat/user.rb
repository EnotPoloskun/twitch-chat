# frozen_string_literal: true

module Twitch
  module Chat
    # Class for user as chat message author
    class User
      attr_reader :id, :name, :display_name, :badges

      def initialize(name, additional_info)
        @name = name
        @additional_info = additional_info

        return unless @additional_info

        @id = @additional_info['user-id']

        @display_name = @additional_info['display-name']

        @badges = parse_badges

        @is_broadcaster = badges['broadcaster'] == '1'

        @is_moderator = @additional_info['mod'] == '1'

        @is_subscriber = @additional_info['subscriber'] == '1'
      end

      %w[broadcaster moderator subscriber].each do |role|
        define_method "#{role}?" do
          instance_variable_get "@is_#{role}"
        end
      end

      private

      def parse_badges
        @additional_info['badges']
          .split(',')
          .map { |key_value| key_value.split('/') }
          .to_h
      end
    end
  end
end

# frozen_string_literal: true

module Twitch
  module Chat
    ## Data class for a chat channel
    class Channel
      attr_reader :name, :moderators

      def initialize(name)
        @name = name.downcase
        @moderators = []
      end

      def add_moderator(moderator)
        @moderators << moderator
      end

      def remove_moderator(moderator)
        @moderators.delete moderator
      end
    end
  end
end

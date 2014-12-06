module Twitch
  module Chat
    class Channel
      attr_reader :name, :moderators

      def initialize(name)
        @name = name
        @moderators = []
      end

      def add_moderator(moderator)
        @moderators << moderator
      end

      def remove_moderator(moderator)
        @moderators.delete(moderator)
      end
    end
  end
end

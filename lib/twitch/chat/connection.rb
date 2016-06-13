module Twitch
  module Chat
    class Connection < EventMachine::Connection
      extend ::Forwardable

      def_delegators :@client, :receive_data, :unbind

      def initialize(client)
        raise ArgumentError.new("client argument is required TC::Connection") unless client

        @client = client
      end

      def post_init
        @client.connection = self
      end

      def connection_completed
        @client.ready
      end
    end
  end
end

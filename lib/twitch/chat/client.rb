module Twitch
  module Chat
    class Client
      attr_accessor :host, :port, :nickname, :password, :connection
      attr_reader :channel

      def initialize(options = {}, &blk)
        options.symbolize_keys!
        options = {
          :host =>     'irc.twitch.tv',
          :port =>     '6667',
        }.merge!(options)

        @host = options[:host]
        @port = options[:port]
        @nickname = options[:nickname]
        @password = options[:password]
        @channel = options[:channel]

        @connected = false
        @callbacks = {}

        check_attributes!

        if block_given?
          if blk.arity == 1
            yield self
          else
            instance_eval(&blk)
          end
        end
      end

      def connect
        @connection ||= EventMachine::connect(@host, @port, Connection, self)
      end

      def connected?
        @connected
      end

      def on(callback, &blk)
        (@callbacks[callback.to_sym] ||= []) << blk
      end

      def trigger(event_name, *args)
        (@callbacks[event_name.to_sym] || []).each { |blk| blk.call(*args) }
      end

      def run!
        EM.epoll
        EventMachine.run do
          trap("TERM") { EM::stop }
          trap("INT")  { EM::stop }
          connect
        end
      end

      def join(channel)
        @channel = channel
        send_data "JOIN ##{channel}"
      end

      def ready
        @connected = true
        authenticate
        join(channel) if @channel

        trigger(:connected)
      end

    private

      def unbind(arg = nil)
        puts 'UNBIND'
      end

      def receive_data(data)
        puts data
      end

      def send_data(message)
        return false unless connected?

        message = message + "\n"
        connection.send_data(message)
      end

      def check_attributes!
        [:host, :port, :nickname, :password].each do |attribute|
          raise ArgumentError.new("#{attribute.capitalize} is not defined") if send(attribute).nil?
        end

        nil
      end

      def authenticate
        send_data "PASS #{password}"
        send_data "NICK #{nickname}"
      end
    end
  end
end

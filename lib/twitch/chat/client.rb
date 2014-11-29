module Twitch
  module Chat
    class Client
      attr_accessor :host, :port, :nickname, :password, :channel

      def initialize(options = {}, &blk)
        options.symbolize_keys!
        options = {
          :host =>     'irc.twitch.tv',
          :port =>     '6667',
        }.merge!(options)

        @host = options[:host]
        @port = options[:port]
        @nickname = option[:nickname]
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
        self.connection ||= EventMachine::connect(@host, @port, Connection, self)
      end

      def ready
        @connected = true
      end

      def on(callback, &blk)
        (@callbacks[callback.to_sym] ||= []) << &blk
      end

    private

      def check_attributes!
        [:host, :port, :nickname, :password, :channel] do |attribute|
          raise ArgumentError.new("#{attribute.capitalize} is not defined") if send(attribute).blank?
        end

        nil
      end
    end
  end
end

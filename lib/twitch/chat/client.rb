module Twitch
  module Chat
    class Client
      attr_accessor :host, :port, :nickname, :password, :connection
      attr_reader :channel

      def initialize(options = {}, &blk)
        options.symbolize_keys!
        options = {
          host: 'irc.twitch.tv',
          port: '6667',
        }.merge!(options)

        @host = options[:host]
        @port = options[:port]
        @nickname = options[:nickname]
        @password = options[:password]
        @channel = Channel.new(options[:channel]) if options[:channel]

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

        self.on(:mode) do |command, user|
          if command = '+o'
            @channel.add_moderator(user)
          else
            @channel.remove_moderator(user)
          end
        end

        self.on(:ping) do
          send_data("PONG :tmi.twitch.tv")
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
        @channel = Channel.new(channel)
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
        trigger(:disconnect)
      end

      def receive_data(data)
        data.split(/\r?\n/).each do |message|
          puts message.colorize(:yellow)

          Message.new(message).tap do |message|
            trigger(:raw, message)

            case message.type
              when :ping
                trigger(:ping)
              when :message
                trigger(:message, message.user, message.message) if message.target == @channel.name
              when :mode
                trigger(:mode, *message.params.last(2))
              when :slow_mode, :r9k_mode, :subscribers_mode
                trigger(message.type)
              when :subscribe
                trigger(:subscribe, message.params.last.split(' ').first)
              when :not_supported
                trigger(:not_supported, *message.params)
            end
          end
        end
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
        send_data "TWITCHCLIENT 3"
      end
    end
  end
end

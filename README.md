# Twitch::Chat

twitch-chat library is a Twitch chat client which uses Twitch IRC. EventMachine is used to handle connection to server. With the help of this library you can connect to any Twitch's channel and handle various chat events. Can be used as twitch chat bot engine.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'twitch-chat'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install twitch-chat

## Usage

```ruby
require 'twitch-chat'

client = Twitch::Chat::Client.new(channel: 'channel', nickname: 'nickname', password: 'twitch_oath_token') do
  on(:connect) do
    send_message 'Hi guys!'
  end

  on(:subscribe) do |user|
    client.send_message "Hi #{user}, thank you for subscription"
  end

  on(:slow_mode) do
    send_message "Slow down guys"
  end

  on(:subscribers_mode_off) do
    send_message "FREEEEEDOOOOOM"
  end

  on(:message) do |user, message|
    send_message "Current time: #{Time.now.utc}" if message == '!time'
  end

  on(:message) do |user, message|
    send_mesage "Hi #{user}!" if message.include?("Hi #{nickname}")
  end

  on(:message) do |user, message|
    send_message channel.moderators.join(', ') if message == '!moderators'
  end

  on(:new_moderator) do |user|
    send_message "#{user} is our new moderator"
  end

  on(:remove_moderator) do |user|
    send_message "#{user} is no longer moderator"
  end

  on(:disconnect) do
    send_message 'Bye guys!'
  end
end

client.run!
```

List of events: ``:message, :slow_mode, :r9k_mode, :subscribers_mode, :slow_mode_off, :r9k_off, :subscribers_mode_off, :subscribe, :connect, :disconnect, not_supported, raw``.

``raw`` event is triggered for every twitch irc message. ``not_supported`` event is triggered for not supported twitch irc messages.

if local variable access is needed, the first block variable is the client:

```ruby

Twitch::Chat::Client.new(channel: 'channel', nickname: 'nickname', password: 'twitch_oath_token') do |client|
  # client is the client instance
end
```

By default, logging is done to the ``STDOUT``, but you can change it by passing log file path as ``:output`` parameter in initializer

```ruby
Twitch::Chat::Client.new(channel: 'channel', nickname: 'nickname', password: 'twitch_oath_token', output: 'file.log')
```
## Contributing

1. Fork it ( https://github.com/enotpoloskun/twitch-chat/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

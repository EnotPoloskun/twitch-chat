# Twitch::Chat

`twitch-chat` library is a Twitch chat client which uses [Twitch IRC](http://help.twitch.tv/customer/portal/articles/1302780-twitch-irc).
[`TCPSocket`](https://ruby-doc.org/stdlib/libdoc/socket/rdoc/TCPSocket.html) (with [`Thread`](https://ruby-doc.org/core/Thread.html)) is used to handle connection to server.
With the help of this library you can connect to any Twitch's channel and handle various chat events. Can be used as Twitch chat bot engine.

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'twitch-chat'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install twitch-chat
```

## Usage

```ruby
require 'twitch/chat'

client = Twitch::Chat::Client.new(
  channel: 'channel', nickname: 'nickname', password: 'twitch_oath_token'
) do
  on :join do |channel|
    send_message "Hi guys on #{channel}!"
  end

  on :subscribe do |user|
    send_message "Hi #{user.name}, thank you for subscription"
  end

  on :slow_mode do
    send_message 'Slow down guys'
  end

  on :subscribers_mode_off do
    send_message 'FREEEEEDOOOOOM'
  end

  on :message do |message|
    send_message "Current time: #{Time.now.utc}" if message.text == '!time'
  end

  on :message do |message|
    if message.text.include?("Hi #{nickname}")
      send_message "Hi #{message.user.name}!"
    end
  end

  on :message do |message|
    send_message channel.moderators.join(', ') if message.text == '!moderators'
  end

  on :new_moderator do |user|
    send_message "#{user.display_name} is our new moderator"
  end

  on :remove_moderator do |user|
    send_message "#{user.display_name} is no longer moderator"
  end

  on :stop do
    send_message 'Bye guys!'
  end
end

client.run!
```

You can also join to channel later:

```ruby
client = Twitch::Chat::Client.new(
  nickname: 'nickname', password: 'twitch_oath_token'
) do
  on :message do |message|
    if message.text.include?("Hi #{nickname}")
      send_message "Hi #{message.user.name}!"
    end
  end
end

client.join 'channel'

client.run!
```

List of events:

*   `:authenticated`
*   `:join`
*   `:message`
*   `:bits`
*   `:slow_mode`
*   `:slow_mode_off`
*   `:r9k_mode`
*   `:r9k_mode_off`
*   `:followers_mode`
*   `:followers_mode_off`
*   `:subscribers_mode`
*   `:subscribers_mode_off`
*   `:subscribe`
*   `:stop`
*   `:not_supported`
*   `:raw`

``raw`` event is triggered for every Twitch IRC message. ``not_supported`` event is triggered for not supported Twitch IRC messages.

If local variable access is needed, the first block variable is the client:

```ruby
Twitch::Chat::Client.new(
  channel: 'channel', nickname: 'nickname', password: 'twitch_oath_token'
) do |client|
  # client is the client instance
end
```

By default, logging is done to the ``STDOUT``, but you can change it by passing log file path as ``:output`` parameter in ``initialize``:

```ruby
Twitch::Chat::Client.new(
  channel: 'channel', nickname: 'nickname', password: 'twitch_oath_token',
  output: 'file.log'
)
```

### Message object

In events with `message` argument, like `message`, you will get
an instance of `Message` class with such methods:

*   `text`
*   `user`
    *   `id` (Twitch ID, may be used for API)
    *   `name` (in lower case, like nickname)
    *   `display_name` (in user specified register)
    *   `badges` (a Hash with badge name and its level)
    *   `broadcaster?`
    *   `moderator?`
    *   `subscriber?`
*   `sent_at` (when message was sent or received)
*   `channel` (in what channel was sent)
*   `bits` (count of bits if sent)

## Contributing

1.  Fork it ( <https://github.com/enotpoloskun/twitch-chat/fork> )
2.  Create your feature branch (`git checkout -b my-new-feature`)
3.  Commit your changes (`git commit -am 'Add some feature'`)
4.  Push to the branch (`git push origin my-new-feature`)
5.  Create a new Pull Request

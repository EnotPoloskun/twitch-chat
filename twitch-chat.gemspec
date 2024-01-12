# frozen_string_literal: true

require_relative 'lib/twitch/chat/version'

Gem::Specification.new do |spec|
  spec.name          = 'twitch-chat'
  spec.version       = Twitch::Chat::VERSION
  spec.authors       = ['Pavel Astraukh']
  spec.email         = ['paladin111333@gmail.com']
  spec.summary       = <<~SUMMARY
    twitch-chat is a Twitch chat client that uses Twitch IRC. Can be used as twitch chat bot engine.
  SUMMARY
  spec.description = <<~DESC
    twitch-chat library is a Twitch chat client that uses Twitch IRC.
    `TCPSocket` is used to handle connections to servers.
    With the help of this library you can connect to any Twitch's channel and handle various chat events.
    Can be used as twitch chat bot engine.
  DESC
  spec.homepage      = 'https://github.com/EnotPoloskun/twitch-chat'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
end

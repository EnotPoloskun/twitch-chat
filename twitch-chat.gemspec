# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'twitch/chat/version'

Gem::Specification.new do |spec|
  spec.name          = "twitch-chat"
  spec.version       = Twitch::Chat::VERSION
  spec.authors       = ["Pavel Astraukh"]
  spec.email         = ["paladin111333@gmail.com"]
  spec.summary       = %q{twitch-chat is a Twitch chat client that uses Twitch IRC. Can be used as twitch chat bot engine.}
  spec.description   = %q{twitch-chat library is a Twitch chat client that uses Twitch IRC.
                        EventMachine is used to handle connections to servers.
                        With the help of this library you can connect to any Twitch's channel and handle various chat events.
                        Can be used as twitch chat bot engine.}
  spec.homepage      = "https://github.com/EnotPoloskun/twitch-chat"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "eventmachine"
  spec.add_dependency "activesupport"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end

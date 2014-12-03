require 'spec_helper'

describe Twitch::Chat::Message do
  context :type do
    context 'PRIVMSG' do
      context :message do
        let(:message) { Twitch::Chat::Message.new(":enotpoloskun!enotpoloskun@enotpoloskun.tmi.twitch.tv PRIVMSG #enotpoloskun :BibleThump") }

        it { message.type.should eq :message }
        it { message.message.should eq 'BibleThump' }
        it { message.user.should eq 'enotpoloskun' }
      end

      context :slow_mode do
        let(:message) { Twitch::Chat::Message.new(":jtv!jtv@jtv.tmi.twitch.tv PRIVMSG #enotpoloskun :This room is now in slow mode. You may send messages every 123 seconds") }

        it { message.type.should eq :slow_mode }
        it { message.user.should eq 'jtv' }
      end

      context :r9k_mode do
        let(:message) { Twitch::Chat::Message.new(":jtv!jtv@jtv.tmi.twitch.tv PRIVMSG #enotpoloskun :This room is now in r9k mode.") }

        it { message.type.should eq :r9k_mode }
        it { message.user.should eq 'jtv' }
      end

      context :r9k_mode do
        let(:message) { Twitch::Chat::Message.new(":jtv!jtv@jtv.tmi.twitch.tv PRIVMSG #enotpoloskun :This room is now in subscribers-only mode.") }

        it { message.type.should eq :subscribers_mode }
        it { message.user.should eq 'jtv' }
      end

      context :subscribe do
        let(:message) { Twitch::Chat::Message.new(":twitchnotify!twitchnotify@twitchnotify.tmi.twitch.tv PRIVMSG #enotpoloskun :enotpoloskun just subscribed!") }

        it { message.type.should eq :subscribe }
        it { message.user.should eq 'twitchnotify' }
      end
    end
  end
end

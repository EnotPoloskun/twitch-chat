require 'spec_helper'

describe Twitch::Chat::Client do
  let(:client) { Twitch::Chat::Client.new(password: 'password', nickname: 'enotpoloskun') }

  describe '#on' do
    context 'There is one message callback' do
      before { client.on(:message) { 'callback1' } }

      it { client.callbacks[:message].count.should eq 1 }

      context "There is another message callback" do
        before { client.on(:message) { 'callback2' } }

        it { client.callbacks[:message].count.should eq 2 }
      end
    end
  end

  describe '#trigger' do
    before { client.on(:message) { client.inspect } }

    it { client.should_receive(:inspect) }

    after { client.trigger(:message) }
  end
end

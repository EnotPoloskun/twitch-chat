# frozen_string_literal: true

describe Twitch::Chat::Client do
  subject(:client) do
    described_class.new(password: 'password', nickname: 'enotpoloskun')
  end

  describe '#on' do
    context 'with one message callback' do
      subject { client.instance_variable_get(:@callbacks)[:message].count }

      before { client.on(:message) { 'callback1' } }

      it { is_expected.to eq 1 }

      context 'with another message callback' do
        before { client.on(:message) { 'callback2' } }

        it { is_expected.to eq 2 }
      end
    end
  end

  describe '#trigger' do
    specify do
      expect do |b|
        client.on(:message, &b)

        client.trigger(:message)
      end.to yield_control.once
    end
  end

  describe 'reconnection' do
    let(:socket) { instance_double(TCPSocket) }

    before do
      allow(socket).to receive(:set_encoding)

      allow(socket).to receive(:puts).with(a_string_starting_with('CAP REQ '))
      allow(socket).to receive(:puts).with(a_string_starting_with('PASS '))
      allow(socket).to receive(:puts).with(a_string_starting_with('NICK '))

      allow(TCPSocket).to receive(:new).and_return socket

      ## 3 fails + 1 stop
      allow(socket).to receive(:close).exactly(3 + 1).times

      gets_call_count = 0
      allow(socket).to receive(:gets) do
        gets_call_count += 1

        raise Errno::EPIPE if gets_call_count.between? 3, 5

        ## next after 1 success after the last fail
        client.stop if gets_call_count == 5 + 1 + 1

        'foo'
      end

      client.run!
    end

    it { expect(socket).to have_received(:gets).exactly(7).times }
  end
end

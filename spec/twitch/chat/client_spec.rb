# frozen_string_literal: true

describe Twitch::Chat::Client do
  let(:client) do
    Twitch::Chat::Client.new(password: 'password', nickname: 'enotpoloskun')
  end

  describe '#on' do
    context 'There is one message callback' do
      subject { client.instance_variable_get(:@callbacks)[:message].count }

      before { client.on(:message) { 'callback1' } }

      it { is_expected.to eq 1 }

      context 'There is another message callback' do
        before { client.on(:message) { 'callback2' } }

        it { is_expected.to eq 2 }
      end
    end
  end

  describe '#trigger' do
    before { client.on(:message) { client.inspect } }

    it { expect(client).to receive(:inspect) }

    after { client.trigger(:message) }
  end

  describe 'reconnection' do
    let(:socket) { instance_double(TCPSocket) }

    before do
      allow(client).to receive(:initialize_socket) do
        client.instance_variable_set :@socket, socket
      end

      allow(socket).to receive(:puts).with(a_string_starting_with('CAP REQ '))
      allow(socket).to receive(:puts).with(a_string_starting_with('PASS '))
      allow(socket).to receive(:puts).with(a_string_starting_with('NICK '))

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

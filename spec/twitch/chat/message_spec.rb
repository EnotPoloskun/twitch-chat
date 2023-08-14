# frozen_string_literal: true

describe Twitch::Chat::Message do
  context :type do
    let(:message) { Twitch::Chat::Message.new(raw) }

    context 'PRIVMSG' do
      context :message do
        let(:raw) do
          <<~RAW
            :enotpoloskun!enotpoloskun@enotpoloskun.tmi.twitch.tv PRIVMSG #enotpoloskun :BibleThump
          RAW
        end

        it { expect(message.type).to eq :message }
        it { expect(message.text).to eq 'BibleThump' }
        it { expect(message.user.name).to eq 'enotpoloskun' }
      end

      context :slow_mode do
        let(:raw) do
          <<~RAW
            @room-id=117474239;slow=10 :tmi.twitch.tv ROOMSTATE #alexwayfer
          RAW
        end

        it { expect(message.type).to eq :slow_mode }
        it { expect(message.channel).to eq 'alexwayfer' }
      end

      context :slow_mode_off do
        let(:raw) do
          <<~RAW
            @room-id=117474239;slow=0 :tmi.twitch.tv ROOMSTATE #alexwayfer
          RAW
        end

        it { expect(message.type).to eq :slow_mode_off }
        it { expect(message.channel).to eq 'alexwayfer' }
      end

      context :r9k_mode do
        let(:raw) do
          <<~RAW
            @r9k=1;room-id=117474239 :tmi.twitch.tv ROOMSTATE #alexwayfer
          RAW
        end

        it { expect(message.type).to eq :r9k_mode }
        it { expect(message.channel).to eq 'alexwayfer' }
      end

      context :r9k_mode_off do
        let(:raw) do
          <<~RAW
            @r9k=0;room-id=117474239 :tmi.twitch.tv ROOMSTATE #alexwayfer
          RAW
        end

        it { expect(message.type).to eq :r9k_mode_off }
        it { expect(message.channel).to eq 'alexwayfer' }
      end

      context :subscribers_mode do
        let(:raw) do
          <<~RAW
            @room-id=128644134;subs-only=1 :tmi.twitch.tv ROOMSTATE #sad_satont
          RAW
        end

        it { expect(message.type).to eq :subscribers_mode }
        it { expect(message.channel).to eq 'sad_satont' }
      end

      context :subscribers_mode_off do
        let(:raw) do
          <<~RAW
            @room-id=128644134;subs-only=0 :tmi.twitch.tv ROOMSTATE #sad_satont
          RAW
        end

        it { expect(message.type).to eq :subscribers_mode_off }
        it { expect(message.channel).to eq 'sad_satont' }
      end

      context :subscribe do
        let(:raw) do
          <<~RAW
            :twitchnotify!twitchnotify@twitchnotify.tmi.twitch.tv PRIVMSG #enotpoloskun :enotpoloskun just subscribed!
          RAW
        end

        it { expect(message.type).to eq :subscribe }
        it { expect(message.user.name).to eq 'twitchnotify' }
      end

      context :bits do
        let(:raw) do
          <<~RAW
            @badge-info=;badges=bits/5000;bits=1000 :alexwayfer!alexwayfer@alexwayfer.tmi.twitch.tv PRIVMSG #stas_satori :Corgo1 thank you!
          RAW
        end

        it { expect(message.type).to eq :bits }
        it { expect(message.channel).to eq 'stas_satori' }
        it { expect(message.user.name).to eq 'alexwayfer' }
        it { expect(message.text).to eq 'Corgo1 thank you!' }
        it { expect(message.bits).to eq '1000' }
      end
    end

    context 'MODE' do
      let(:raw) do
        <<~RAW
          :jtv MODE #enotpoloskun +o enotpoloskun
        RAW
      end

      it { expect(message.user).to eq nil }
      it { expect(message.type).to eq :mode }
    end

    context 'PING' do
      let(:host) { 'tmi.twitch.tv' }

      let(:raw) do
        <<~RAW
          PING :#{host}
        RAW
      end

      it { expect(message.user).to eq nil }
      it { expect(message.type).to eq :ping }
      it { expect(message.params.last).to eq host }
    end

    context 'NOTIFY' do
      context :login_failed do
        let(:raw) do
          <<~RAW
            :tmi.twitch.tv NOTICE * :Login authentication failed
          RAW
        end

        it { expect(message.user).to eq nil }
        it { expect(message.type).to eq :login_failed }
      end
    end
  end
end

# frozen_string_literal: true

describe Twitch::Chat::User do
  subject { described_class.new(name, additional_info) }

  let(:name) { 'alexwayfer' }

  let(:additional_info) do
    {
      'badge-info' => 'subscriber/1',
      'badges' => badges,
      'color' => '#1E90FF',
      'display-name' => display_name,
      'emotes' => '81274:8-13',
      'flags' => '',
      'mod' => mod,
      'room-id' => '117474239',
      'subscriber' => subscriber,
      'turbo' => '0',
      'user-id' => user_id,
      'user-type' => ''
    }
  end

  let(:user_id) { '117474239' }
  let(:display_name) { 'AlexWayfer' }
  let(:badges) { 'broadcaster/1,subscriber/0' }

  let(:mod) { '0' }
  let(:subscriber) { '1' }

  describe '#id' do
    subject { super().id }

    it { is_expected.to eq user_id }
  end

  describe '#name' do
    subject { super().name }

    it { is_expected.to eq name }
  end

  describe '#display_name' do
    subject { super().display_name }

    it { is_expected.to eq display_name }
  end

  describe '#badges' do
    subject { super().badges }

    let(:badges) { 'broadcaster/1,subscriber/0' }

    it { is_expected.to eq('broadcaster' => '1', 'subscriber' => '0') }
  end

  describe '#broadcaster?' do
    subject { super().broadcaster? }

    context 'when there is broadcaster badge' do
      let(:badges) { 'broadcaster/1,subscriber/0' }

      it { is_expected.to be true }
    end

    context 'when there is no broadcaster badge' do
      let(:badges) { 'subscriber/0' }

      it { is_expected.to be false }
    end
  end

  describe '#moderator?' do
    subject { super().moderator? }

    context 'when there is moderator info' do
      let(:mod) { '1' }

      it { is_expected.to be true }
    end

    context 'when there is no moderator info' do
      let(:mod) { '0' }

      it { is_expected.to be false }
    end
  end

  describe '#subscriber?' do
    subject { super().subscriber? }

    context 'when there is subscriber info' do
      let(:subscriber) { '1' }

      it { is_expected.to be true }
    end

    context 'when there is no subscriber info' do
      let(:subscriber) { '0' }

      it { is_expected.to be false }
    end
  end
end

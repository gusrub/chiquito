require 'rails_helper'

RSpec.describe ShortUrl, type: :model do
  subject { FactoryBot.build :short_url }

  describe :validations do
    it { should validate_presence_of(:original) }
    it { should validate_presence_of(:ip_address) }
    it do
      should validate_numericality_of(:visit_count)
      .only_integer
      .is_greater_than_or_equal_to(0)
    end
    it { should validate_uniqueness_of(:short) }
    it { should validate_length_of(:short).is_at_most(ShortUrl::CUSTOM_MAX_LENGTH) }
    it do
      is_expected.to define_enum_for(:expiration)
      .with_suffix
      .with_values(ShortUrl.expirations.keys)
    end
    it 'should validate short URL allowed chars' do
      subject.short = "España!"
      expect(subject.valid?).to be(false)
      expect(subject.errors.messages).to include(:short)
    end

    context 'when record is saved' do
      let(:short_url) { FactoryBot.create(:short_url) }

      before(:each) do
        short_url.short = nil
      end

      it 'validates the short URL presence' do
        expect(short_url.valid?).to be(false)
        expect(short_url.errors.messages).to include(:short)
      end
    end

    context 'if custom short URL is taken and collides with autogeneration' do
      let!(:custom_url) { FactoryBot.create(:short_url, short: 'abc') }
      let(:conflicting_url) { FactoryBot.build(:short_url) }
      let(:fallback) { 'abc2' }

      before(:each) do
        allow_any_instance_of(ShortUrl)
          .to receive(:bijective_encode)
          .and_return('abc')
      end

      it 'generates an alternative unique URL' do
        expect(conflicting_url.save).to be(true)
        expect(conflicting_url.short).to eq(fallback)
      end
    end
  end

  describe :callbacks do
    let(:short_url) { FactoryBot.build(:short_url, short: nil) }

    it 'should set a default expiration before validation' do
      subject.expiration = nil
      expect { subject.valid? }.to change { subject.expiration }
    end

    it 'should generate the short URL if none was given after save' do
      expect { short_url.save }.to change { short_url.short }.from(nil)
    end
  end

  describe :custom_methods do

    describe '#visited!' do
      it 'bumps the visit count' do
        expect { subject.visited! }.to change { subject.visit_count }
      end
    end
  end

  describe :scopes do
    let(:max) { ENV['MAX_TOP_RECORDS'].to_i }
    let!(:urls) { FactoryBot.create_list(:short_url, max+1) }

    context 'if no max is given' do
      it 'returns the default max' do
        expect(ShortUrl.top_visited.count).to eq(max)
      end
    end

    context 'if a max number is given' do
      it 'returns the top number given' do
        expect(ShortUrl.top_visited(max: max-1).count).to eq(max-1)
      end
    end
  end

end

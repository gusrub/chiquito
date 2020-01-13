require 'rails_helper'

RSpec.describe ShortUrl, type: :model do
  subject { FactoryBot.build :short_url }

  describe :validations do
    it { should validate_presence_of(:original) }
    it { should validate_presence_of(:ip_address) }
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

end

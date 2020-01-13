FactoryBot.define do
  factory :short_url do
    original { Faker::Internet.url }
    ip_address { Faker::Internet.public_ip_v4_address }
    expiration { ShortUrl.expirations.keys.sample }
    title { Faker::Lorem.sentence(word_count: 4) }
  end
end

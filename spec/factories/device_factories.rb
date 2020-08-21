FactoryBot.define do
  factory :device do
    name { Faker::Name.name }
    # code_used_at {Time.zone.now - 1.days}
    association :user, factory: :user
    # association :organization, factory: :user
    # organization {user.association}
    before(:create) do |device|
      device.organization = device.user.organization
    end
    factory :device_with_access_token do
      access_token {SecureRandom.base58(32)}
      access_token_expired_at {Time.zone.now + 30.seconds}
    end
  end
  factory :slang_device,  class: Device do
    name { Faker::Name.name }
  end
end

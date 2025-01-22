value_types = ['percent-off', 'dollar-off']

FactoryBot.define do
  factory :coupon do
    name { Faker::Name.middle_name }
    code { Faker::Commerce.promotion_code }
    value_type { value_types.sample }
    value { Faker::Commerce.price }
    activated { false }
    merchant_id { nil }
    association :merchant
  end
end

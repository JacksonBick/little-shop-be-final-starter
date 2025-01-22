FactoryBot.define do
  factory :invoice do
    status { "shipped" }
    merchant_id { nil }
    customer_id { nil }
  end
end
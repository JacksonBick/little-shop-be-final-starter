FactoryBot.define do
  factory :coupon do
    name { "MyString" }
    code { "MyString" }
    value_type { "MyString" }
    value { "9.99" }
    activated { false }
    merchant { nil }
  end
end

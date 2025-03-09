FactoryBot.define do
  factory :coupon do
    merchant
    name { Faker::Commerce.product_name }  
    code { Faker::Alphanumeric.alphanumeric(number: 10).upcase }  
    discount_value { Faker::Number.decimal(l_digits: 2) }  
    discount_type { ['percentage', 'fixed'].sample }  
    status { [true, false].sample }  
  end
end
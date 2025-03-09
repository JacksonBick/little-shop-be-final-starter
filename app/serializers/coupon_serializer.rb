class CouponSerializer
  include JSONAPI::Serializer
  attributes :id, :name, :code, :discount_value, :discount_type, :status

  attribute :discount_value do |object|
    object.discount_value.to_f
  end
end
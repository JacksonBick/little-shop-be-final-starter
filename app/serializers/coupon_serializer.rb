class CouponSerializer
  include JSONAPI::Serializer
  attributes :name, :code, :value_type, :value, :activated
  belongs_to :merchant
end
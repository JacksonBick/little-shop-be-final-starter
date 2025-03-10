class InvoiceSerializer
  include JSONAPI::Serializer
  attributes :merchant_id, :customer_id, :status

  attribute :coupon_id do |object|
    object.coupon&.id || 0
  end
end
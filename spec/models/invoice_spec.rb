require "rails_helper"

RSpec.describe Invoice do
  it { should belong_to :merchant }
  it { should belong_to :customer }
  it { should validate_inclusion_of(:status).in_array(%w(shipped packaged returned)) }

  describe 'apply_coupon' do
    it 'applys coupon' do
      merchant = create(:merchant)
      coupon = create(:coupon, merchant_id: merchant.id)
      customer = create(:customer)
      invoice = create(:invoice, merchant_id: merchant.id, customer_id: customer.id)

      expect(invoice.coupon_id).to eq(nil)

      invoice.apply_coupon(coupon)

      expect(invoice.coupon_id).to eq(coupon.id)

    end
  end
end
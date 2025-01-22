require 'rails_helper'

RSpec.describe Coupon, type: :model do
  let(:merchant) { create(:merchant) }

  # Valid Coupon attributes for tests
  let(:valid_coupon_attributes) do
    {
      name: 'Discount Coupon',
      code: 'DISCOUNT123',
      value_type: 'percent-off',
      value: 10,
      merchant: merchant
    }
  end

  describe 'associations' do
    it { should belong_to(:merchant) }
    it { should have_many(:invoices) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:code) }
    it { should validate_presence_of(:value) }
    it { should validate_inclusion_of(:value_type).in_array(['percent-off', 'dollar-off']) }

    it 'validates uniqueness of coupon code per merchant' do
      create(:coupon, merchant: merchant, code: 'DISCOUNT123')
      duplicate_coupon = build(:coupon, merchant: merchant, code: 'DISCOUNT123')

      expect(duplicate_coupon).not_to be_valid
      expect(duplicate_coupon.errors[:code]).to include('Coupon code must be unique per merchant.')
    end

    it 'limits merchant to 5 active coupons' do
      create_list(:coupon, 5, merchant: merchant, activated: true)

      new_coupon = build(:coupon, merchant: merchant, activated: true)

      expect(new_coupon).not_to be_valid
      expect(new_coupon.errors[:base]).to include('A merchant can only have 5 active coupons at a time.')
    end
  end

  describe 'callbacks' do
    it 'sets activated to false by default' do
      coupon = Coupon.create(valid_coupon_attributes.except(:activated))
      expect(coupon.activated).to eq(false)
    end
  end

  describe '#toggle_activation' do
    it 'toggles the activated status of the coupon' do
      coupon = create(:coupon, activated: true)
      coupon.toggle_activation
      expect(coupon.activated).to eq(false)

      coupon.toggle_activation
      expect(coupon.activated).to eq(true)
    end
  end

  describe '#usage_count' do
    it 'returns the number of invoices the coupon has been used in' do
      coupon = create(:coupon, merchant: merchant)
      invoice1 = create(:invoice, coupon: coupon)
      invoice2 = create(:invoice, coupon: coupon)

      expect(coupon.usage_count).to eq(2)
    end
  end
end

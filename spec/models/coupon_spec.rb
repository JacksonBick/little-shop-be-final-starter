require 'rails_helper'

RSpec.describe Coupon, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:code) }
  it { should validate_presence_of(:discount_value) }
  it { should validate_presence_of(:discount_type) }
  it { should validate_presence_of(:status) }

  it { should belong_to(:merchant) }
  it { should have_many(:invoices) }

  describe 'Scopes' do
    before do
      @active_coupon = create(:coupon, status: :active)
      @inactive_coupon = create(:coupon, status: :inactive)
    end

    it 'returns only active coupons when active is called' do
      expect(Coupon.active).to include(@active_coupon)
      expect(Coupon.active).not_to include(@inactive_coupon)
    end

    it 'returns only inactive coupons when inactive is called' do
      expect(Coupon.inactive).to include(@inactive_coupon)
      expect(Coupon.inactive).not_to include(@active_coupon)
    end
  end

  describe 'usage_count' do
    it 'returns the count of invoices for a coupon' do
      @coupon = create(:coupon)
      expect(@coupon.usage_count).to eq(0)
      @invoice = create(:invoice, coupon: @coupon)
      expect(@coupon.usage_count).to eq(1)
    end

    it 'returns 0 if no invoices for a coupon' do
      coupon_without_invoices = create(:coupon)
      expect(coupon_without_invoices.usage_count).to eq(0)
    end
  end

  describe 'filter_by_status' do
    before do
      @active_coupon = create(:coupon, status: :active)
      @inactive_coupon = create(:coupon, status: :inactive)
    end

    it 'returns only active coupons' do
      expect(Coupon.filter_by_status('active')).to include(@active_coupon)
      expect(Coupon.filter_by_status('active')).not_to include(@inactive_coupon)
    end

    it 'returns only inactive coupons' do
      expect(Coupon.filter_by_status('inactive')).to include(@inactive_coupon)
      expect(Coupon.filter_by_status('inactive')).not_to include(@active_coupon)
    end

    it 'returns all coupons' do
      expect(Coupon.filter_by_status('other')).to include(@active_coupon, @inactive_coupon)
    end
  end

  describe 'Having valid discount type' do
    before do
      merchant = create(:merchant)

      @valid_attributes = {
        name: 'Summer Sale',
        code: 'SUMMER20',
        discount_value: 20,
        discount_type: 'percentage',  
        status: "active",
        merchant: merchant
      }

      @invalid_attributes = {
        name: 'Winter Sale',
        code: 'WINTER20',
        discount_value: 20,
        discount_type: 'nothing', 
        status: "active",
        merchant: merchant
      }
    end

    it 'is valid with a discount type of "percentage"' do
      coupon = Coupon.new(@valid_attributes.merge(discount_type: 'percentage'))
      expect(coupon).to be_valid
    end

    it 'is valid with a discount type of "dollar off"' do
      coupon = Coupon.new(@valid_attributes.merge(discount_type: 'dollar off'))
      expect(coupon).to be_valid
    end
  end
end
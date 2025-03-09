require 'rails_helper'

RSpec.describe 'Merchant Coupons', type: :request do
  describe 'GET all merchants coupons' do
    it 'should return an array of coupons for the merchant' do
      merchant = create(:merchant)
      create_list(:coupon, 5, merchant: merchant)

      get "/api/v1/merchants/#{merchant.id}/coupons"

      json = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(:ok)
      expect(json[:data].size).to eq(5)

      json[:data].each do |coupon|
        expect(coupon[:attributes]).to have_key(:name)
        expect(coupon[:attributes]).to have_key(:code)
        expect(coupon[:attributes]).to have_key(:discount_value)
        expect(coupon[:attributes]).to have_key(:discount_type)
        expect(coupon[:attributes]).to have_key(:status)
      end
    end
  end

  describe 'GET a specific coupon' do
    it 'should get coupon based on param' do
      merchant = create(:merchant)
      coupon = create(:coupon, merchant: merchant)

      get "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}"

      json = JSON.parse(response.body, symbolize_names: true)
    end
  end
end
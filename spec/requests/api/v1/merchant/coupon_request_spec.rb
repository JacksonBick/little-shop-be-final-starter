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
      expect(response).to have_http_status(:ok)
      expect(json[:data][:id].to_i).to eq(coupon.id)
      expect(json[:data][:attributes][:name]).to eq(coupon.name)
      expect(json[:data][:attributes][:code]).to eq(coupon.code)
      expect(json[:data][:attributes][:discount_value]).to eq(coupon.discount_value)
      expect(json[:data][:attributes][:discount_type]).to eq(coupon.discount_type)
      expect(json[:data][:attributes][:status]).to eq(coupon.status)
    end

    it 'should return an error if coupon is not found' do
      merchant = create(:merchant)
      get "/api/v1/merchants/#{merchant.id}/coupons/9999"  

      json = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(:not_found)
      expect(json[:error]).to eq('Record not found')
    end
  end

  describe 'POST create a coupon' do
    it 'should create a new coupon for the merchant' do
      merchant = create(:merchant)
      coupon_params = {
        name: 'Summer Sale',
        code: 'SUMMER20',
        discount_value: 20,
        discount_type: 'percentage',
        status: "active"
      }

      post "/api/v1/merchants/#{merchant.id}/coupons", params: { coupon: coupon_params }

      json = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(:created)
      expect(json[:data][:attributes][:name]).to eq(coupon_params[:name])
      expect(json[:data][:attributes][:code]).to eq(coupon_params[:code])
      expect(json[:data][:attributes][:discount_value]).to eq(coupon_params[:discount_value])
      expect(json[:data][:attributes][:discount_type]).to eq(coupon_params[:discount_type])
      expect(json[:data][:attributes][:status]).to eq(coupon_params[:status])
    end

    it 'should return an error if there are more than 5 active coupons' do
      merchant = create(:merchant)
      create_list(:coupon, 5, merchant: merchant, status: true)

      coupon_params = {
        name: 'Winter Sale',
        code: 'WINTER10',
        discount_value: 10,
        discount_type: 'percentage',
        status: "active"
      }

      post "/api/v1/merchants/#{merchant.id}/coupons", params: { coupon: coupon_params }

      json = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:error]).to eq('A merchant can only have a maximum of 5 active coupons at a time.')
    end

    it 'should return an error if parameters are invalid' do
      merchant = create(:merchant)
      coupon_params = { name: '', code: '', discount_value: nil, discount_type: nil, status: nil }

      post "/api/v1/merchants/#{merchant.id}/coupons", params: { coupon: coupon_params }

      json = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:error]).to eq('That is not a valid parameter')
    end
  end

  describe 'PATCH update a coupon' do
    it 'should update the coupon for the merchant' do
      merchant = create(:merchant)
      coupon = create(:coupon, merchant: merchant, status: 'inactive')
      
      updated_params = {
        name: 'Updated Summer Sale',
        code: 'SUMMER21',
        discount_value: 30,
        discount_type: 'percentage',
        status: 'active'  
      }

      patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}", params: { coupon: updated_params }

      json = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(:ok)
      expect(json[:data][:attributes][:name]).to eq(updated_params[:name])
      expect(json[:data][:attributes][:code]).to eq(updated_params[:code])
      expect(json[:data][:attributes][:discount_value]).to eq(updated_params[:discount_value])
      expect(json[:data][:attributes][:discount_type]).to eq(updated_params[:discount_type])
      expect(json[:data][:attributes][:status]).to eq(updated_params[:status])
    end

    it 'should return an error if there are more than 5 active coupons' do
      merchant = create(:merchant)
      create_list(:coupon, 5, merchant: merchant, status: 'active')  

      coupon_params = {
        name: 'Winter Sale',
        code: 'WINTER10',
        discount_value: 10,
        discount_type: 'percentage',
        status: 'active' 
      }

      post "/api/v1/merchants/#{merchant.id}/coupons", params: { coupon: coupon_params }

      json = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:error]).to eq('A merchant can only have a maximum of 5 active coupons at a time.')
    end
  end

  describe 'PATCH deactivate a coupon' do
    it 'should deactivate the coupon for the merchant' do
      merchant = create(:merchant)
      coupon = create(:coupon, merchant: merchant, status: 'active')

      patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}/deactivate"

      json = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(:ok)
      expect(json[:data][:attributes][:status]).to eq('inactive')  
    end
  end

  describe 'PATCH activate a coupon' do
    it 'should activate the coupon for the merchant' do
      merchant = create(:merchant)
      coupon = create(:coupon, merchant: merchant, status: 'inactive')

      patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}/activate"

      json = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(:ok)
      expect(json[:data][:attributes][:status]).to eq('active')  
    end
  end
end
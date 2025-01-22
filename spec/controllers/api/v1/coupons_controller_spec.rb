require "rails_helper"

RSpec.describe Api::V1::CouponsController, type: :controller do
  before(:each) do
    @merchant = create(:merchant)
    # Creating 5 coupons for the merchant
    5.times do
      create(:coupon, merchant: @merchant)
    end
    @coupon = create(:coupon, merchant: @merchant)  # Ensure @coupon exists for #show and other tests that need it
  end

  describe 'GET #index' do
    context 'when no status is provided' do
      it 'returns all coupons for the merchant' do
        get :index, params: { merchant_id: @merchant.id }
        coupons = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:ok)
        expect(coupons[:data].size).to eq(6)  # 5 from setup + 1 from @coupon
        expect(coupons[:data].first[:type]).to eq("coupon")
        
        coupons[:data].each do |coupon| 
          expect(coupon[:type]).to eq("coupon") 
          expect(coupon[:attributes][:merchant_id]).to eq(@merchant.id)
        end
      end
    end

    context 'when status is active' do
      it 'returns only active coupons' do
        active_coupon = create(:coupon, merchant: @merchant, activated: true)
        inactive_coupon = create(:coupon, merchant: @merchant, activated: false)

        get :index, params: { merchant_id: @merchant.id, status: 'active' }

        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json_response['data'].size).to eq(1)
        expect(json_response['data'].first['attributes']['activated']).to eq(true)
      end
    end

    context 'when status is inactive' do
      it 'returns only inactive coupons' do
        active_coupon = create(:coupon, merchant: @merchant, activated: true)
        inactive_coupon = create(:coupon, merchant: @merchant, activated: false)

        get :index, params: { merchant_id: @merchant.id, status: 'inactive' }

        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json_response['data'].size).to eq(7)  
        expect(json_response['data'].first['attributes']['activated']).to eq(false)
      end
    end

    context 'when status is invalid' do
      it 'returns an error' do
        get :index, params: { merchant_id: @merchant.id, status: 'invalid' }

        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to eq("Invalid status parameter. Use 'active' or 'inactive'.")
      end
    end
  end

  describe 'GET #show' do
    it 'returns the coupon' do
      # Ensure that the path is correct
      get "/api/v1/merchants/#{@merchant.id}/coupons/#{@coupon.id}" 
      
      #  get :show, params: { merchant_id: @merchant.id, coupon_id: @coupon.id }
      
      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['id']).to eq(@coupon.id.to_s)
      expect(json_response['data']['attributes']['name']).to eq(@coupon.name)
    end
  end

  describe 'POST #create' do
    it 'creates a new coupon with valid attributes' do
      valid_attributes = { name: 'New Coupon', activated: false, merchant_id: @merchant.id }

      post :create, params: { merchant_id: @merchant.id, coupon: valid_attributes }

      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:created)
      expect(json_response['data']['attributes']['name']).to eq('New Coupon')
      expect(json_response['data']['attributes']['activated']).to eq(false)
    end

    it 'returns an error when invalid attributes are provided' do
      invalid_attributes = { name: '', activated: nil }  # Missing or invalid attributes

      post :create, params: { merchant_id: @merchant.id, coupon: invalid_attributes }

      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response['error']).to eq("Name can't be blank")
    end
  end

  describe 'PUT #update' do
    it 'updates the coupon' do
      updated_attributes = { name: 'Updated Coupon Name', activated: true }

      put :update, params: { merchant_id: @merchant.id, coupon_id: @coupon.id, coupon: updated_attributes }

      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['attributes']['name']).to eq('Updated Coupon Name')
      expect(json_response['data']['attributes']['activated']).to eq(true)
    end

    it 'returns an error when coupon does not exist' do
      updated_attributes = { name: 'Updated Coupon Name', activated: true }

      put :update, params: { merchant_id: @merchant.id, coupon_id: 99999, coupon: updated_attributes }

      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:not_found)
      expect(json_response['error']).to eq('Coupon not found')
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the coupon' do
      coupon_to_delete = create(:coupon, merchant: @merchant)  # Create a coupon for deletion

      delete :destroy, params: { merchant_id: @merchant.id, coupon_id: coupon_to_delete.id }

      expect(response).to have_http_status(:no_content)
      expect(Coupon.exists?(coupon_to_delete.id)).to eq(false)
    end

    it 'returns forbidden if coupon cannot be deleted' do
      coupon_to_delete = create(:coupon, merchant: @merchant, activated: true)  # e.g., Coupon that can't be deleted

      delete :destroy, params: { merchant_id: @merchant.id, coupon_id: coupon_to_delete.id }

      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:forbidden)
      expect(json_response['error']).to eq('Cannot delete activated coupon')
    end
  end

  describe 'POST #toggle_activation' do
    it 'toggles the coupon activation status' do
      coupon = create(:coupon, merchant: @merchant, activated: false)

      post :toggle_activation, params: { merchant_id: @merchant.id, coupon_id: coupon.id }

      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['attributes']['activated']).to eq(true)
    end
  end

  describe 'POST #deactivate' do
    it 'deactivates the coupon' do
      coupon = create(:coupon, merchant: @merchant, activated: true)

      post :deactivate, params: { merchant_id: @merchant.id, coupon_id: coupon.id }

      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['attributes']['activated']).to eq(false)
    end
  end

  describe 'POST #activate' do
    it 'activates the coupon' do
      coupon = create(:coupon, merchant: @merchant, activated: false)

      post :activate, params: { merchant_id: @merchant.id, coupon_id: coupon.id }

      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['attributes']['activated']).to eq(true)
    end
  end
end
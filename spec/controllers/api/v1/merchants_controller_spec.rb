require 'rails_helper'

RSpec.describe Api::V1::MerchantsController, type: :controller do
  let(:merchant) { create(:merchant) }

  before do
    sign_in(create(:user)) # if you have authentication in place
  end

  describe 'GET #index' do
    context 'when sorted by age' do
      it 'returns merchants ordered by creation date' do
        old_merchant = create(:merchant, created_at: 2.days.ago)
        recent_merchant = create(:merchant, created_at: 1.day.ago)

        get :index, params: { sorted: 'age' }

        expect(response).to have_http_status(:ok)
        expect(json['data'][0]['id']).to eq(recent_merchant.id.to_s)
      end
    end

    context 'when filtering by status' do
      it 'filters merchants by invoice status' do
        create(:invoice, merchant: merchant, status: 'paid')
        create(:invoice, merchant: merchant, status: 'pending')

        get :index, params: { status: 'paid' }

        expect(response).to have_http_status(:ok)
        expect(json['data'].size).to eq(1)
      end
    end
  end

  describe 'GET #show' do
    it 'returns the merchant details' do
      get :show, params: { id: merchant.id }

      expect(response).to have_http_status(:ok)
      expect(json['data']['id']).to eq(merchant.id.to_s)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new merchant' do
        merchant_params = { name: 'New Merchant' }

        post :create, params: merchant_params

        expect(response).to have_http_status(:created)
        expect(json['data']['attributes']['name']).to eq('New Merchant')
      end
    end

    context 'with invalid attributes' do
      it 'returns an error' do
        merchant_params = { name: '' }

        post :create, params: merchant_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to be_present
      end
    end
  end

  describe 'PUT #update' do
    it 'updates the merchant details' do
      updated_attributes = { name: 'Updated Merchant' }

      put :update, params: { id: merchant.id, merchant: updated_attributes }

      expect(response).to have_http_status(:ok)
      expect(json['data']['attributes']['name']).to eq('Updated Merchant')
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the merchant' do
      delete :destroy, params: { id: merchant.id }

      expect(response).to have_http_status(:no_content)
      expect(Merchant.exists?(merchant.id)).to eq(false)
    end
  end
end
module Api
  module V1
    class CouponsController < ApplicationController
      before_action :set_merchant

      def index
        @coupons = @merchant.coupons  # Ensure @merchant is loaded correctly
        render json: @coupons
      end

      private

      def set_merchant
        @merchant = Merchant.find(params[:merchant_id])
      end
    end
  end
end
class RemoveDiscountFromCoupons < ActiveRecord::Migration[7.1]
  def change
    remove_column :coupons, :discount, :integer
  end
end

class ChangeActivatedDefaultInCoupons < ActiveRecord::Migration[7.1]
  def change
    change_column_default :coupons, :activated, false
    change_column_null :coupons, :activated, false
  end
end

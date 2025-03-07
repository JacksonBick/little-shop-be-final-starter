class AddToCoupons < ActiveRecord::Migration[7.1]
  def change
    add_column :coupons, :name, :string
    add_column :coupons, :code, :string
    add_column :coupons, :discount_value, :decimal
    add_column :coupons, :discount_type, :string
    add_column :coupons, :status, :boolean, default: false
    add_index :coupons, :code, unique: true
  end
end

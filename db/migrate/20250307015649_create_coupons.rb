class CreateCoupons < ActiveRecord::Migration[7.1]
  def change
    create_table :coupons do |t|
      t.references :merchant, null: false, foreign_key: true
      t.integer :discount

      t.timestamps
    end
  end
end

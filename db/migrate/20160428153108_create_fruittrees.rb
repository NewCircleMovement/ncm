class CreateFruittrees < ActiveRecord::Migration
  def change
    create_table :fruittrees do |t|
      t.integer :owner_id
      t.string :owner_type
      t.integer :fruits_per_month
      t.integer :fruittype_id

      t.timestamps null: false
    end
  end
end

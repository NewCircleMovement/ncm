class CreateFruitbags < ActiveRecord::Migration
  def change
    create_table :fruitbags do |t|
      t.integer :amount
      t.string :fruittype_id
      t.string :fruitbasket_id

      t.timestamps null: false
    end
  end
end

class CreateFruitbaskets < ActiveRecord::Migration
  def change
    create_table :fruitbaskets do |t|
      t.integer :owner_id
      t.string :owner_type
      t.integer :fruits
      t.integer :fruittype_id

      t.timestamps null: false
    end
  end
end

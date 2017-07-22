class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.string :kind
      t.boolean :bookable
      t.string :title
      t.text :body
      t.integer :owner_id
      t.string :owner_type
      t.integer :calender_id

      t.timestamps null: false
    end
  end
end

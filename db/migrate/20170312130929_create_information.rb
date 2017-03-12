class CreateInformation < ActiveRecord::Migration
  def change
    create_table :information do |t|
      t.integer :owner_id
      t.string :owner_type
      t.string :string
      t.integer :position
      t.string :title
      t.text :body

      t.timestamps null: false
    end
  end
end

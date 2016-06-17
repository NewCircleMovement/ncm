class CreateTshirts < ActiveRecord::Migration
  def change
    create_table :tshirts do |t|
      t.integer :epicenter_id
      t.integer :user_id
      t.integer :access_point_id

      t.timestamps null: false
    end
  end
end

class CreateAccessPoints < ActiveRecord::Migration
  def change
    create_table :access_points do |t|
      t.integer :location_id
      t.string :name

      t.timestamps null: false
    end
  end
end

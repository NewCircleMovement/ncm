class CreateEpicenters < ActiveRecord::Migration
  def change
    create_table :epicenters do |t|
      t.string :name
      t.text :description
      t.string :video_url
      t.integer :max_members, :default => 1000

      t.timestamps null: false
    end
  end
end

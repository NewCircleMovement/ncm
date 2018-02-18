class CreatePostits < ActiveRecord::Migration
  def change
    create_table :postits do |t|

      t.integer :resource_id
      t.integer :epicenter_id
      t.integer :owner_id
      t.string :owner_type
      t.integer :wall_id
      t.integer :visibility
      t.integer :asking, :default => 0
      t.boolean :only_epicenter, :default => false
      t.string :title
      t.text :body

      t.timestamps null: false

      t.index :resource_id
      t.index :owner_id
      t.index :owner_type
      t.index :only_epicenter
    end
  end
end

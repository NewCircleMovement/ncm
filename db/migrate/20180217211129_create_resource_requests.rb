class CreateResourceRequests < ActiveRecord::Migration
  def change
    create_table :resource_requests do |t|
      t.integer :requester_id
      t.integer :holder_id
      t.integer :resource_id
      t.integer :postit_id
      t.integer :amount
      t.boolean :accepted

      t.timestamps null: false

      t.index :resource_id
      t.index :holder_id
      t.index :resource_id
      t.index :postit_id
    end
  end
end

class AddFieldsToResourcesTable < ActiveRecord::Migration
  def change
    rename_column :resources, :kind, :type
    add_column :resources, :holder_id, :integer
    add_column :resources, :image, :string

    add_index :resources, :owner_id
    add_index :resources, :owner_type
    add_index :resources, :holder_id
  end
end

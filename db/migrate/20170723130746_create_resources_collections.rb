class CreateResourcesCollections < ActiveRecord::Migration
  def change
    create_table :resources_collections do |t|
    	t.integer :epipage_id
    	t.integer :resource_id
      t.timestamps null: false
    end
  end
end

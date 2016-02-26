class AddGrowAndManifestFieldsToEpicenter < ActiveRecord::Migration
  def change
    add_column :epicenters, :growing, :boolean, :default => false
    add_column :epicenters, :manifested, :boolean, :default => false
  end
end

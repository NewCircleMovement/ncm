class AddLocationToEpicenters < ActiveRecord::Migration
  def change
    add_column :epicenters, :location_id, :integer
    add_column :epicenters, :niveau, :integer
  end
end

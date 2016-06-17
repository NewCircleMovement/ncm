class AddDepthFieldsToEpicenters < ActiveRecord::Migration
  def change
    add_column :epicenters, :depth_members, :integer
    add_column :epicenters, :depth_fruits, :integer
  end
end

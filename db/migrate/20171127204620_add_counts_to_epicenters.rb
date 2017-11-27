class AddCountsToEpicenters < ActiveRecord::Migration
  def change
    add_column :epicenters, :members_count, :integer
    add_column :epicenters, :fruits_count, :integer
  end
end

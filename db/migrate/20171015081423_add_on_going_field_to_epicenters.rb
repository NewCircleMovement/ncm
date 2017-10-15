class AddOnGoingFieldToEpicenters < ActiveRecord::Migration
  def change
    add_column :epicenters, :ongoing, :boolean, :default => true
  end
end

class AddPostitsBooleanToEpicenters < ActiveRecord::Migration
  def change
    add_column :epicenters, :show_postits, :boolean, :default => false
  end
end

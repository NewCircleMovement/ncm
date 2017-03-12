class AddImageToEpicenters < ActiveRecord::Migration
  def change
    add_column :epicenters, :image, :string
  end
end

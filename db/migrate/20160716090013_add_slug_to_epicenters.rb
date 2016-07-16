class AddSlugToEpicenters < ActiveRecord::Migration
  def change
    add_column :epicenters, :slug, :string
  end
end

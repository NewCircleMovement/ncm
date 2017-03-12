class AddTaglineToEpicenters < ActiveRecord::Migration
  def change
    add_column :epicenters, :tagline, :string
  end
end

class AddTokenFieldToEpicenters < ActiveRecord::Migration
  def change
    add_column :epicenters, :api_token, :string, :default => nil
  end
end

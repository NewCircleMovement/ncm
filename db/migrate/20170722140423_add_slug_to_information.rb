class AddSlugToInformation < ActiveRecord::Migration
  def change
    add_column :information, :slug, :string
  end
end

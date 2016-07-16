class AddProfileToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :profile, :text
  end
end

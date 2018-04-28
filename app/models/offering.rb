# == Schema Information
#
# Table name: postits
#
#  id             :integer          not null, primary key
#  resource_id    :integer
#  epicenter_id   :integer
#  owner_id       :integer
#  owner_type     :string
#  wall_id        :integer
#  visibility     :integer
#  asking         :integer          default(0)
#  only_epicenter :boolean          default(FALSE)
#  title          :string
#  body           :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Offering < Postit
    
end

# == Schema Information
#
# Table name: postits
#
#  id             :integer          not null, primary key
#  resource_id    :integer
#  owner_id       :integer
#  owner_type     :string
#  wall_id        :integer
#  visibility     :integer
#  asking         :integer          default(0)
#  only_epicenter :boolean          default(FALSE)
#  title          :string
#  body           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Offering < Postit
    
end

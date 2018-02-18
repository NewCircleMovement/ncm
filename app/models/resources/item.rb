# == Schema Information
#
# Table name: resources
#
#  id          :integer          not null, primary key
#  type        :string
#  bookable    :boolean
#  title       :string
#  body        :text
#  owner_id    :integer
#  owner_type  :string
#  calender_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  holder_id   :integer
#  image       :string
#

class Item < Resource
    
end

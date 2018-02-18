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

class Resource < ActiveRecord::Base
    mount_uploader :image, ImageUploaderUser

    self.inheritance_column = :type

    scope :users, -> { where(owner_type: 'User') } 
    scope :epicenters, -> { where(owner_type: 'Epicenter')}

    belongs_to :owner, polymorphic: true

    has_one :fruitbasket, as: :owner, :dependent => :destroy
    has_many :postits
    has_many :resource_requests

    def show_requests(user)
      if self.owner == user
        return self.resource_requests.length >= 2
      else
        return true
      end
    end

    
    # has_many :information, as: :owner
    # has_one :calendar
    # accepts_nested_attributes_for :calendar
    # has_many :epipages, :through => :resources_collections
    # has_many :resources_collections

end

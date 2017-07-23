# == Schema Information
#
# Table name: resources
#
#  id          :integer          not null, primary key
#  kind        :string
#  bookable    :boolean
#  title       :string
#  body        :text
#  owner_id    :integer
#  owner_type  :string
#  calender_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Resource < ActiveRecord::Base

	has_many :information, as: :owner
	has_one :calendar
	accepts_nested_attributes_for :calendar

	has_many :epipages, :through => :resources_collections
	has_many :resources_collections

	belongs_to :owner, polymorphic: true

end

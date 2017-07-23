# == Schema Information
#
# Table name: epipages
#
#  id           :integer          not null, primary key
#  slug         :string
#  menu_title   :string
#  title        :string
#  body         :text
#  kind         :string           default("Info")
#  epicenter_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Epipage < ActiveRecord::Base
	validates :menu_title, :title, :presence => true

	belongs_to :epicenter

	has_many :resources, :through => :resources_collections
	has_many :resources_collections

	def to_param
		if self.slug
    		self.slug.parameterize
    	end
	end

end

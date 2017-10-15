# == Schema Information
#
# Table name: resources_collections
#
#  id          :integer          not null, primary key
#  epipage_id  :integer
#  resource_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class ResourcesCollection < ActiveRecord::Base

	belongs_to :epipage
	belongs_to :resource
	
end

# == Schema Information
#
# Table name: locations
#
#  id         :integer          not null, primary key
#  density    :integer
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Location < ActiveRecord::Base

	has_many :epicenters
	has_many :access_points

end

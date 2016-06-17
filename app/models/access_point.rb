# == Schema Information
#
# Table name: access_points
#
#  id          :integer          not null, primary key
#  location_id :integer
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class AccessPoint < ActiveRecord::Base

	belongs_to :location

end

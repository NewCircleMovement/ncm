# == Schema Information
#
# Table name: calendars
#
#  id            :integer          not null, primary key
#  day_start     :time
#  day_end       :time
#  module_length :float
#  flexible      :boolean
#  resource_id   :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Calendar < ActiveRecord::Base

	belongs_to :resource
	
end

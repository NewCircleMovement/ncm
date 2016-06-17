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

class Gateway < Location

	has_many :tshirt_keys

end

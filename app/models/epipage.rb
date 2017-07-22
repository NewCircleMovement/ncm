class Epipage < ActiveRecord::Base

	has_many :information, as: :owner

end

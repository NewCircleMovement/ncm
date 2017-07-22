class Resource < ActiveRecord::Base

	has_many :information, as: :owner

	belongs_to :owner, polymorphic: true

end

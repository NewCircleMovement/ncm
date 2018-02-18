class ResourceRequest < ActiveRecord::Base

  belongs_to :user, :foreign_key => :requester_id
  belongs_to :resource
  belongs_to :postit

end

# == Schema Information
#
# Table name: resource_requests
#
#  id           :integer          not null, primary key
#  requester_id :integer
#  holder_id    :integer
#  resource_id  :integer
#  postit_id    :integer
#  amount       :integer
#  accepted     :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class ResourceRequest < ActiveRecord::Base

  belongs_to :user, :foreign_key => :requester_id
  belongs_to :resource
  belongs_to :postit

end

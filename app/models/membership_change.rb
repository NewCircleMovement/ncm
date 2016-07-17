# == Schema Information
#
# Table name: membership_changes
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  epicenter_id      :integer
#  old_membership_id :integer
#  new_membership_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class MembershipChange < ActiveRecord::Base
end

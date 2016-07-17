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

require 'rails_helper'

RSpec.describe MembershipChange, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

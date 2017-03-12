# == Schema Information
#
# Table name: memberships
#
#  id           :integer          not null, primary key
#  name         :string
#  monthly_fee  :integer
#  epicenter_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  engagement   :integer          default(2)
#  payment_id   :string
#  monthly_gain :integer
#  profile      :text
#

require 'rails_helper'

RSpec.describe Membership, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

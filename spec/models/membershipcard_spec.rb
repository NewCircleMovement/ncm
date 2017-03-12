# == Schema Information
#
# Table name: membershipcards
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  membership_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  payment_id    :string
#  epicenter_id  :integer
#

require 'rails_helper'

RSpec.describe Membershipcard, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

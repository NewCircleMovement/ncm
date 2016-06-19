# == Schema Information
#
# Table name: tshirts
#
#  id              :integer          not null, primary key
#  epicenter_id    :integer
#  user_id         :integer
#  access_point_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  membership_id   :integer
#

require 'rails_helper'

RSpec.describe Tshirt, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

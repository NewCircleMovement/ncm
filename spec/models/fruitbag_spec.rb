# == Schema Information
#
# Table name: fruitbags
#
#  id             :integer          not null, primary key
#  amount         :integer          default(0)
#  fruittype_id   :string
#  fruitbasket_id :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'rails_helper'

RSpec.describe Fruitbag, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

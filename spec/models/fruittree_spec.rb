# == Schema Information
#
# Table name: fruittrees
#
#  id               :integer          not null, primary key
#  owner_id         :integer
#  owner_type       :string
#  fruits_per_month :integer
#  fruittype_id     :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'rails_helper'

RSpec.describe Fruittree, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

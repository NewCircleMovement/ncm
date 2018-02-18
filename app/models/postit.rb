# == Schema Information
#
# Table name: postits
#
#  id             :integer          not null, primary key
#  resource_id    :integer
#  owner_id       :integer
#  owner_type     :string
#  wall_id        :integer
#  visibility     :integer
#  asking         :integer          default(0)
#  only_epicenter :boolean          default(FALSE)
#  title          :string
#  body           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Postit < ActiveRecord::Base
  include PgSearch
  pg_search_scope :search_for, against: [:title, :body], using: { tsearch: { any_word: true } }

  validates :visibility, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  belongs_to :epicenter
  belongs_to :owner, polymorphic: true
  belongs_to :resource
  has_one :fruitbasket, as: :owner, :dependent => :destroy

  has_many :resource_requests

  def has_requester(user)
    requester_ids = self.resource_requests.map(&:requester_id)
    return requester_ids.include? user.id
  end
    
end

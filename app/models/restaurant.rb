class Restaurant < ApplicationRecord
  include ApplicationHelper
  include ValidationHelper

  has_many :menu_items, dependent: :destroy

  searchkick word_middle: [:name, :address]

  before_validation :sanitize_input

  validates :name, presence: true, length: { minimum: 5, maximum: 250 }, uniqueness: true
  validates :address, presence: true, length: { minimum: 5, maximum: 500 }

  scope :recently_created, -> { order(created_at: :desc) }

  private

  def sanitize_input
    sanitize_from_xcs_and_url %w[name address]
  end
end

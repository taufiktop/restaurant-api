class Category < ApplicationRecord 
  include ApplicationHelper
  include ValidationHelper

  before_validation :sanitize_input
  
  validates :name, presence: true, length: { minimum: 3, maximum: 100 }, uniqueness: true

  scope :recently_created, -> { order(created_at: :desc) }

  private

  def sanitize_input
    sanitize_from_xcs_and_url %w[name]
  end
end

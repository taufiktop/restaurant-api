class MenuItem < ApplicationRecord
  include ApplicationHelper
  include ValidationHelper

  belongs_to :restaurant
  belongs_to :category, optional: true

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :available, -> { where(is_available: true) }
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :recently_created, -> { order(created_at: :desc) }

  before_validation :sanitize_input

  searchkick

  def search_data
    {
      name: name,
      description: description,
      price: price,
      is_available: is_available,
      restaurant_id: restaurant_id,
      category_id: category_id,
      category_name: category&.name,
      created_at: created_at,
      updated_at: updated_at
    }
  end

  private

  def sanitize_input
    sanitize_from_xcs_and_url %w[name description]
  end
end

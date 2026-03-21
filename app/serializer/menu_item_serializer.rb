class MenuItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :price, :is_available, :category_id, :category_name, :created_at, :updated_at

  def category_name
    object.category&.name
  end
end
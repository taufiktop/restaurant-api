class RestaurantSerializer < ActiveModel::Serializer 
  attributes :id, :name, :address, :phone, :opening_hours, :closing_hours, :created_at, :updated_at
  
  has_many :menu_items, if: -> { @instance_options[:include_menu_items] }
end

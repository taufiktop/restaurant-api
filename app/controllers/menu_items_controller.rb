class MenuItemsController < ApplicationApiController
  include ApplicationHelper
  
  before_action :authenticate_user!
  before_action :set_restaurant, only: [:index, :create]
  before_action :set_menu_item, only: [:update, :destroy]

  # GET /restaurants/:restaurant_id/menu_items
  def index
    filters = { restaurant_id: @restaurant.id }
    filters[:category_id] = params[:category_id] if params[:category_id].present?

    # Determine if we are searching or just listing
    if params[:search].present?
      @menu_items = MenuItem.search(
        params[:search],
        where: filters,
        fields: [:name],
        order: { created_at: :desc }
      )
    else
      @menu_items = MenuItem.where(filters).recently_created
    end

    render_paginated_data_with_serializer(params[:page], params[:limit], @menu_items, MenuItemSerializer)
  end

  # POST /restaurants/:restaurant_id/menu_items
  def create
    @menu_item = @restaurant.menu_items.new(menu_item_params)
    if @menu_item.save
      render_success_process_with_data(201, 'Menu item created successfully', MenuItemSerializer.new(@menu_item))
    else
      render_custom_error(code = "RESTO-422", status = 422, message = @menu_item.errors.full_messages.join(", "))
    end
  end

  # PATCH/PUT /menu_items/:id
  def update
    if @menu_item.update(menu_item_params)
      render_success_process_with_data(200, 'Menu item updated successfully', MenuItemSerializer.new(@menu_item))
    else
      render_custom_error(code = "RESTO-422", status = 422, message = @menu_item.errors.full_messages.join(", "))
    end
  end

  # DELETE /menu_items/:id
  def destroy
    @menu_item.destroy
    render_success_process(200, "Menu item deleted successfully")
  end

  private
    def set_restaurant
      @restaurant = Restaurant.find(params[:restaurant_id])
    rescue ActiveRecord::RecordNotFound
      render_custom_error(code = "RESTO-404", status = 404, message = "Restaurant not found")
    end

    def set_menu_item
      @menu_item = MenuItem.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_custom_error(code = "RESTO-404", status = 404, message = "Menu item not found")
    end

    def menu_item_params
      params.require(:menu_item).permit(:name, :description, :price, :category_id, :is_available)
    end
end

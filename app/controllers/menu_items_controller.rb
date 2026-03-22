class MenuItemsController < ApplicationApiController
  before_action :authenticate_user!
  before_action :set_restaurant, only: [:index, :create]
  before_action :set_menu_item, only: [:update, :destroy]

  # GET /restaurants/:restaurant_id/menu_items
  def index
    @menu_items = @restaurant.menu_items
    @menu_items = @menu_items.by_category(params[:category_id]) if params[:category_id].present?

    data = @menu_items.recently_created
    render_paginated_data_with_serializer(params[:page], params[:limit], data, MenuItemSerializer)
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
      render json: { error: 'Restaurant not found' }, status: :not_found
    end

    def set_menu_item
      @menu_item = MenuItem.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Menu item not found' }, status: :not_found
    end

    def menu_item_params
      params.require(:menu_item).permit(:name, :description, :price, :category_id, :is_available)
    end
end
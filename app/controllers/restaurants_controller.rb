class RestaurantsController < ApplicationApiController
  include ApplicationHelper

  before_action :set_restaurant, only: [:show, :update, :destroy]

  # GET /restaurants
  def index
    data = Restaurant.all.recently_created
    render_paginated_data_with_serializer(params[:page], params[:limit], data, RestaurantSerializer)
  end

  # GET /restaurants/:id
  def show
    render_success_process_with_data(200, "Restaurant details retrieved successfully", RestaurantSerializer.new(@restaurant, include_menu_items: true))
  end

  # POST /restaurants
  def create
    @restaurant = Restaurant.new(restaurant_params)
    if @restaurant.save
      render_success_process_with_data(201, 'Restaurant created successfully', RestaurantSerializer.new(@restaurant))
    else
      render_custom_error(code = "RESTO-422", status = 422, message = @restaurant.errors.full_messages.join(", "))
    end
  end

  # PUT /restaurants/:id
  def update
    if @restaurant.update(restaurant_params)
      render_success_process_with_data(201, 'Restaurant updated successfully', RestaurantSerializer.new(@restaurant))
    else
      render_custom_error(code = "RESTO-422", status = 422, message = @restaurant.errors.full_messages.join(", "))
    end
  end

  # DELETE /restaurants/:id
  def destroy
    @restaurant.destroy
    if @restaurant.destroyed?
      render_success_process(200, "Restaurant deleted successfully")
    else
      render_custom_error(code = "RESTO-500", status = 500, message = "Failed to delete restaurant")
    end
  end

  private
    def set_restaurant
      @restaurant = Restaurant.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_custom_error(code = "RESTO-404", status = 404, message = "Restaurant not found")
    end

    def restaurant_params
      params.require(:restaurant).permit(:name, :address, :phone, :opening_hours, :closing_hours)
    end
end
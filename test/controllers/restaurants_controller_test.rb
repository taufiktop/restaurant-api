# test/controllers/restaurants_controller_test.rb
require "test_helper"

class RestaurantsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:super_admin)
    @headers = { 'Authorization' => "Bearer #{@user.access_token}" } if @user.respond_to?(:access_token)
    @restaurant = restaurants(:one)
    @valid_attributes = {
      name: "Test Restaurant",
      address: "123 Main St",
      phone: "123-456-7890",
      opening_hours: "09:00",
      closing_hours: "22:00"
    }
    @invalid_attributes = {
      name: nil,
      address: "123 Main St"
    }
  end

  test "should get index with pagination" do
    get restaurants_url, params: { page: 1, limit: 2 }, headers: @headers
    assert_response :success

    json = response.parsed_body
    assert_includes json, "data"
    assert_includes json, "meta"
  end

  test "should get index with search" do
    # Create a restaurant with a unique name
    restaurant = Restaurant.create!(name: "Special Burger Joint", address: "456 Oak St")

    # Reindex all restaurants (this creates the index if it doesn't exist)
    Restaurant.reindex
    Restaurant.search_index.refresh

    get restaurants_url, params: { search: "Burger", page: 1, limit: 10 }, headers: @headers
    assert_response :success
    json = response.parsed_body
    assert_equal 1, json['meta']['total']
    assert_equal restaurant.id, json['data'].first['id']

    # Clean up
    restaurant.destroy
    Restaurant.reindex          # optional, to keep index clean
    Restaurant.search_index.refresh
  end

  test "should return unauthorized when no token is provided" do
    # Tidak mengirim header Authorization
    get restaurants_url, params: { page: 1 }
    assert_response :unauthorized
    json = response.parsed_body
    assert_includes json['error']['message'], 'User unauthorized or token invalid'
  end

  test "should show restaurant" do
    get restaurant_url(@restaurant), headers: @headers
    assert_response :success
    json = response.parsed_body
    assert_equal @restaurant.id, json['data']['id']
  end

  test "should return 404 when restaurant not found" do
    get restaurant_url(id: -1), headers: @headers
    assert_response :not_found
    json = response.parsed_body
    assert_equal "RESTO-404", json['error']['code']
  end

  test "should create restaurant" do
    assert_difference('Restaurant.count', 1) do
      post restaurants_url, params: { restaurant: @valid_attributes }, headers: @headers
    end
    assert_response :created
    json = response.parsed_body
    assert_equal "Test Restaurant", json['data']['name']
  end

  test "should not create restaurant with invalid params" do
    assert_no_difference('Restaurant.count') do
      post restaurants_url, params: { restaurant: @invalid_attributes }, headers: @headers
    end
    assert_response :unprocessable_entity
    json = response.parsed_body
    assert_includes json['error']['message'], "Name can't be blank"
  end

  test "should update restaurant" do
    patch restaurant_url(@restaurant), params: { restaurant: { name: "Updated" } }, headers: @headers
    assert_response :success
    @restaurant.reload
    assert_equal "Updated", @restaurant.name
  end

  test "should not update restaurant with invalid params" do
    patch restaurant_url(@restaurant), params: { restaurant: { name: nil } }, headers: @headers
    assert_response :unprocessable_entity
    json = response.parsed_body
    assert_includes json['error']['message'], "Name can't be blank"
  end

  test "should destroy restaurant" do
    assert_difference('Restaurant.count', -1) do
      delete restaurant_url(@restaurant), headers: @headers
    end
    assert_response :ok
    json = response.parsed_body
    assert_equal "Restaurant deleted successfully", json['message']
  end

  test "should return 404 when deleting non-existent restaurant" do
    delete restaurant_url(id: -1), headers: @headers
    assert_response :not_found
    json = response.parsed_body
    assert_equal "RESTO-404", json['error']['code']
  end
end

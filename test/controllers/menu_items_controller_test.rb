# test/controllers/menu_items_controller_test.rb
require "test_helper"

class MenuItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:super_admin)
    @headers = { 'Authorization' => "Bearer #{@user.access_token}" }

    @restaurant = restaurants(:one)
    @category = categories(:appetizer)
    @menu_item = menu_items(:nasi_goreng)

    @valid_attributes = {
      name: "New Item",
      description: "Delicious",
      price: 25000,
      category_id: @category.id,
      is_available: true
    }
    @invalid_attributes = {
      name: nil,
      price: 0
    }
  end

  # ========== INDEX ==========
  test "should get index without search" do
    get restaurant_menu_items_url(@restaurant), headers: @headers
    assert_response :success
    json = response.parsed_body
    assert_includes json, "data"
    assert_includes json, "meta"
    assert json['data'].any? { |item| item['id'] == @menu_item.id }
  end

  test "should filter by category" do
    get restaurant_menu_items_url(@restaurant), params: { category_id: @category.id }, headers: @headers
    assert_response :success
    json = response.parsed_body
    assert json['data'].all? { |item| item['category_id'] == @category.id }
  end

  test "should search by name" do
    # Create a temporary menu item with a unique name
    special_item = @restaurant.menu_items.create!(
      name: "Special Burger",
      description: "Tasty",
      price: 35000,
      category: @category
    )

    # Reindex all menu items (this creates the index if it doesn't exist)
    MenuItem.reindex
    MenuItem.search_index.refresh

    get restaurant_menu_items_url(@restaurant), params: { search: "Burger" }, headers: @headers
    assert_response :success
    json = response.parsed_body
    assert_equal 1, json['meta']['total']
    assert_equal special_item.id, json['data'].first['id']

    # Clean up
    special_item.destroy
    MenuItem.reindex   # optional: clean up index
    MenuItem.search_index.refresh
  end

  test "should return unauthorized when no token is provided" do
    # Tidak mengirim header Authorization
    get restaurant_menu_items_url(@restaurant), params: { page: 1 }
    assert_response :unauthorized
    json = response.parsed_body
    assert_includes json['error']['message'], 'User unauthorized or token invalid'
  end

  # ========== CREATE ==========
  test "should create menu item with valid attributes" do
    assert_difference('MenuItem.count', 1) do
      post restaurant_menu_items_url(@restaurant), params: { menu_item: @valid_attributes }, headers: @headers
    end
    assert_response :created
    json = response.parsed_body
    assert_equal "New Item", json['data']['name']
    assert_equal @category.id, json['data']['category_id']
  end

  test "should not create menu item with invalid attributes" do
    assert_no_difference('MenuItem.count') do
      post restaurant_menu_items_url(@restaurant), params: { menu_item: @invalid_attributes }, headers: @headers
    end
    assert_response :unprocessable_entity
    json = response.parsed_body
    assert_includes json['error']['message'], "Name can't be blank"
  end

  test "should return 404 when creating for non-existent restaurant" do
    post restaurant_menu_items_url(999999), params: { menu_item: @valid_attributes }, headers: @headers
    assert_response :not_found
    json = response.parsed_body
    assert_includes json['error']['message'], 'Restaurant not found'
  end

  # ========== UPDATE ==========
  test "should update menu item with valid attributes" do
    patch menu_item_url(@menu_item), params: { menu_item: { name: "Updated Name", price: 40000 } }, headers: @headers
    assert_response :success
    json = response.parsed_body
    assert_equal "Updated Name", json['data']['name']
    assert_equal 40000.0, json['data']['price'].to_f
    @menu_item.reload
    assert_equal "Updated Name", @menu_item.name
  end

  test "should not update menu item with invalid attributes" do
    patch menu_item_url(@menu_item), params: { menu_item: { name: nil } }, headers: @headers
    assert_response :unprocessable_entity
    json = response.parsed_body
    assert_includes json['error']['message'], "Name can't be blank"
  end

  test "should return 404 when updating non-existent menu item" do
    patch menu_item_url(999999), params: { menu_item: { name: "New" } }, headers: @headers
    assert_response :not_found
    json = response.parsed_body
    assert_includes json['error']['message'], 'Menu item not found'
  end

  # ========== DESTROY ==========
  test "should destroy menu item" do
    assert_difference('MenuItem.count', -1) do
      delete menu_item_url(@menu_item), headers: @headers
    end
    assert_response :ok
    json = response.parsed_body
    assert_equal "Menu item deleted successfully", json['message']
  end

  test "should return 404 when destroying non-existent menu item" do
    delete menu_item_url(999999), headers: @headers
    assert_response :not_found
    json = response.parsed_body
    assert_includes json['error']['message'], 'Menu item not found'
  end
end

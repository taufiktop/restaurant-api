# test/controllers/users_controller_test.rb
require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:super_admin)
    @password = 'password123'
  end

  test "should sign in with valid credentials" do
    post '/users/signin', params: { email: @user.email, password: @password }
    assert_response :success
    json = response.parsed_body
    assert_equal 200, json['meta']['status']
    assert_equal "User signed in successfully", json['message']
    assert_includes json['data'], 'access_token'
    assert_equal @user.email, json['data']['email']
  end

  test "should not sign in with invalid email" do
    post '/users/signin', params: { email: 'wrong@example.com', password: @password }
    assert_response :unauthorized
    json = response.parsed_body
    assert_equal 401, json['error']['status']
    assert_includes json['error']['message'], 'Wrong email or password'
  end

  test "should not sign in with invalid password" do
    post '/users/signin', params: { email: @user.email, password: 'wrongpassword' }
    assert_response :unauthorized
    json = response.parsed_body
    assert_equal 401, json['error']['status']
    assert_includes json['error']['message'], 'Wrong email or password'
  end

  test "should require email and password" do
    post '/users/signin', params: { email: @user.email }
    assert_response :bad_request
    json = response.parsed_body
    assert_equal 400, json['error']['status']
    assert_includes json['error']['message'], 'Missing required parameters: email and password'
  end
end

class UsersController < ApplicationApiController
  include ApplicationHelper

  def signin
    unless permitted_params[:email].present? && permitted_params[:password].present?
      return render_custom_error(code = "RESTO-400", status = 400, message = "Missing required parameters: email and password")
    end

    user = User.signin(permitted_params[:email])

    if user.present? && user.authenticate?(permitted_params[:password])
      render_success_process_with_data(200, "User signed in successfully", UserSerializer.new(user, access_token: user.access_token))
    else
      render_failed_login(permitted_params.reject{|k| k == "password"})
    end
  end

  private

  def permitted_params
    params.permit(:email, :name, :password)
  end
end

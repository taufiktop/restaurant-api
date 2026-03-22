class UsersController < ApplicationApiController
  def signin
    user = User.signin(permitted_params[:email])

    if user.present? && user.authenticate?(permitted_params[:password])
      render_success_process_with_data(200, "User signed in successfully", UserSerializer.new(user, access_token: user.access_token))
    else
      render_failed_login(permitted_params.reject{|k| k == "password"})
    end
  end

  private

   def permitted_params
      params.permit(:email, :name, :password, :phone_number)
    end
end

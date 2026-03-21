class User < ApplicationRecord
  include ApplicationHelper
  include ValidationHelper

  validates :phone_number, uniqueness: true

  def access_token
    secret = Rails.application.credentials.jwt[:secret_key]
    method = Rails.application.credentials.jwt[:algorithm]
    payload = {
      data: {email: email, name: name, phone_number: phone_number},
      iat: Time.now.to_i,
      sub: Rails.application.credentials.jwt[:subject]
    }

    JWT.encode(payload, secret, method)
  end

  def authenticate?(text)
    password = BCrypt::Password.new(encrypted_password)
    password == text
  end

  private

  def sanitize_input
    sanitize_from_xcs_and_url %w[name]
  end
end

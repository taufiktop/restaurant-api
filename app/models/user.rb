class User < ApplicationRecord
  include ApplicationHelper
  include ValidationHelper

  validates :email, uniqueness: true

  def access_token
    secret = Rails.application.credentials.jwt[:secret_key]
    method = Rails.application.credentials.jwt[:algorithm]
    payload = {
      data: {email: email, name: name},
      iat: Time.now.to_i,
      sub: Rails.application.credentials.jwt[:subject]
    }

    JWT.encode(payload, secret, method)
  end

  def authenticate?(text)
    password = BCrypt::Password.new(encrypted_password)
    password == text
  end

  def self.signin(email_or_phone)
    if email_or_phone.match?(/(|\+)\d{9,12}/)
      t = TelephoneNumber.parse(email_or_phone, :id)
      User.find_by(phone_number: t.normalized_number)
    else
     User.find_by(email: email_or_phone)
    end
  end

  private

  def sanitize_input
    sanitize_from_xcs_and_url %w[name]
  end
end

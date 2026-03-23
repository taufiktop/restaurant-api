class ApplicationApiController < ActionController::API
  include ActionController::MimeResponds
  # include ActiveStorage::SetCurrent
  helper ApplicationHelper
  rescue_from StandardError, with: :handle_internal_server_error

  # before_action :cors_set_access_control_headers
  # around_action :switch_locale

  # respond_to :json

  def render_unauthorized(resource_or_params)
    render status: :unauthorized, json: {
      error: {
        code: "RESTO-401",
        status: 401,
        message: "User unauthorized or token invalid"
      }
    }
  end

  def render_failed_login(resource_or_params)
    render status: :unauthorized, json: {
      error: {
        code: "RESTO-401",
        status: 401,
        message: "Wrong email or password"
      }
    }
  end

  def render_custom_error(code = "RESTO-001", status = 500, message = I18n.t("errors.RESTO-001"))
    render status: status, json: {
      error: {
        code: code,
        status: status,
        message: truncated_message(message)
      }
    }
  end

  def render_success_process(status = 200, message = "Success")
    render status: status, json: {
      message: message,
      meta: {
        status: status,
        error: false
      }
    }
  end

  def render_success_process_with_data(status = 200, message = "Success", data = {})
    render status: status, json: {
      message: message,
      meta: {
        status: status,
        error: false
      },
      data: data
    }
  end

  def render_paginated_data_with_serializer(page, limit, data, serializer, **options)
    page = page.to_i > 0 ? page.to_i : 1
    limit = [ (limit.to_i > 0 ? limit.to_i : 12), 50 ].min
    paginated_data = data.page(page).per(limit)

    meta = {
      page: page,
      limit: limit,
      has_previous_page: paginated_data.prev_page.present?,
      has_next_page: paginated_data.next_page.present?,
      total: paginated_data.total_count
    }
    serialized_data = ActiveModelSerializers::SerializableResource.new(
      paginated_data,
      each_serializer: serializer,
      **options
    )

    render json: { data: serialized_data, meta: meta }
  end

  def cors_preflight_check
    if request.method == "OPTIONS"
      cors_set_access_control_headers
      render json: {}, content_type: "text/plain"
    end

    render text: "", content_type: "text/plain" && return
  end

  protected

  def switch_locale(&action)
    locale = request.headers["Accept-Language"] || I18n.default_locale
    locale = I18n.default_locale unless I18n.locale_available?(locale)
    I18n.with_locale(locale, &action)
  end

  def cors_set_access_control_headers
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "POST, GET, PUT, PATCH, DELETE, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Origin, Content-Type, Accept, Authorization, Token, Auth-Token, Email, X-User-Token, X-User-Email"
    response.headers["Access-Control-Max-Age"] = "1728000"
  end

  def authenticate_user!
    token = get_bearer_token
    if token.blank?
      render_unauthorized({}) && return
    else
      user = get_user(token)
      # sign_in(user) if using Devise or similar authentication system
    end
  end

  def authenticate_user_without_render!
    token = get_bearer_token
    if token.blank?
      false
    else
      user = get_user(token)
      # sign_in(user) if using Devise or similar authentication system
    end
  end

  private

  def sanitize_options(options)
    if options.is_a?(Hash)
      options.reject! do |k|
        if k.is_a?(String)
          k.include?("password")
        else
          k == :password || k == :password_confirmation
        end
      end
    else
      options
    end
  end

  def get_bearer_token
    pattern = /^Bearer/
    header = request.authorization
    header = request.env["Authorization"] if header.blank?
    header.gsub(pattern, "").strip if header && header.match(pattern)
  end

  def get_user(token)
    secret = Rails.application.credentials.jwt[:secret_key]
    method = Rails.application.credentials.jwt[:algorithm]

    begin
      raw = JWT.decode(token, secret, true, { algorithm: method })[0]
      data = raw["data"]

      Rails.cache.fetch("user_with_email:#{data['email']}/logged_in", expires_in: 10.minutes) do
        User.find_by(email: data["email"])
      end
    rescue JWT::VerificationError => e
    puts e
      render_unauthorized({})
    end
  end

  def handle_internal_server_error(exception)
    log_error(exception)
    render status: :internal_server_error, json: {
      error: {
        code: "RESTO-001",
        status: 500,
        message: truncated_message(exception.message)
      }
    }
  end

  def log_error(exception)
    logger.error "Error: #{truncated_message(exception.message)}"
    logger.error "Backtrace:"
    logger.error truncated_backtrace(exception.backtrace).join("\n")
  end

  def truncated_message(message, length = 200)
    message.length > length ? message[0...length] + "..." : message
  end

  def truncated_backtrace(backtrace, lines = 5)
    backtrace[0...lines]
  end
end

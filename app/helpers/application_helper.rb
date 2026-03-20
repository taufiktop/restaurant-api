module ApplicationHelper
  def number_format(amount)
    number_to_currency(amount.to_i, separator: ",", delimiter: ".", unit: "Rp ")
  end

  def price_without_currency(amount)
    number_to_currency(amount.to_i, separator: ",", delimiter: ".", unit: "")
  end

  def format_daydatetime(date)
    I18n.default_locale = :id
    I18n.l(date, format: :full) if date.present?
  end

  def format_datetime(date)
    date.strftime("%A, %d %B %Y %H:%M") if date.present?
  end

  def format_american_date(date)
    I18n.default_locale = :id
    I18n.l(date, format: :american) if date.present?
  end

  def format_date(date)
    date.strftime("%d %B %Y") if date.present?
  end

  def format_am_pm_time(date)
    I18n.default_locale = :id
    I18n.l(date, format: :am_pm) if date.present?
  end

  def active_text(status)
    status ? "Active" : "Inactive"
  end

  def valid_base64_image?(base64_string)
    begin
      # Remove the data URL prefix if present
      if base64_string.start_with?("data:image")
        base64_string = base64_string.split(",")[1]
      end

      # Check if the string is valid base64
      unless base64_string.match?(/\A([A-Za-z0-9+\/]{4})*([A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=)?\z/)
        return false
      end

      decoded_data = Base64.decode64(base64_string)
      image = MiniMagick::Image.read(decoded_data)

      # Ensure the image is valid and contains a valid format
      valid_formats = %w[jpg jpeg png gif heif heic]
      image.valid? && valid_formats.include?(image.type.downcase)
    rescue StandardError
      false
    end
  end

  def valid_base64_image_keyword?(image)
    image.start_with?("data:image")
  end

  def valid_image_url?(url)
    URI.parse(url).open.content_type.start_with?("image")
  end

  def to_boolean(value)
    ActiveModel::Type::Boolean.new.cast(value)
  end

  def to_integer_array(array)
    array.map { |id| id.to_i } rescue []
  end

  def formatted_telephone_number(phone)
    TelephoneNumber.parse(phone, :id).international_number if phone.present?
  end

  def valid_file_photo?(photo)
    begin
      valid_formats = [ "image/jpeg", "image/png", "image/heic", "image/heif" ]
      valid_formats.include?(photo.content_type)
    rescue StandardError
      false
    end
  end

  def valid_file_video?(video)
    begin
      valid_formats = [ "video/mp4", "video/x-matroska", "video/quicktime", "video/3gpp", "video/hevc" ]
      valid_formats.include?(video.content_type)
    rescue StandardError
      false
    end
  end

  def get_video_duration(video)
    movie = FFMPEG::Movie.new(video.path)
    movie.duration.to_i
  rescue => e
    0
  end

  def sanitize_params(*fields)
    sanitized_params = params.permit(*fields)
      .transform_values { |v| v.strip rescue v }
      .to_h

    if (key, value = sanitized_params.find { |_k, v| xss_detected?(v) })
      return { error: key }
    end

    sanitized_params
  end

  def xss_detected?(input)
    input.is_a?(String) && input.match?(/<\s*(script|img|iframe|object|embed|form|on\w+)\b/i)
  end

  def formatted_file_size(file)
    size = file.byte_size
    if size >= 1.megabyte
      "#{(size.to_f / 1.megabyte).round(2)} MB"
    elsif size >= 1.kilobyte
      "#{(size.to_f / 1.kilobyte).round(2)} KB"
    else
      "#{size} Bytes"
    end
  rescue => e
    "0 Bytes"
  end
end

# frozen_string_literal: true

module ValidationHelper
  extend ActiveSupport::Concern

  included do
    def sanitize_from_xcs_and_url fields
      fields.each do |field|
        if self[field].present?
          self.errors.add(field, :invalid) if self[field].match(/(http|https|javascript|xcs|xss|<|>)/)
        end
      end
    end

    def sanitize_meta_field_from_xcs_and_url fields
      fields.each do |field|
        I18n.available_locales.each do |locale|
          if send(:"#{field}_#{locale}")&.match(/(http|https|javascript|xcs|xss|<|>)/)
            errors.add(:"#{field.gsub('meta_', '')}_#{locale.to_s}", "is invalid")
          end
        end
      end
    end
  end
end

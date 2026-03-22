class UserSerializer < ActiveModel::Serializer
  include ActionView::Helpers::AssetTagHelper

  attributes :id, :name, :email, :created_at, :updated_at

  attribute :access_token, if: -> { instance_options[:access_token].present? }

  def access_token
    if instance_options[:access_token]
      object.access_token
    end
  end
  
end

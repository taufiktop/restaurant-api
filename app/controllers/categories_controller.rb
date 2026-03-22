class CategoriesController < ApplicationApiController
  before_action :authenticate_user!
end

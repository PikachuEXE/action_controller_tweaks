class TestController < ActionController::Base
  include Rails.application.routes.url_helpers

  def render(*_attributes); end
end

class PostsController < TestController
  include ActionControllerTweaks

  def index
    set_no_cache if params[:no_cache]
  end
end

class NotController
end

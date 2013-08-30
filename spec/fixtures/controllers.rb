class TestController < ActionController::Base
  include Rails.application.routes.url_helpers

  def render(*attributes); end
end

class PostsController < TestController
  include ActionControllerTweaks

  def index
    if params[:no_cache]
      set_no_cache
    end
  end

end
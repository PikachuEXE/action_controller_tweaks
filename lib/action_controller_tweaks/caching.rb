require 'active_support/concern'

module ActionControllerTweaks
  module Caching
    extend ActiveSupport::Concern

    HEADERS = {
      "Cache-Control" => "no-cache, no-store, max-age=0, must-revalidate, pre-check=0, post-check=0", # HTTP 1.1
      "Pragma" => "no-cache", # HTTP 1.0
      "Expires" => "Fri, 01 Jan 1990 00:00:00 GMT", # HTTP 1.0
    }.freeze

    included do
      private

      # Should be more powerful than #expire_now
      def set_no_cache
        HEADERS.each do |key, value|
          response.headers[key] = value
        end
      end
    end
  end
end

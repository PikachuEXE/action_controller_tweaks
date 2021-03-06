require "active_support/concern"

module ActionControllerTweaks
  module Caching
    extend ActiveSupport::Concern

    HEADERS = {
      # HTTP 1.1
      "Cache-Control" => "no-cache, no-store, pre-check=0, post-check=0",
      # HTTP 1.0
      "Pragma"        => "no-cache",
      # HTTP 1.0
      "Expires"       => "Mon, 01 Jan 1990 00:00:00 GMT",
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

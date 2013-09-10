require 'active_support/concern'
require 'active_support/time'

module ActionControllerTweaks
  module Session
    extend ActiveSupport::Concern

    SPECIAL_KEYS = %w( session_keys_to_expire )

    included do
      before_filter :delete_expired_session_keys

      private

      def set_session(key, value, options = {})
        key = key.to_sym

        if SPECIAL_KEYS.include?(key.to_s)
          return
        end

        session[key] = value

        # Set special session
        new_session_keys_to_expire = session_keys_to_expire

        expire_in = options.delete(:expire_in)
        if expire_in && expire_in.is_a?(Integer) # Time period
          new_session_keys_to_expire[key] = expire_in.from_now
        end

        session[:session_keys_to_expire] = new_session_keys_to_expire
      end

      def delete_expired_session_keys
        # Remove keys that are expired
        session_keys_to_expire.each do |key, expire_at_str|
          begin
            if Time.now > Time.parse(expire_at_str.to_s)
              session.delete(key)
              session_keys_to_expire.delete(key)
            end
          rescue ArgumentError 
            # Parse error
            # Let's expire it to be safe
            session.delete(key)
            session_keys_to_expire.delete(key)
          end
        end
      end

      def session_keys_to_expire
        # Check whether session key is a hash to prevent exception
        unless session[:session_keys_to_expire].is_a?(Hash)
          session[:session_keys_to_expire] = {}
        end

        session[:session_keys_to_expire]
      end
    end
  end
end

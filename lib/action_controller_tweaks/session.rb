require 'active_support/concern'
require 'active_support/time'

module ActionControllerTweaks
  module Session
    extend ActiveSupport::Concern

    SPECIAL_KEYS = %w( session_keys_to_expire )

    class InvalidOptionValue < ArgumentError
      def self.new(option_key, options_value, expected_types)
        super("option key `#{option_key}` should contain value with type(s): #{expected_types}, " +
          "but got <#{options_value.inspect}> (#{options_value.class})")
      end
    end

    included do
      before_filter :delete_expired_session_keys

      private

      def set_session(key, value, options = {})
        options.symbolize_keys!

        key = key.to_sym

        if SPECIAL_KEYS.include?(key.to_s)
          return
        end

        session[key] = value

        # Set special session
        new_session_keys_to_expire = session_keys_to_expire

        expires_in = options.delete(:expires_in) || options.delete(:expire_in)
        expires_at = options.delete(:expires_at) || options.delete(:expire_at)

        if expires_at && expires_at.respond_to?(:to_time)
          expires_at = expires_at.to_time
        end

        raise InvalidOptionValue.new(:expires_in, expires_in, Numeric) if expires_in && !expires_in.is_a?(Numeric)
        raise InvalidOptionValue.new(:expires_at, expires_at, Time) if expires_at && !expires_at.is_a?(Time)

        new_session_keys_to_expire[key] = if expires_in
          expires_in.from_now
        elsif expires_at
          expires_at
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
          rescue
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

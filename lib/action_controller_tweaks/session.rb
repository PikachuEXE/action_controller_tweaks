require 'active_support/concern'
require 'active_support/time'

module ActionControllerTweaks
  module Session
    extend ActiveSupport::Concern

    module Errors
      InvalidOptionKeys = Class.new(ArgumentError)
      ReservedSessionKeyConflict = Class.new(ArgumentError)
    end

    RESERVED_SESSION_KEYS = %w( session_keys_to_expire )
    VALID_OPTION_KEYS = [
      :expires_in,
      :expires_at,
      :expire_in,
      :expire_at,
    ].freeze

    class InvalidOptionValue < ArgumentError
      def self.new(option_key, options_value, expected_types)
        super("option key `#{option_key}` should contain value with type(s): #{expected_types}, " +
          "but got <#{options_value.inspect}> (#{options_value.class})")
      end
    end

    included do
      before_filter :delete_expired_session_keys

      private

      # Set session just like `session[key] = value` but accept some options about expiry
      #
      # @option expires_in [Integer] How long from now should the session value be expired
      # @option expire_in [Integer] same as `expires_in`
      # @option expires_at [Integer] What time should the session value be expired (using a time in the past would expire at next request)
      # @option expire_at [Integer] same as `expires_at`
      def set_session(key, value, options = {})
        if RESERVED_SESSION_KEYS.include?(key.to_s)
          raise Errors::ReservedSessionKeyConflict.new, "you are trying to set #{value} to #{key}, but reserved by ActionControllerTweaks::Session"
        end

        session[key] = value

        session[:session_keys_to_expire] = new_session_keys_to_expire(key, options)
      end

      # set value in session just like `set_session`, but checked option keys
      #
      # @raise [ActionControllerTweaks::Session::Errors::InvalidOptionKeys]
      def set_session_with_expiry(key, value, options = {})
        option_keys = options.symbolize_keys.keys
        required_option_key_present = option_keys.any? do |key|
          VALID_OPTION_KEYS.include?(key)
        end
        invalid_option_key_absent = (option_keys - VALID_OPTION_KEYS.dup).empty?
        (required_option_key_present && invalid_option_key_absent) or raise ActionControllerTweaks::Session::Errors::InvalidOptionKeys

        set_session(key, value, options = {})
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

      def new_session_keys_to_expire(key, options = {})
        options.symbolize_keys!

        result = session_keys_to_expire

        expires_in = options.delete(:expires_in) || options.delete(:expire_in)
        expires_at = options.delete(:expires_at) || options.delete(:expire_at)

        if expires_at && expires_at.respond_to?(:to_time)
          expires_at = expires_at.to_time
        end

        raise InvalidOptionValue.new(:expires_in, expires_in, Numeric) if expires_in && !expires_in.is_a?(Numeric)
        raise InvalidOptionValue.new(:expires_at, expires_at, Time) if expires_at && !expires_at.is_a?(Time)

        result[key] = if expires_in
          expires_in.from_now
        elsif expires_at
          expires_at
        end

        result
      end
    end
  end
end

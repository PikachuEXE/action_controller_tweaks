require 'active_support/concern'

require 'action_controller_tweaks/version'
require 'action_controller_tweaks/caching'
require 'action_controller_tweaks/session'

module ActionControllerTweaks
  extend ActiveSupport::Concern

  included do
    include Caching
    include Session
  end
end

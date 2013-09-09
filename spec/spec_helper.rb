if ENV["TRAVIS"]
  require 'coveralls'
  Coveralls.wear!('rails')
end

require 'action_controller_tweaks'

require 'fixtures/application'
require 'fixtures/controllers'
require 'rspec/rails'

require 'timecop'
require 'logger'


# For comparison
class Hash
  def deep_include?(sub_hash)
    sub_hash.keys.all? do |key|
      self.has_key?(key) && if sub_hash[key].is_a?(Hash)
        self[key].is_a?(Hash) && self[key].deep_include?(sub_hash[key])
      else
        self[key] == sub_hash[key]
      end
    end
  end
end

RSpec.configure do |config|
end

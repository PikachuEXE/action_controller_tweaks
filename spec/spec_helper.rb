# frozen_string_literal: true

if ENV["COVERALLS"]
  require "simplecov"
  require "simplecov-lcov"

  SimpleCov::Formatter::LcovFormatter.config do |c|
    c.report_with_single_file = true
    c.single_report_path = "coverage/lcov.info"
  end

  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(
    [SimpleCov::Formatter::HTMLFormatter, SimpleCov::Formatter::LcovFormatter]
  )

  SimpleCov.start do
    add_filter "spec/"
  end
end

require "action_controller_tweaks"

require "fixtures/application"
require "fixtures/controllers"

require "rspec/rails"
require "rspec/its"

require "timecop"
require "logger"

# see https://github.com/rspec/rspec-rails/issues/1171
# prevent Test::Unit"s AutoRunner from executing during RSpec"s rake task
Test::Unit.run = true if defined?(Test::Unit) && Test::Unit.respond_to?(:run=)

# For comparison
class Hash
  def deep_include?(sub_hash)
    sub_hash.keys.all? do |key|
      next unless self.key?(key)

      if sub_hash[key].is_a?(Hash)
        self[key].is_a?(Hash) && self[key].deep_include?(sub_hash[key])
      else
        self[key] == sub_hash[key]
      end
    end
  end
end

RSpec.configure do
end


# Monkey patch for rails 4.2 + ruby 2.6
# https://github.com/rails/rails/issues/34790
if RUBY_VERSION>='2.6.0'
  if Rails.version < '5'
    class ActionController::TestResponse < ActionDispatch::TestResponse
      def recycle!
        # hack to avoid MonitorMixin double-initialize error:
        @mon_mutex_owner_object_id = nil
        @mon_mutex = nil
        initialize
      end
    end
  else
    puts "Monkeypatch for ActionController::TestResponse no longer needed"
  end
end

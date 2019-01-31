require 'bundler/setup'
require 'rung'

# RSpec.configure do |config|
# end

Dir[File.join File.dirname(__FILE__), 'support', '**', '*.rb']
  .each { |f| require_relative f }

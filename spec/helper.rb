# frozen_string_literal: true

require 'rubygems'
require 'bundler'

require 'simplecov'

SimpleCov.start do
  enable_coverage :branch
  # fail CI if any line or branch goes uncovered; skipped locally so single spec files can run
  minimum_coverage line: 100, branch: 100 if ENV['CI']

  cover 'lib/**/*.rb'
  # loaded by the gemspec before SimpleCov starts, so it would always show as missed
  skip 'lib/inheritance-helper/version.rb'
end

begin
  Bundler.setup(:default, :development, :spec)
rescue Bundler::BundlerError => e
  warn e.message
  warn 'Run `bundle install` to install missing gems'
  exit e.status_code
end

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
$LOAD_PATH.unshift(__dir__)
require 'inheritance-helper'

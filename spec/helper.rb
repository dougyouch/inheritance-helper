# frozen_string_literal: true

require 'rubygems'
require 'bundler'
require 'simplecov'

SimpleCov.start

begin
  Bundler.setup(:default, :development, :spec)
rescue Bundler::BundlerError => e
  warn e.message
  warn 'Run `bundle install` to install missing gems'
  exit e.status_code
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'inheritance-helper'

# frozen_string_literal: true

require_relative 'lib/inheritance-helper/version'

Gem::Specification.new do |s|
  s.name        = 'inheritance-helper'
  s.version     = InheritanceHelper::VERSION
  s.licenses    = ['MIT']
  s.summary     = 'Class-level settings that subclasses can extend without changing their parents'
  s.description = 'Redefine a class method on a subclass to return a new value, so hashes, arrays and sets ' \
                  'declared on a parent class can be added to by each subclass while the parent keeps its own ' \
                  'copy. Built for DSLs that collect attributes, options or callbacks at the class level. Also ' \
                  'includes a helper for creating named classes inside a module.'
  s.authors     = ['Doug Youch']
  s.email       = 'dougyouch@gmail.com'
  s.homepage    = 'https://github.com/dougyouch/inheritance-helper'
  s.files       = Dir['lib/**/*.rb', 'README.md', 'LICENSE.txt', 'CHANGELOG.md']
  s.required_ruby_version = '>= 3.3'

  s.metadata['rubygems_mfa_required'] = 'true'
  s.metadata['source_code_uri'] = 'https://github.com/dougyouch/inheritance-helper'
  s.metadata['changelog_uri'] = 'https://github.com/dougyouch/inheritance-helper/blob/master/CHANGELOG.md'
  s.metadata['bug_tracker_uri'] = 'https://github.com/dougyouch/inheritance-helper/issues'
  s.metadata['documentation_uri'] = 'https://rubydoc.info/gems/inheritance-helper'
end

# frozen_string_literal: true

require_relative 'inheritance-helper/version'

# Helpers for class-level values that subclasses can extend without changing their parent classes.
module InheritanceHelper
  autoload :Methods, 'inheritance-helper/methods'

  # Helpers for creating classes at runtime.
  module ClassBuilder
    autoload :Utils, 'inheritance-helper/class_builder/utils'
  end
end

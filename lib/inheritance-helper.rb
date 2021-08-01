# frozen_string_literal: true

# A set of utility classes for making inheritance work with class level variables
module InheritanceHelper
  autoload :Methods, 'inheritance-helper/methods'

  module ClassBuilder
    autoload :Utils, 'inheritance-helper/class_builder/utils'
  end
end

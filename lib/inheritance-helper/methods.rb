# frozen_string_literal: true

module InheritanceHelper
  module Methods
    def self.redefine_class_method(klass, method, value)
      class << klass; self; end.send(:define_method, method) { value }
      klass
    end

    def redefine_class_method(method, value)
      ::InheritanceHelper::Methods.redefine_class_method(self, method, value)
    end

    def add_value_to_class_method(method, value)
      old_value = send(method)

      new_value =
        case old_value
        when Hash
          old_value.merge(value)
        else
          old_value + Array(value)
        end

      redefine_class_method(method, old_value.frozen? ? new_value.freeze : new_value)
    end
  end
end

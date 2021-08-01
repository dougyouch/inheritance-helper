# frozen_string_literal: true

module InheritanceHelper
  # Utility methods for building dynamic classes
  module ClassBuilder
    module Utils
      module_function

      def get_class_name(name, preffix_class_name, postfix_class_name)
        name = name.to_s

        class_name =
          if name.respond_to?(:classify)
            name.classify
          else
            # simple naive method to convert a string to a class name
            name.gsub(/(^.|_.)/) { |_| ($1[1] || $1[0]).upcase }
          end

        preffix_class_name.to_s + class_name + postfix_class_name.to_s
      end

      # Purpose to create a class that is under a module with an actual class name
      def create_class(base_module, name, base_class, preffix_class_name, postfix_class_name, &block)
        class_name = get_class_name(name, preffix_class_name, postfix_class_name)
        kls = base_class ? Class.new(base_class) : Class.new
        base_module.const_set(class_name, kls)
        kls = base_module.const_get(class_name)
        kls.class_eval(&block) if block
        kls
      end
    end
  end
end

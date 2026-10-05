# frozen_string_literal: true

module InheritanceHelper
  module ClassBuilder
    # Functions for creating named classes inside a module.
    #
    # @example
    #   InheritanceHelper::ClassBuilder::Utils.create_class(MyApp, :line_item, Struct.new(:id), 'Schema', nil)
    #   # => MyApp::SchemaLineItem
    module Utils
      module_function

      # Builds a class name from `name` with an optional prefix and suffix.
      #
      # `name` is split on underscores and the first letter of each part is capitalized. The result doesn't depend
      # on whether ActiveSupport is loaded, and the name isn't singularized (`:line_items` gives `"LineItems"`).
      #
      # @param name [String, Symbol] the base name, such as `:line_item`
      # @param prefix_class_name [String, nil] text to put before the converted name
      # @param suffix_class_name [String, nil] text to put after the converted name
      # @return [String] the class name, such as `"SchemaLineItem"`
      # @example
      #   get_class_name(:line_item, 'Schema', 'Class') # => "SchemaLineItemClass"
      def get_class_name(name, prefix_class_name, suffix_class_name)
        class_name = name.to_s.split('_').map { |part| part.sub(/\A./, &:upcase) }.join
        "#{prefix_class_name}#{class_name}#{suffix_class_name}"
      end

      # Creates a class and assigns it to a constant in `base_module`, which gives the class a name.
      #
      # If the constant already exists it is replaced, and Ruby prints an "already initialized constant"
      # warning.
      #
      # @param base_module [Module] the module the class is defined in
      # @param name [String, Symbol] the base name, converted with {get_class_name}
      # @param base_class [Class, nil] the superclass, or `nil` for `Object`
      # @param prefix_class_name [String, nil] text to put before the converted name
      # @param suffix_class_name [String, nil] text to put after the converted name
      # @yield evaluated in the new class with `class_eval`, to define its methods
      # @return [Class] the new class
      # @raise [NameError] if the resulting name isn't a valid constant name
      def create_class(base_module, name, base_class, prefix_class_name, suffix_class_name, &block)
        class_name = get_class_name(name, prefix_class_name, suffix_class_name)
        kls = Class.new(base_class || Object)
        base_module.const_set(class_name, kls)
        kls.class_eval(&block) if block
        kls
      end
    end
  end
end

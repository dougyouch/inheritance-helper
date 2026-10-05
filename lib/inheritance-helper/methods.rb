# frozen_string_literal: true

module InheritanceHelper
  # Class methods for redefining class methods on a subclass.
  #
  # Extend a class with this module. A class method on that class, or on any subclass, can then be replaced
  # with one that returns a new value. The new method is defined on the receiving class's singleton class,
  # so the parent class keeps its own method and value.
  #
  # @example Collect attributes across an inheritance chain
  #   class Model
  #     extend InheritanceHelper::Methods
  #
  #     def self.attributes
  #       {}.freeze
  #     end
  #
  #     def self.attribute(name, type)
  #       add_value_to_class_method(:attributes, name => type)
  #     end
  #   end
  #
  #   class Person < Model
  #     attribute :name, :string
  #   end
  #
  #   Person.attributes # => {name: :string}
  #   Model.attributes  # => {}
  module Methods
    # Defines (or replaces) the class method `method` on `klass` so that it returns `value`.
    #
    # The new method keeps the visibility of the method it replaces, so a private class method stays private.
    #
    # @param klass [Module] the class or module to define the method on
    # @param method [Symbol, String] name of the class method
    # @param value [Object] the value the method returns. The same object is returned on every call, so
    #   freeze it if callers shouldn't change it
    # @return [Module] `klass`
    def self.redefine_class_method(klass, method, value)
      singleton = klass.singleton_class
      visibility = method_visibility(singleton, method)
      singleton.send(:define_method, method) { value }
      singleton.send(visibility, method)
      klass
    end

    # @api private
    # @param mod [Module] the module to look the method up in
    # @param method [Symbol, String] name of the method
    # @return [Symbol] `:private`, `:protected` or `:public` (also for a method that isn't defined yet)
    def self.method_visibility(mod, method)
      if mod.private_method_defined?(method)
        :private
      elsif mod.protected_method_defined?(method)
        :protected
      else
        :public
      end
    end
    private_class_method :method_visibility

    # Defines (or replaces) the class method `method` on this class so that it returns `value`.
    #
    # @param method [Symbol, String] name of the class method
    # @param value [Object] the value the method returns
    # @return [Module] this class
    # @see InheritanceHelper::Methods.redefine_class_method
    def redefine_class_method(method, value)
      ::InheritanceHelper::Methods.redefine_class_method(self, method, value)
    end

    # Redefines the class method `method` to return its current value with `value` added.
    #
    # - A Hash is merged with `value`, which must be a Hash.
    # - Anything else (an Array, a Set) is combined with `Array(value)`, so an array of values adds each one
    #   and the result stays flat. Use {#append_value_to_class_method} to add an array as a single element.
    #
    # The current value isn't changed. If it is frozen, the new value is frozen too.
    #
    # @param method [Symbol, String] name of a class method that returns a Hash, Array or Set
    # @param value [Object] the value or values to add
    # @return [Module] this class
    # @example
    #   add_value_to_class_method(:attributes, name: :string)  # {} => {name: :string}
    #   add_value_to_class_method(:fields, [:a, :b])           # [] => [:a, :b]
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

    # Redefines the class method `method` to return a copy of its current value with `value` appended as a
    # single element (using `<<`).
    #
    # The current value isn't changed. If it is frozen, the new value is frozen too.
    #
    # @param method [Symbol, String] name of a class method that returns an Array (or anything that responds
    #   to `dup` and `<<`)
    # @param value [Object] the element to append
    # @return [Module] this class
    # @example
    #   append_value_to_class_method(:callbacks, [:save, :log])  # [] => [[:save, :log]]
    def append_value_to_class_method(method, value)
      old_value = send(method)
      new_value = old_value.dup << value
      redefine_class_method(method, old_value.frozen? ? new_value.freeze : new_value)
    end
  end
end

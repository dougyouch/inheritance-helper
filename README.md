# inheritance-helper

Class-level settings that subclasses can extend without changing their parents.

[![CI](https://github.com/dougyouch/inheritance-helper/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/dougyouch/inheritance-helper/actions/workflows/ci.yml)
[![Coverage](https://raw.githubusercontent.com/dougyouch/inheritance-helper/badges/coverage.svg)](https://github.com/dougyouch/inheritance-helper/actions/workflows/ci.yml)
[![Branch Coverage](https://raw.githubusercontent.com/dougyouch/inheritance-helper/badges/branches.svg)](https://github.com/dougyouch/inheritance-helper/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/inheritance-helper.svg)](https://rubygems.org/gems/inheritance-helper)

[API reference](https://rubydoc.info/gems/inheritance-helper) · [Changelog](CHANGELOG.md)

DSLs often collect data at the class level: attributes, options, callbacks. With a class instance variable,
subclasses don't see the parent's data. With a class variable (`@@attributes`), every class in the chain
shares and changes the same object. `inheritance-helper` avoids both: each call replaces the class method on
the class it's called on, so a subclass starts with its parent's value, adds to it, and the parent keeps its
own.

It has no dependencies. It is used by [schema-model](https://github.com/dougyouch/schema) to collect
attribute definitions.

## Installation

Requires Ruby 3.2 or newer. Add this line to your application's Gemfile:

```ruby
gem 'inheritance-helper'
```

And then execute:

```bash
$ bundle install
```

## Usage

Extend a class with `InheritanceHelper::Methods` and define a class method that returns the starting value.
Freezing the value is recommended: values built from a frozen value are frozen too, so no class can change
another's data by mutating it.

```ruby
require 'inheritance-helper'

class Model
  extend InheritanceHelper::Methods

  def self.attributes
    {}.freeze
  end

  def self.attribute(name, type)
    add_value_to_class_method(:attributes, name => type)
    attr_accessor name
  end
end

class Person < Model
  attribute :name, :string
  attribute :phone, :string
end

class Employee < Person
  attribute :employee_id, :integer
end

Model.attributes     # => {}
Person.attributes    # => {name: :string, phone: :string}
Employee.attributes  # => {name: :string, phone: :string, employee_id: :integer}
```

### add_value_to_class_method

Redefines a class method to return its current value with more added:

- a **Hash** is merged with the new hash
- an **Array** or **Set** is combined with `Array(value)`, so an array of values adds each one and the
  result stays flat

```ruby
class Base
  extend InheritanceHelper::Methods

  def self.fields = [].freeze
  def self.tags = Set.new.freeze
end

class Child < Base
  add_value_to_class_method :fields, :name
  add_value_to_class_method :fields, %i[email phone]
  add_value_to_class_method :tags, :admin
end

Child.fields  # => [:name, :email, :phone]
Child.tags    # => Set[:admin]
Base.fields   # => []
```

### append_value_to_class_method

Redefines a class method to return its current array with one element appended. Unlike
`add_value_to_class_method`, an array is added as a single element:

```ruby
class Base
  extend InheritanceHelper::Methods

  def self.callbacks = [].freeze

  def self.before_save(*methods)
    append_value_to_class_method(:callbacks, methods)
  end
end

class Child < Base
  before_save :normalize, :validate
  before_save :log
end

Child.callbacks  # => [[:normalize, :validate], [:log]]
```

### redefine_class_method

Replaces a class method with one that returns the given value. Use it for settings that are replaced rather
than added to:

```ruby
class Base
  extend InheritanceHelper::Methods

  def self.table_name = 'records'

  def self.table(name)
    redefine_class_method(:table_name, name.freeze)
  end
end

class User < Base
  table 'users'
end

User.table_name  # => "users"
Base.table_name  # => "records"
```

The method returns the same object on every call, so freeze values that callers shouldn't change. The new
method keeps the visibility of the one it replaces, so a private class method stays private.

`InheritanceHelper::Methods.redefine_class_method(klass, method, value)` does the same for a class that
doesn't extend the module.

### Notes

- The class method must already return a value: `add_value_to_class_method` and
  `append_value_to_class_method` call it to get the current value.
- Each call defines a method on the class's singleton class. Classes declared at load time (the usual DSL
  case) are fine; redefining class methods from several threads at once is not synchronized.

## ClassBuilder::Utils

`InheritanceHelper::ClassBuilder::Utils` creates named classes at runtime, which is useful for DSLs that
build nested classes (such as a `has_many :items do ... end` block):

```ruby
module Shop; end

klass = InheritanceHelper::ClassBuilder::Utils.create_class(Shop, :line_item, nil, 'Schema', nil) do
  attr_accessor :quantity
end

klass       # => Shop::SchemaLineItem
klass.name  # => "Shop::SchemaLineItem"

InheritanceHelper::ClassBuilder::Utils.get_class_name(:line_item, 'Has', 'Class')
# => "HasLineItemClass"
```

`create_class(base_module, name, base_class, prefix, suffix, &block)` subclasses `base_class` (or `Object` when
`nil`), assigns it to the constant in `base_module`, and evaluates the block in the new class. If the constant
already exists it is replaced, with Ruby's "already initialized constant" warning.

`get_class_name` uses `String#classify` when ActiveSupport is loaded, which also singularizes the name
(`line_items` becomes `LineItem`). Without ActiveSupport the name is split on underscores and each part is
capitalized (`line_items` becomes `LineItems`).

## Development

```bash
bundle install
bundle exec rspec      # tests, with line and branch coverage in coverage/
bundle exec rubocop    # lint
bundle exec yard doc   # API docs in doc/
```

CI requires 100% line and branch coverage, no RuboCop offenses, and every public method documented with YARD.

Releases are automated with [release-please](https://github.com/googleapis/release-please): conventional
commits on `master` (`fix:`, `feat:`) update a release PR, and merging it tags the release and publishes the
gem.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).

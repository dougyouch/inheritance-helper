# inheritance-helper

A Ruby library that provides utility methods for handling class-level inheritance in Ruby. This gem makes it easy to manage and extend class methods and their values across your inheritance chain.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'inheritance-helper'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install inheritance-helper
```

## Usage

The `inheritance-helper` gem provides utilities for managing class-level attributes and methods across inheritance chains. It's particularly useful when you need to accumulate or modify class-level data through inheritance.

### Basic Example

```ruby
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

Person.attributes
# => {:name=>:string, :phone=>:string}
```

### Features

- Safely extend and modify class methods through inheritance
- Preserve class-level data integrity across the inheritance chain
- Simple and intuitive API for managing class attributes
- Thread-safe implementation

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details.

## Author

Doug Youch (dougyouch+github@gmail.com)

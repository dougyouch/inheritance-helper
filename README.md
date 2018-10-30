# inheritance-helper

Ruby library for redefining class methods.

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

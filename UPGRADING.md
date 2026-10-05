# Upgrading

## From 0.2.x to 1.0

1.0 has the same code as 0.3.0; the version number marks the API as stable. Everything below changed in 0.2.6
or 0.3.0, so it applies whichever of those you're upgrading from.

Most code needs no changes: `redefine_class_method`, `add_value_to_class_method` and
`append_value_to_class_method` behave as before for public class methods that return a starting value. Check
the items below that apply to you.

| Change | Version | Who is affected |
|---|---|---|
| [Ruby 3.3 or newer is required](#ruby-33-or-newer-is-required) | 0.3.0 | Apps on Ruby 3.2 |
| [Class names no longer use ActiveSupport](#class-names-no-longer-use-activesupport) | 0.3.0 | Code that uses `ClassBuilder::Utils` with ActiveSupport (Rails) loaded and refers to the generated constants by name |
| [Redefined private class methods stay private](#redefined-private-class-methods-stay-private) | 0.2.6 | Code that redefines a private class method and calls it from outside the class |
| [Underscores in class names](#underscores-in-class-names) | 0.2.6 | `ClassBuilder::Utils` names with repeated, leading or trailing underscores |
| [A nil starting value raises TypeError](#a-nil-starting-value-raises-typeerror) | 0.3.0 | Code that rescues `NoMethodError` from `add_value_to_class_method` or `append_value_to_class_method` |

### Ruby 3.3 or newer is required

Ruby 3.2 reached end of life in March 2026. On Ruby 3.2, Bundler and RubyGems keep resolving to 0.2.6, the last
release that supports it.

### Class names no longer use ActiveSupport

`InheritanceHelper::ClassBuilder::Utils.get_class_name`, and so `create_class`, used `String#classify` when
ActiveSupport was loaded. `classify` also singularizes, so the same code produced different class names with and
without ActiveSupport, and a singular and a plural name produced the same class. Names are now built the same way
everywhere: split on underscores, and the first letter of each part capitalized.

| Name | 0.2.x with ActiveSupport | 0.2.x without ActiveSupport | 1.0 |
|---|---|---|---|
| `:line_item` | `LineItem` | `LineItem` | `LineItem` |
| `:line_items` | `LineItem` | `LineItems` | `LineItems` |
| `:users` | `User` | `Users` | `Users` |
| `:news_items` | `NewsItem` | `NewsItems` | `NewsItems` |

Without ActiveSupport, nothing changes (apart from [underscores](#underscores-in-class-names)). With it, plural
names now stay plural. Two names that used to collide, such as `:user` and `:users`, now create two classes
instead of the second replacing the first with an "already initialized constant" warning.

`create_class` returns the class it creates, so code that keeps that return value is unaffected. Only code that
looks the class up by its constant name changes. To upgrade, either:

- **use the returned class** instead of the constant name, or
- **refer to the new name** (`Shop::SchemaLineItems` instead of `Shop::SchemaLineItem`), or
- **singularize the name yourself** if you want the old singular class name:

  ```ruby
  InheritanceHelper::ClassBuilder::Utils.create_class(Shop, :line_items.to_s.singularize, nil, 'Schema', nil)
  # => Shop::SchemaLineItem
  ```

Gems built on `ClassBuilder` pass this change on to their users. For example,
[client-api-builder 1.0](https://github.com/dougyouch/client-api-builder/blob/master/UPGRADING.md) names its
section classes this way.

### Redefined private class methods stay private

`redefine_class_method` (and the two helpers built on it) used to define the new method as public, even when it
replaced a private or protected class method. The new method now keeps the visibility of the one it replaces.

```ruby
class Base
  extend InheritanceHelper::Methods

  def self.registry = [].freeze
  private_class_method :registry
end

class Child < Base
  add_value_to_class_method :registry, :child
end

Child.registry         # 0.2.5: [:child]   1.0: NoMethodError (private method 'registry' called)
Child.send(:registry)  # => [:child]
```

If outside code calls such a method, make it public in the base class, or call it with `send` as above.

### Underscores in class names

Without ActiveSupport, `get_class_name` mishandled repeated and trailing underscores. It now drops empty parts:

| Name | 0.2.5 | 1.0 |
|---|---|---|
| `"foo__bar"` | `Foo_bar` | `FooBar` |
| `"foo_"` | `Foo_` | `Foo` |
| `"_foo"` | `_foo` (not a valid constant, so `create_class` raised `NameError`) | `Foo` |

### A nil starting value raises TypeError

`add_value_to_class_method` and `append_value_to_class_method` call the class method to get its current value.
When it returned `nil`, they failed with `NoMethodError: undefined method '+' for nil`. They now raise a
`TypeError` that names the method:

```
TypeError: Model.attributes returned nil; define it to return a starting value such as {}.freeze or [].freeze
```

Define the class method to return a starting value, as the README shows. Only code that rescued `NoMethodError`
here needs to change.

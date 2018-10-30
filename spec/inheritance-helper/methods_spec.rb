require 'helper'
require 'set'

describe InheritanceHelper::Methods do
  let(:class_a) do
    Class.new do
      extend InheritanceHelper::Methods
      def self.test_hash; {a: 1}.freeze; end
      def self.test_array; [:a].freeze; end
      def self.test_set; Set.new([:a]).freeze; end
    end
  end

  context 'add_value_to_class_method' do
    let(:class_b) { Class.new(class_a) }
    let(:class_c) { Class.new(class_b) }

    before do
      class_b.add_value_to_class_method(:test_hash, b: 2)
      class_b.add_value_to_class_method(:test_array, :b)
      class_b.add_value_to_class_method(:test_set, :b)
      class_c.add_value_to_class_method(:test_hash, c: 3)
      class_c.add_value_to_class_method(:test_array, :c)
      class_c.add_value_to_class_method(:test_set, :c)
    end

    it 'subclasses do not alter base class values' do
      expect(class_a.test_hash).to eq(a: 1)
      expect(class_a.test_array).to eq([:a])
      expect(class_a.test_set).to eq(Set.new([:a]))
      expect(class_b.test_hash).to eq(a: 1, b: 2)
      expect(class_b.test_array).to eq([:a, :b])
      expect(class_b.test_set).to eq(Set.new([:a, :b]))
      expect(class_c.test_hash).to eq(a: 1, b: 2, c: 3)
      expect(class_c.test_array).to eq([:a, :b, :c])
      expect(class_c.test_set).to eq(Set.new([:a, :b, :c]))
    end
  end
end

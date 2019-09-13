require 'helper'
require 'set'

describe InheritanceHelper::Methods do
  let(:class_a) do
    Class.new do
      extend InheritanceHelper::Methods
      def self.test_hash; {a: 1}.freeze; end
      def self.test_array; [:a].freeze; end
      def self.test_set; Set.new([:a]).freeze; end
      def self.test_list; [].freeze; end
    end
  end

  let(:class_b) { Class.new(class_a) }
  let(:class_c) { Class.new(class_b) }

  context 'add_value_to_class_method' do
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

  context 'append_value_to_class_method' do
    before(:each) do
      class_b.append_value_to_class_method(:test_list, [:a])
      class_b.append_value_to_class_method(:test_list, [:b])
      class_c.append_value_to_class_method(:test_list, [:c])
      class_c.append_value_to_class_method(:test_list, [:d])
    end

    it 'subclasses do not alter base class values' do
      expect(class_a.test_list).to eq([])
      expect(class_b.test_list).to eq([[:a], [:b]])
      expect(class_c.test_list).to eq([[:a], [:b], [:c], [:d]])
    end
  end
end

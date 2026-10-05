# frozen_string_literal: true

require 'helper'

describe InheritanceHelper::Methods do
  let(:class_a) do
    Class.new do
      extend InheritanceHelper::Methods

      def self.test_hash = { a: 1 }.freeze
      def self.test_array = [:a].freeze
      def self.test_set = Set.new([:a]).freeze
      def self.test_list = [].freeze
      def self.unfrozen_hash = { a: 1 }
      def self.unfrozen_array = [:a]
    end
  end

  let(:class_b) { Class.new(class_a) }
  let(:class_c) { Class.new(class_b) }

  describe '.redefine_class_method' do
    it 'defines a class method that returns the value and returns the class' do
      klass = Class.new
      expect(described_class.redefine_class_method(klass, :answer, 42)).to eq(klass)
      expect(klass.answer).to eq(42)
    end

    it 'does not change the parent class' do
      described_class.redefine_class_method(class_b, :test_list, [:b].freeze)
      expect(class_a.test_list).to eq([])
      expect(class_b.test_list).to eq([:b])
      expect(class_c.test_list).to eq([:b])
    end

    it 'keeps a private class method private' do
      class_a.singleton_class.send(:define_method, :secret) { :a }
      class_a.private_class_method :secret
      described_class.redefine_class_method(class_b, :secret, :b)
      expect(class_b.respond_to?(:secret)).to be(false)
      expect(class_b.send(:secret)).to eq(:b)
    end

    it 'keeps a protected class method protected' do
      class_a.singleton_class.send(:define_method, :guarded) { :a }
      class_a.singleton_class.send(:protected, :guarded)
      described_class.redefine_class_method(class_b, :guarded, :b)
      expect(class_b.singleton_class.protected_method_defined?(:guarded)).to be(true)
      expect(class_b.send(:guarded)).to eq(:b)
    end

    it 'accepts a string method name' do
      described_class.redefine_class_method(class_b, 'test_list', [:b])
      expect(class_b.test_list).to eq([:b])
    end
  end

  describe '#redefine_class_method' do
    it 'redefines the class method on the receiver' do
      expect(class_b.redefine_class_method(:test_hash, { b: 2 })).to eq(class_b)
      expect(class_b.test_hash).to eq(b: 2)
      expect(class_a.test_hash).to eq(a: 1)
    end
  end

  describe '#add_value_to_class_method' do
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
      expect(class_b.test_array).to eq(%i[a b])
      expect(class_b.test_set).to eq(Set.new(%i[a b]))
      expect(class_c.test_hash).to eq(a: 1, b: 2, c: 3)
      expect(class_c.test_array).to eq(%i[a b c])
      expect(class_c.test_set).to eq(Set.new(%i[a b c]))
    end

    it 'keeps frozen values frozen' do
      expect(class_c.test_hash).to be_frozen
      expect(class_c.test_array).to be_frozen
      expect(class_c.test_set).to be_frozen
    end

    it 'adds each element of an array, keeping the result flat' do
      class_c.add_value_to_class_method(:test_array, %i[d e])
      expect(class_c.test_array).to eq(%i[a b c d e])
    end

    it 'leaves unfrozen values unfrozen' do
      class_b.add_value_to_class_method(:unfrozen_hash, b: 2)
      class_b.add_value_to_class_method(:unfrozen_array, :b)
      expect(class_b.unfrozen_hash).to eq(a: 1, b: 2)
      expect(class_b.unfrozen_hash).not_to be_frozen
      expect(class_b.unfrozen_array).to eq(%i[a b])
      expect(class_b.unfrozen_array).not_to be_frozen
      expect(class_a.unfrozen_hash).to eq(a: 1)
      expect(class_a.unfrozen_array).to eq([:a])
    end

    it 'works with a private class method' do
      class_a.singleton_class.send(:define_method, :private_list) { [].freeze }
      class_a.private_class_method :private_list
      class_b.add_value_to_class_method(:private_list, :b)
      expect(class_b.send(:private_list)).to eq([:b])
      expect(class_b.respond_to?(:private_list)).to be(false)
    end
  end

  describe '#append_value_to_class_method' do
    before do
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

    it 'keeps frozen values frozen' do
      expect(class_c.test_list).to be_frozen
    end

    it 'leaves unfrozen values unfrozen' do
      class_b.append_value_to_class_method(:unfrozen_array, :b)
      expect(class_b.unfrozen_array).to eq(%i[a b])
      expect(class_b.unfrozen_array).not_to be_frozen
      expect(class_a.unfrozen_array).to eq([:a])
    end
  end
end

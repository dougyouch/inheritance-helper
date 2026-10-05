# frozen_string_literal: true

require 'helper'

describe InheritanceHelper::ClassBuilder::Utils do
  let(:base_module) { stub_const('ClassBuilderSpec', Module.new) }
  let(:base_class) { Struct.new(:name) }
  let(:name) { 'foo_bar' }
  let(:prefix_class_name) { 'Pre' }
  let(:suffix_class_name) { 'Game' }

  describe '.get_class_name' do
    subject { described_class.get_class_name(name, prefix_class_name, suffix_class_name) }

    it { expect(subject).to eq('PreFooBarGame') }

    context 'without a prefix or suffix' do
      let(:prefix_class_name) { nil }
      let(:suffix_class_name) { nil }

      it { expect(subject).to eq('FooBar') }
    end

    context 'with a symbol' do
      let(:name) { :foo_bar }

      it { expect(subject).to eq('PreFooBarGame') }
    end

    context 'with repeated, leading and trailing underscores' do
      let(:name) { '_foo__bar_' }

      it { expect(subject).to eq('PreFooBarGame') }
    end

    context 'with capitals in the name' do
      let(:name) { 'fooBar_baz' }

      it { expect(subject).to eq('PreFooBarBazGame') }
    end

    context 'when the string responds to classify (ActiveSupport)' do
      let(:name) do
        str = +'foo_bars'
        def str.classify = 'FooBar'
        str
      end

      it 'does not use classify or singularize' do
        expect(subject).to eq('PreFooBarsGame')
      end
    end
  end

  describe '.create_class' do
    subject do
      described_class.create_class(base_module, name, base_class, prefix_class_name, suffix_class_name) do
        attr_accessor :count
      end
    end

    let(:instance) do
      obj = subject.new('foo')
      obj.count = 21
      obj
    end

    it { expect(subject.name).to eq('ClassBuilderSpec::PreFooBarGame') }
    it { expect(subject.superclass).to eq(base_class) }
    it { expect(subject).to equal(base_module::PreFooBarGame) }
    it { expect(instance.name).to eq('foo') }
    it { expect(instance.count).to eq(21) }

    context 'without a base class or block' do
      subject { described_class.create_class(base_module, name, nil, nil, nil) }

      it { expect(subject.superclass).to eq(Object) }
      it { expect(subject).to equal(base_module::FooBar) }
    end

    context 'with a name that is not a valid constant' do
      subject { described_class.create_class(base_module, 'foo-bar', nil, nil, nil) }

      it { expect { subject }.to raise_error(NameError) }
    end
  end
end

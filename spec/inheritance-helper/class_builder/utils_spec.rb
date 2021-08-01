require 'helper'

describe InheritanceHelper::ClassBuilder::Utils do
  let(:base_module) { Object }
  let(:base_class) { Struct.new(:name) }
  let(:name) { 'foo_bar' }
  let(:preffix_class_name) { 'Pre' }
  let(:postfix_class_name) { 'Game' }

  context '.get_class_name' do
    subject { InheritanceHelper::ClassBuilder::Utils.get_class_name(name, preffix_class_name, postfix_class_name) }
    let(:expected_class_name) { 'PreFooBarGame' }

    it { expect(subject).to eq(expected_class_name) }
  end

  context '.create_class' do
    subject { InheritanceHelper::ClassBuilder::Utils.create_class(base_module, name, base_class, preffix_class_name, postfix_class_name) { attr_accessor :count } }
    let(:expected_class_name) { 'PreFooBarGame' }
    let(:instance) do
      obj = subject.new('foo')
      obj.count = 21
      obj
    end

    it { expect(subject.name).to eq(expected_class_name) }
    it { expect(instance.count).to eq(21) }
  end
end

# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

RSpec.describe ToProcInterface do
  let(:delegated_methods) { ToProcInterface::METHODS }
  let(:including_mixin) { Module.new.tap { _1.include ToProcInterface } }

  it "has a version number" do
    expect(ToProcInterface::VERSION).not_to be nil
  end

  describe ".loader" do
    subject(:loader) { ToProcInterface.loader }

    it { is_expected.to be_instance_of(Zeitwerk::GemLoader) }

    it "doesn't raise an error on eager load" do
      expect { loader.eager_load(force: true) }.not_to raise_error
    end
  end

  describe "ToProcInterface::METHODS" do
    subject(:methods_list) { delegated_methods }

    let(:not_delegated) { %i[dup to_proc inspect === to_s ruby2_keywords call hash clone] }

    it { is_expected.to match_array(Proc.instance_methods(false) - not_delegated) }
  end

  describe ToProcInterface::Delegations do
    it "provides instance methods listed in ToProcInterface::METHODS" do
      expect(described_class.instance_methods).to match_array(delegated_methods)
    end
  end

  context "on a module included ToProcInterface" do
    subject(:target_module) { including_mixin }

    it { is_expected.not_to be < ToProcInterface::Hooks::Inherited }

    context "on its singleton class" do
      subject(:target_singleton_class) { target_module.singleton_class }

      it { is_expected.to be < ToProcInterface::Hooks::Extended }
      it { is_expected.not_to be < ToProcInterface::Hooks::Inherited }
    end

    context "on a class extended with that module" do
      subject(:target_class) { Class.new.tap { _1.extend(target_module) } }

      it { is_expected.not_to be < ToProcInterface::Hooks::Extended }
      it { is_expected.not_to be < ToProcInterface::Hooks::Inherited }

      context "on its singleton class" do
        subject(:target_singleton_class) { target_class.singleton_class }

        it { is_expected.to be < ToProcInterface::Hooks::Inherited }
        it { is_expected.not_to be < ToProcInterface::Hooks::Extended }
      end
    end
  end
end

# rubocop:enable Metrics/BlockLength

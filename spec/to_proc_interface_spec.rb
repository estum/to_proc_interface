# frozen_string_literal: true

RSpec.describe ToProcInterface do
  it "has a version number" do
    expect(ToProcInterface::VERSION).not_to be nil
  end

  subject(:mixin) { ToProcInterface }

  context 'when extended to class' do
    subject(:sample_class) do
      Class.new do
        def self.call(*args, **opts, &block)
          { args: args, opts: opts, block: block }
        end

        extend ToProcInterface
      end
    end

    it { is_expected.to respond_to(:to_proc) }
  end
end

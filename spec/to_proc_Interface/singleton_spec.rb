# frozen_string_literal: true

require "to_proc_interface/singleton"

module ToProcInterface
  RSpec.describe Singleton do
    context "on a singleton class" do
      subject(:example_class) do
        Class.new do
          include Singleton

          def call(a:, b:)
            a + b
          end
        end
      end

      it { is_expected.to respond_to(:call) & respond_to(:to_proc) }

      it { is_expected.to be < ::Singleton }
      it { is_expected.not_to be < Hooks::Extended }

      describe ".to_proc" do
        subject(:produced_proc) { example_class.to_proc }
        it { is_expected.to be_instance_of(Proc) }
      end

      it "delegates procs methods to an instance of a singleton class" do
        dataset = [{ a: 1, b: 2 }, { a: 3, b: 4 }]
        expect(dataset.map(&example_class)).to match_array [3, 7]
      end
    end
  end
end

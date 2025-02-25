# frozen_string_literal: true

require "dry/core/equalizer"

module ToProcInterface
  RSpec.describe Initializer do
    let(:extended_class) do
      Class.new do
        extend Initializer

        include Dry.Equalizer(:a, :b)

        def initialize(a:, b:)
          @a, @b = a, b
        end

        attr_reader :a, :b
      end
    end

    let(:inherited_class) do
      Class.new(extended_class) do
        include Dry.Equalizer(:a, :b, :c)

        def initialize(c: nil, **opts)
          super(**opts)
          @c = c
        end

        attr_reader :c
      end
    end

    context "on an extended class" do
      subject(:klass) { extended_class }

      it { is_expected.to respond_to(:call) & respond_to(:to_proc) }

      describe ".to_proc" do
        subject(:produced_proc) { klass.to_proc }
        it { is_expected.to be_instance_of(Proc) }

        it "memoizes a proc" do
          expect(klass.to_proc).to eq(produced_proc)
        end
      end

      it "makes an extended class acts like a constructor proc" do
        dataset = [{ a: 1, b: 2 }, { a: 3, b: 4 }]
        expect(dataset.map(&klass)).to match_array [
          klass[a: 1, b: 2],
          klass[a: 3, b: 4]
        ]
      end

      context 'on an inherited class' do
        subject(:subclass) { inherited_class }

        describe '.to_proc' do
          subject(:subclass_proc) { subclass.to_proc }
          it { is_expected.not_to eq(extended_class.to_proc) }
        end

        it "makes an extended class acts like a constructor proc" do
          dataset = [{ a: 1, b: 2, c: 3 }, { a: 4, b: 5, c: 6 }]
          expect(dataset.map(&subclass)).to match_array [
            subclass[a: 1, b: 2, c: 3],
            subclass[a: 4, b: 5, c: 6]
          ]
        end
      end
    end
  end
end

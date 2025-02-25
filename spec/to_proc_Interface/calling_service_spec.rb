# frozen_string_literal: true

module ToProcInterface
  RSpec.describe CallingService do
    let(:extended_class) do
      Struct.new(:a, :b, keyword_init: true) do
        extend CallingService

        def call
          a + b
        end
      end
    end

    context "on an extended class" do
      subject(:klass) { extended_class }

      it { is_expected.to respond_to(:call) & respond_to(:to_proc) }

      describe ".to_proc" do
        subject(:produced_proc) { klass.to_proc }
        it { is_expected.to be_instance_of(Proc) }
      end

      it "makes an extended class acts like a constructor + call proc" do
        allow(klass).to receive(:new).and_call_original
        allow(klass).to receive(:call).and_call_original
        allow(klass).to receive(:to_proc).and_call_original

        dataset = [{ a: 1, b: 2 }, { a: 3, b: 4 }]
        expect(dataset.map(&klass)).to match_array [3, 7]
        expect(klass).to have_received(:new).with(a: 1, b: 2).once
        expect(klass).to have_received(:new).with(a: 3, b: 4).once
      end
    end
  end
end

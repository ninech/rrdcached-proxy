shared_examples_for 'a backend' do
  let(:logger) { Logger.new(StringIO.new) }
  let(:default_config) { { logger: logger } }
  let(:merged_config) { default_config.merge(config) }
  let(:instance) { described_class.new(merged_config) }

  describe '#initialize' do
    specify { expect { instance }.to_not raise_error }
  end

  describe '#write' do
    let(:point1) { instance_double(RRDCachedProxy::UpdateData::Point) }
    let(:point2) { instance_double(RRDCachedProxy::UpdateData::Point) }

    subject { instance.write(points) }

    context 'empty array' do
      let(:points) { [] }

      specify { expect { subject }.to_not raise_error }
    end

    context 'one point' do
      let(:points) { [point1] }

      before do
        allow(point1).to receive(:name).and_return('point1')
        allow(point1).to receive(:value).and_return(42)
        allow(point1).to receive(:timestamp).and_return(Time.now.to_i)
      end

      specify { expect { subject }.to_not raise_error }
    end

    context 'multiple points' do
      let(:points) { [point1, point2] }

      before do
        allow(point1).to receive(:name).and_return('point1')
        allow(point1).to receive(:value).and_return(42)
        allow(point1).to receive(:timestamp).and_return(Time.now.to_i)

        allow(point2).to receive(:name).and_return('point2')
        allow(point2).to receive(:value).and_return(1337)
        allow(point2).to receive(:timestamp).and_return(Time.now.to_i)
      end

      specify { expect { subject }.to_not raise_error }
    end
  end
end

require 'spec_helper'

describe Elasticsnap::VerifyEsClusterStatus do
  it 'requires a url' do
    expect { described_class.new(quorum_nodes: 1) }.to raise_error ArgumentError
  end

  it 'requires quorum_nodes' do
    expect { described_class.new(url: 'asdf') }.to raise_error ArgumentError
  end

  let(:verify) { described_class.new(url: 'localhost:9200', quorum_nodes: 2) }

  it 'queries elasticsearch with flex' do
    expect(Flex).to receive(:cluster_health).and_return({'status' => 'green', 'number_of_nodes' => 2 })
    verify.verify!
  end

  context 'when the cluster remains red' do
    it 'raises a StatusRed exception' do
      allow(Flex).to receive(:cluster_health).and_return({'status' => 'red'})
      expect { verify.verify! }.to raise_error Elasticsnap::VerifyEsClusterStatus::StatusRed
    end
  end

  context "when the cluster hasn't reached quorum" do
    it 'raises a NoQuorum exception' do
      allow(Flex).to receive(:cluster_health).and_return({'status' => 'green', 'number_of_nodes' => 1 })
      expect { verify.verify! }.to raise_error Elasticsnap::VerifyEsClusterStatus::NoQuorum
    end
  end
end

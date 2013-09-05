require 'spec_helper'

describe Elasticsnap::Snapshot do
  let(:url) { 'localhost:9200' }
  let(:volume) { '/dev/sda' }
  let(:quorum_nodes) { 2 }
  let(:snapshot) { described_class.new(url: url, volume: volume, quorum_nodes: quorum_nodes) }

  before do
    allow(snapshot).to receive(:verify_es_cluster_status!)
    allow(snapshot).to receive(:freeze_es) do |&block|
      block.call
    end
    allow(snapshot).to receive(:freeze_fs) do |&block|
      block.call
    end
    allow(snapshot).to receive(:ebs_snapshot!)
  end

  it 'requires url' do
    expect { described_class.new(volume: 'foo') }.to raise_error ArgumentError
  end

  it 'requires volume' do
    expect { described_class.new(url: 'foo') }.to raise_error ArgumentError
  end

  it 'requires quorum_nodes' do
    expect { described_class.new(url: 'foo', volume: 'foo') }.to raise_error ArgumentError
  end

  it 'checks the ES cluster status' do
    snapshot.call
    expect(snapshot).to have_received :verify_es_cluster_status!
  end

  context 'when the cluster status is bad' do
    it 'raises an exception' do
      allow(snapshot).to receive(:verify_es_cluster_status!).and_raise 'bad cluster!'
      expect { snapshot.call }.to raise_error 'bad cluster!'
    end
  end

  it 'freezes elasticsearch' do
    snapshot.call
    expect(snapshot).to have_received :freeze_es
  end

  it 'freezes the filesystem' do
    snapshot.call
    expect(snapshot).to have_received :freeze_fs
  end

  it 'snapshots the EBS volume' do
    snapshot.call
    expect(snapshot).to have_received :ebs_snapshot!
  end
end

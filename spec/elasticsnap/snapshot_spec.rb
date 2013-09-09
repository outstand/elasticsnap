require 'spec_helper'

describe Elasticsnap::Snapshot do
  let(:security_group) { 'elasticsearch' }
  let(:url) { 'localhost:9200' }
  let(:mount) { '/usr/local/var/data/elasticsearch/disk1' }
  let(:quorum_nodes) { 2 }
  let(:snapshot) { described_class.new(security_group: security_group, url: url, mount: mount, quorum_nodes: quorum_nodes) }

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

  it 'requires security group' do
    expect { described_class.new }.to raise_error ArgumentError
  end

  it 'requires url' do
    expect { described_class.new(security_group: 'foo') }.to raise_error ArgumentError
  end

  it 'requires mount' do
    expect { described_class.new(security_group: 'foo', url: 'foo') }.to raise_error ArgumentError
  end

  it 'requires quorum_nodes' do
    expect { described_class.new(security_group: 'foo', url: 'foo', mount: 'foo') }.to raise_error ArgumentError
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

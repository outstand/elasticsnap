require 'spec_helper'

describe Elasticsnap::EbsSnapshot do
  it 'requires security group' do
    expect { described_class.new }.to raise_error ArgumentError
  end

  let(:security_group) { double(:security_group, name: 'elasticsearch') }
  let(:snapshotter) { described_class.new(security_group: security_group.name) }
  let(:snapshots) { [double(:snapshot1, add_volume_tags: true), double(:snapshot2, add_volume_tags: true)] }
  let(:volumes) { [double(:volume1, id: 'vol-123', snapshot: snapshots[0]), double(:volume2, id: 'vol-234', snapshot: snapshots[1])] }

  describe '#snapshot' do
    before do
      allow(snapshotter).to receive(:wrap_snapshot) do |snapshot|
        snapshot
      end

      allow(Elasticsnap::SecurityGroup).to receive(:new).with(name: security_group.name).and_return(security_group)
      allow(security_group).to receive(:volumes).and_return(volumes)
    end

    it 'gets a list of volumes from the security group' do
      snapshotter.snapshot
      expect(Elasticsnap::SecurityGroup).to have_received(:new).with(name: security_group.name)
      expect(security_group).to have_received(:volumes)
    end

    it 'snapshots each volume' do
      snapshotter.snapshot
      volumes.each do |volume|
        expect(volume).to have_received(:snapshot)
      end
    end

    it 'adds volume tags to each snapshot' do
      snapshotter.snapshot
      snapshots.each do |snapshot|
        expect(snapshot).to have_received(:add_volume_tags)
      end
    end
  end

  describe '#wrap_snapshot' do
    let(:snapshot_body) { double(:snapshot_body) }
    let(:snapshot_response) { double(:snapshot_response, body: snapshot_body) }
    let(:snapshot) { double(:snapshot) }

    before do
      allow(Fog::Compute::AWS::Snapshot).to receive(:new).with(snapshot_body).and_return(snapshot)
    end

    it 'bundles the response in a snapshot model' do
      snapshotter.wrap_snapshot(snapshot_response)
      expect(Fog::Compute::AWS::Snapshot).to have_received(:new)
    end

    it 'extends the snapshot instance with SnapshotVolumeTags' do
      expect(snapshot).to receive(:extend).with(Elasticsnap::SnapshotVolumeTags)
      snapshotter.wrap_snapshot(snapshot_response)
    end
  end
end

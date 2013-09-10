require 'spec_helper'

describe Elasticsnap::SecurityGroup do
  it 'requires name' do
    expect { described_class.new }.to raise_error ArgumentError
  end

  let(:group) { described_class.new(name: 'elasticsearch') }
  let(:hosts) {[double(:host1, id: 'host1', dns_name: 'host1.ec2'), double(:host2, id: 'host2', dns_name: 'host2.ec2')]}

  describe '#fog_group' do
    it 'fetches the fog model' do
      groups = double(:groups)
      group.stub_chain(:connection, :security_groups, :all).and_return(groups)
      expect(groups).to receive(:first)
      group.fog_group
    end
  end

  describe '#id' do
    it 'aliases the fog group_id' do
      fog_group = double(:fog_group)
      expect(group).to receive(:fog_group).and_return(fog_group)
      expect(fog_group).to receive(:group_id)
      group.id
    end
  end

  describe '#hosts' do
    it 'fetches all servers with the group id' do
      allow(group).to receive(:id).and_return('sg-deadbeef')
      servers = double(:servers)
      group.stub_chain(:connection, :servers).and_return(servers)
      expect(servers).to receive(:all).with('group-id' => 'sg-deadbeef')
      group.hosts
    end
  end

  describe '#volumes' do
    let(:volumes) { double(:volumes) }
    before do
      allow(group).to receive(:hosts).and_return(hosts)
      group.stub_chain(:connection, :volumes).and_return(volumes)
    end

    context 'with cluster name' do
      it 'fetches all volumes with the instance ids and cluster name tag' do
        expect(volumes).to receive(:all).with(
          'attachment.instance-id' => ['host1', 'host2'],
          'tag:ClusterName' => 'thundercats'
        )
        group.volumes(cluster_name: 'thundercats')
      end
    end

    context 'without cluster name' do
      it 'fetches all volumes with the instance ids' do
        expect(volumes).to receive(:all).with(
          'attachment.instance-id' => ['host1', 'host2']
        )
        group.volumes
      end
    end
  end

  describe '#ssh_hosts' do
    before do
      allow(group).to receive(:hosts).and_return(hosts)
    end

    it 'fetches the dns name for all hosts in the security group' do
      expect(group.ssh_hosts).to eq ['host1.ec2', 'host2.ec2']
    end

    context 'with an ssh user' do
      it 'adds the ssh user to each host' do
        expect(group.ssh_hosts(ssh_user: 'foo')).to eq ['foo@host1.ec2', 'foo@host2.ec2']
      end
    end
  end
end

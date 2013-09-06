require 'spec_helper'

describe 'Snapshots' do
  before do
    WebMock.disable_net_connect!
  end

  after do
    WebMock.allow_net_connect!
  end

  let(:timeout) { 2 }
  let(:quorum) { 2 }
  let(:args) { "-u localhost:9200 -v /dev/sda -q #{quorum} -t #{timeout}" }

  it 'User creates snapshot' do
    health_check = stub_request(:get, 'localhost:9200/_cluster/health/').with(
      query: hash_including({
        wait_for_nodes: "gt(#{quorum})",
        wait_for_status: 'yellow'
      })
    ).to_return(
      body: MultiJson.dump({
        'cluster_name' => 'foobar',
        'status' => 'green',
        'timed_out' => false,
        'number_of_nodes' => 2,
        'number_of_data_nodes' => 2,
        'active_primary_shards' => 5,
        'active_shards' => 10,
        'relocating_shards' => 0,
        'initializing_shards' => 0,
        'unassigned_shards' => 0
      })
    )

    start(:snapshot, args)
    expect(health_check).to have_been_requested
  end
end

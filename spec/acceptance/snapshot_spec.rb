require 'spec_helper'

describe 'Snapshots' do
  before do
    WebMock.disable_net_connect!
    #WebMock.allow_net_connect!
  end

  let(:timeout) { 2 }
  let(:quorum) { 2 }
  let(:args) { "-u localhost:9200 -v /dev/sda -q #{quorum} -t #{timeout}" }

  it 'User creates snapshot' do
    pending 'Add stubs for ssh connections and fog'
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

    flush = stub_request(:post, 'localhost:9200/_all/_flush').to_return(
      body: MultiJson.dump({
        'ok' => true
      })
    )

    disable_flush = stub_request(:put, 'localhost:9200/_all/_settings').with(
      body: MultiJson.dump({
        index: {
          translog: {
            disable_flush: true
          }
        }
      })
    ).to_return(
      body: MultiJson.dump({
        'ok' => true
      })
    )

    enable_flush = stub_request(:put, 'localhost:9200/_all/_settings').with(
      body: MultiJson.dump({
        index: {
          translog: {
            disable_flush: false
          }
        }
      })
    ).to_return(
      body: MultiJson.dump({
        'ok' => true
      })
    )

    start(:snapshot, args)
    expect(health_check).to have_been_requested
    expect(flush).to have_been_requested
    expect(disable_flush).to have_been_requested
    expect(enable_flush).to have_been_requested
  end
end

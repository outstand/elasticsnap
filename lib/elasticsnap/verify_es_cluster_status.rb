require 'flex'

module Elasticsnap
  class VerifyEsClusterStatus
    class Error < StandardError; end
    class StatusRed < Error; end
    class NoQuorum < Error; end

    attr_accessor :url
    attr_accessor :quorum_nodes
    attr_accessor :wait_timeout

    def initialize(url: nil, quorum_nodes: nil, wait_timeout: 30)
      raise ArgumentError, 'url required' if url.nil?
      raise ArgumentError, 'quorum_nodes required' if quorum_nodes.nil?

      @url = url
      @quorum_nodes = quorum_nodes
      @wait_timeout = wait_timeout
    end

    def verify!
      wait_for_green_quorum!
    end

    def wait_for_green_quorum!
      Flex::Configuration.http_client.base_uri = url
      health = Flex.cluster_health(
        params: {
          wait_for_status: 'yellow',
          wait_for_nodes: "gt(#{quorum_nodes})",
          timeout: "#{wait_timeout}s"
        }
      )

      raise StatusRed if health['status'] == 'red'
      raise NoQuorum if health['number_of_nodes'] < quorum_nodes

      health
    end
  end
end

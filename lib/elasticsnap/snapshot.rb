require 'elasticsnap/verify_es_cluster_status'
require 'elasticsnap/freeze_elasticsearch'
require 'elasticsnap/freeze_fs'
require 'elasticsnap/ebs_snapshot'

module Elasticsnap
  class Snapshot
    attr_accessor :url
    attr_accessor :volume
    attr_accessor :quorum_nodes

    def initialize(url: nil, volume: nil, quorum_nodes: nil)
      raise ArgumentError, "url required" if url.nil?
      raise ArgumentError, "volume required" if volume.nil?
      raise ArgumentError, "quorum_nodes required" if quorum_nodes.nil?

      @url = url
      @volume = volume
      @quorum_nodes = quorum_nodes
    end

    def call
      verify_es_cluster_status!
      freeze_es do
        freeze_fs do
          ebs_snapshot!
        end
      end
    end

    def verify_es_cluster_status!
      VerifyEsClusterStatus.new(url: url, quorum_nodes: quorum_nodes).verify!
    end

    def freeze_es(&block)
      FreezeElasticsearch.new(url: url).freeze(&block)
    end

    def freeze_fs(&block)
      FreezeFs.new(volume: volume).freeze(&block)
    end

    def ebs_snapshot!
      EbsSnapshot.new(volume: volume).call
    end
  end
end

require 'elasticsnap/verify_es_cluster_status'
require 'elasticsnap/freeze_elasticsearch'
require 'elasticsnap/freeze_fs'
require 'elasticsnap/ebs_snapshot'

module Elasticsnap
  class Snapshot
    attr_accessor :security_group
    attr_accessor :url
    attr_accessor :mount
    attr_accessor :quorum_nodes
    attr_accessor :wait_timeout
    attr_accessor :cluster_name

    def initialize(security_group: nil, url: nil, mount: nil, quorum_nodes: nil, wait_timeout: 30, cluster_name: nil)
      raise ArgumentError, "security_group required" if security_group.nil?
      raise ArgumentError, "url required" if url.nil?
      raise ArgumentError, "mount required" if mount.nil?
      raise ArgumentError, "quorum_nodes required" if quorum_nodes.nil?

      @security_group = security_group
      @url = url
      @mount = mount
      @quorum_nodes = quorum_nodes
      @wait_timeout = wait_timeout
      @cluster_name = cluster_name
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
      VerifyEsClusterStatus.new(url: url, quorum_nodes: quorum_nodes, wait_timeout: wait_timeout).verify!
    end

    def freeze_es(&block)
      FreezeElasticsearch.new(url: url).freeze(&block)
    end

    def freeze_fs(&block)
      FreezeFs.new(mount: mount, security_group: security_group).freeze(&block)
    end

    def ebs_snapshot!
      EbsSnapshot.new(security_group: security_group, cluster_name: cluster_name).snapshot
    end
  end
end

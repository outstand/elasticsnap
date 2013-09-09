require 'elasticsnap/security_group'
require 'elasticsnap/snapshot_volume_tags'
require 'fog/aws/models/compute/snapshot'

module Elasticsnap
  class EbsSnapshot
    attr_accessor :security_group
    attr_accessor :cluster_name

    def initialize(security_group: nil, cluster_name: nil)
      raise ArgumentError, 'security_group required' if security_group.nil?
      @security_group = security_group
      @cluster_name = cluster_name
    end

    def snapshot
      SecurityGroup.new(name: security_group).volumes(cluster_name: cluster_name).map do |volume|
        snapshot = volume.snapshot("Created by Elasticsnap from #{volume.id}")
        snapshot = wrap_snapshot(snapshot)
        snapshot.add_volume_tags(volume)
      end
    end

    def wrap_snapshot(snapshot)
      snapshot = Fog::Compute::AWS::Snapshot.new(snapshot.body)
      snapshot.send(:extend, SnapshotVolumeTags)
      snapshot
    end
  end
end

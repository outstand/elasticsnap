require 'elasticsnap/config'

module Elasticsnap
  module SnapshotVolumeTags
    def add_volume_tags(volume)
      connection.create_tags(self.id, volume.tags)
    end

    def connection
      Config.fog_connection
    end
  end
end

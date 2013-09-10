require 'elasticsnap/config'

module Elasticsnap
  class SecurityGroup
    attr_accessor :name

    def initialize(name: nil)
      raise ArgumentError, 'name required' if name.nil?

      @name = name
    end

    def hosts
      @hosts ||= connection.servers.all('group-id' => id)
    end

    def ssh_hosts(ssh_user: nil)
      hosts.map do |host|
        if ssh_user
          "#{ssh_user}@#{host.dns_name}"
        else
          host.dns_name
        end
      end
    end

    def volumes(cluster_name: nil)
      filters = { 'attachment.instance-id' => hosts.map(&:id) }
      filters.merge!('tag:ClusterName' => cluster_name) if cluster_name
      connection.volumes.all(filters)
    end

    def fog_group
      @fog_group ||= connection.security_groups.all('group-name' => name).first
    end

    def id
      @id ||= fog_group.group_id
    end

    def reload
      @hosts = @id = nil
    end

    private
    def connection
      Config.fog_connection
    end
  end
end

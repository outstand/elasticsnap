require 'elasticsnap'
require 'elasticsnap/cli/base'

module Elasticsnap
  module Cli
    class Application < Base
      desc "snapshot", "Snapshot elasticsearch to EBS"
      method_option :security_group, type: :string, aliases: '-g', required: true, desc: 'EC2 security group'
      method_option :mount, type: :string, aliases: '-m', required: true, desc: 'Volume mount point'
      method_option :quorum_nodes, type: :numeric, aliases: '-q', required: true, desc: 'Number of nodes required for quorum'
      method_option :url, type: :string, aliases: '-u', default: 'localhost:9200', desc: 'Elasticsearch URL'
      method_option :wait_timeout, type: :numeric, aliases: '-t', default: 30, desc: 'Number of seconds to wait for elasticsearch to become healthy'
      method_option :cluster_name, type: :string, aliases: '-n' ,desc: 'Elasticsearch cluster name used to filter EBS volumes'
      method_option :ssh_user, type: :string, desc: 'SSH user'
      def snapshot
        Snapshot.new(
          security_group: options[:security_group],
          url: options[:url],
          mount: options[:mount],
          quorum_nodes: options[:quorum_nodes],
          wait_timeout: options[:wait_timeout],
          cluster_name: options[:cluster_name],
          ssh_user: options[:ssh_user]
        ).call
      end

      desc "version", "Display version information"
      def version
        say("Elasticsnap: #{Elasticsnap::VERSION}", :yellow)
      end
    end
  end
end

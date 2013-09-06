require 'elasticsnap'
require 'elasticsnap/cli/base'

module Elasticsnap
  module Cli
    class Application < Base
      desc "snapshot", "Snapshot elasticsearch to EBS"
      method_option :volume, type: :string, aliases: '-v', required: true, desc: 'Block Volume'
      method_option :quorum_nodes, type: :numeric, aliases: '-q', required: true, desc: 'Number of nodes required for quorum'
      method_option :url, type: :string, aliases: '-u', default: 'localhost:9200', desc: 'Elasticsearch URL'
      method_option :wait_timeout, type: :numeric, aliases: '-t', default: 30, desc: 'Number of seconds to wait for elasticsearch to become healthy'
      def snapshot
        Snapshot.new(url: options[:url], volume: options[:volume], quorum_nodes: options[:quorum_nodes], wait_timeout: options[:wait_timeout]).call
      end

      desc "version", "Display version information"
      def version
        say("Elasticsnap: #{Elasticsnap::VERSION}", :yellow)
      end
    end
  end
end

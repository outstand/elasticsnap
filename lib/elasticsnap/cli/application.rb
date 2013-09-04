require 'elasticsnap'
require 'elasticsnap/cli/base'

module Elasticsnap
  module Cli
    class Application < Base
      desc "snapshot", "Snapshot elasticsearch to EBS"
      method_option :url, type: :string, aliases: '-u', default: 'localhost:9200', desc: 'Elasticsearch URL'
      method_option :volume, type: :string, aliases: '-v', required: true, desc: 'Block Volume'
      def snapshot
        Snapshot.new(url: options[:url], volume: options[:volume]).call
      end

      desc "version", "Display version information"
      def version
        say("Elasticsnap: #{Elasticsnap::VERSION}", :yellow)
      end
    end
  end
end

require 'thor'

module Elasticsnap
  module Cli
    class Base < Thor
      include Thor::Actions

      def self.exit_on_failure?
        true
      end

      # Fixes thor's banners when used with :default namespace
      def self.banner(command, namespace = nil, subcommand = false)
        "#{basename} #{command.formatted_usage(self, $thor_runner, subcommand)}"
      end
    end
  end
end

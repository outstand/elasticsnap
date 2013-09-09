require 'fog'

module Elasticsnap
  class Config
    def self.fog_connection
      Thread.current[:fog_connection] ||= self._fog_connection
    end

    private
    def self._fog_connection
      @connection ||= begin
                        if ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY']
                          Fog::Compute.new(
                            provider: 'AWS',
                            aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                            aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
                          )
                        else
                          Fog::Compute.new(provider: 'AWS', use_iam_profile: true)
                        end
                      end
    end
  end
end

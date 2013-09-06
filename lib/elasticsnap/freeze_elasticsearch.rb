module Elasticsnap
  class FreezeElasticsearch
    class Error < StandardError; end
    class FlushFailed < Error; end
    class DisableFlushFailed < Error; end
    class EnableFlushFailed < Error; end

    attr_accessor :url

    def initialize(url: nil)
      raise ArgumentError, 'url required' if url.nil?

      @url = url
    end

    def freeze(&block)
      begin
        flush
        disable_flush

        block.call unless block.nil?
      ensure
        enable_flush
      end
    end

    def flush
      Flex::Configuration.http_client.base_uri = url
      result = Flex.flush_index(index: '_all')

      raise FlushFailed unless result.fetch('ok', false) == true

      result
    end

    def disable_flush
      Flex::Configuration.http_client.base_uri = url
      result = Flex.update_index_settings(
        index: '_all',
        data: {
          index: {
            translog: {
              disable_flush: true
            }
          }
        }
      )

      raise DisableFlushFailed unless result.fetch('ok', false) == true

      result
    end

    def enable_flush
      Flex::Configuration.http_client.base_uri = url
      result = Flex.update_index_settings(
        index: '_all',
        data: {
          index: {
            translog: {
              disable_flush: false
            }
          }
        }
      )

      raise EnableFlushFailed unless result.fetch('ok', false) == true

      result
    end
  end
end

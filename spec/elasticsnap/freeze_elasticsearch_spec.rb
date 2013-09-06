require 'spec_helper'

describe Elasticsnap::FreezeElasticsearch do
  it 'requires url' do
    expect { described_class.new }.to raise_error ArgumentError
  end

  let(:freeze) { described_class.new(url: 'localhost:9200')}
  let(:disable_flush_hash) do
    {
      index: '_all',
      data: {
        index: {
          translog: {
            disable_flush: true
          }
        }
      }
    }
  end
  let(:enable_flush_hash) do
    {
      index: '_all',
      data: {
        index: {
          translog: {
            disable_flush: false
          }
        }
      }
    }
  end

  before do
    allow(Flex).to receive(:flush_index).and_return({'ok' => true})
    allow(Flex).to receive(:update_index_settings).with(disable_flush_hash).and_return({'ok' => true})
    allow(Flex).to receive(:update_index_settings).with(enable_flush_hash).and_return({'ok' => true})
  end

  it 'flushes elasticsearch' do
    freeze.freeze
    expect(Flex).to have_received(:flush_index).with(index: '_all')
  end

  context 'when flushing fails' do
    before do
      allow(Flex).to receive(:flush_index).and_return({'ok' => false})
    end

    it 'raises FlushFailed' do
      expect { freeze.freeze }.to raise_error Elasticsnap::FreezeElasticsearch::FlushFailed
    end
  end

  it 'disables flushing' do
    freeze.freeze
    expect(Flex).to have_received(:update_index_settings).with(disable_flush_hash)
  end

  context 'when disable flushing fails' do
    before do
      allow(Flex).to receive(:update_index_settings).with(disable_flush_hash).and_return({'ok' => false})
    end

    it 'raises DisableFlushFailed' do
      expect { freeze.freeze }.to raise_error Elasticsnap::FreezeElasticsearch::DisableFlushFailed
    end
  end

  it 'calls the passed block' do
    block_called = false
    freeze.freeze do
      block_called = true
    end

    expect(block_called).to be_true
  end

  it 'enables flushing' do
    freeze.freeze
    expect(Flex).to have_received(:update_index_settings).with(enable_flush_hash)
  end

  context 'when enable flushing fails' do
    before do
      allow(Flex).to receive(:update_index_settings).with(enable_flush_hash).and_return({'ok' => false})
    end

    it 'raises EnableFlushFailed' do
      expect { freeze.freeze }.to raise_error Elasticsnap::FreezeElasticsearch::EnableFlushFailed
    end
  end

  context 'when an exception is raised from the block' do
    it 'enables flushing' do
      expect { freeze.freeze do
        raise 'BOOM'
      end }.to raise_error 'BOOM'
      expect(Flex).to have_received(:update_index_settings).with(enable_flush_hash)
    end
  end
end

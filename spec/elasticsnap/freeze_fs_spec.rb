require 'spec_helper'

describe Elasticsnap::FreezeFs do
  it 'requires mount' do
    expect { described_class.new }.to raise_error ArgumentError
  end

  it 'requires security_group' do
    expect { described_class.new(mount: 'asdf') }.to raise_error ArgumentError
  end

  let(:mount) { '/mnt/data' }
  let(:security_group) { 'group' }
  let(:freeze) { described_class.new(mount: mount, security_group: security_group) }

  before do
    allow(freeze).to receive(:run_command).with('sync')
    allow(freeze).to receive(:run_command).with('fsfreeze', '-f', mount)
    allow(freeze).to receive(:run_command).with('fsfreeze', '-u', mount)
  end

  it 'syncs the filesystem' do
    freeze.freeze
    expect(freeze).to have_received(:run_command).with('sync')
  end

  it 'freezes the filesystem' do
    freeze.freeze
    expect(freeze).to have_received(:run_command).with('fsfreeze', '-f', mount)
  end

  it 'calls the passed block' do
    block_called = false
    freeze.freeze do
      block_called = true
    end

    expect(block_called).to be_true
  end

  it 'unfreezes the filesystem' do
    freeze.freeze
    expect(freeze).to have_received(:run_command).with('fsfreeze', '-u', mount)
  end

  context 'when the block raises an exception' do
    it 'unfreezes the filesystem' do
      expect { freeze.freeze do
        raise 'BOOM'
      end }.to raise_error 'BOOM'
      expect(freeze).to have_received(:run_command).with('fsfreeze', '-u', mount)
    end
  end
end

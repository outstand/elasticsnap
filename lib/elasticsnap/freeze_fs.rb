require 'capistrano/cli'

module Elasticsnap
  class FreezeFs
    attr_accessor :mount
    attr_accessor :security_group
    attr_accessor :ssh_user

    def initialize(mount: nil, security_group: nil, ssh_user: nil)
      raise ArgumentError, 'mount required' if mount.nil?
      raise ArgumentError, 'security_group required' if security_group.nil?

      @mount = mount
      @security_group = security_group
      @ssh_user = ssh_user
    end

    def freeze(&block)
      begin
        sync
        freeze_fs

        block.call unless block.nil?
      ensure
        unfreeze_fs
      end
    end

    def sync
      run_command('sync')
    end

    def freeze_fs
      run_command 'fsfreeze', '-f', mount
    end

    def unfreeze_fs
      run_command 'fsfreeze', '-u', mount
    end

    private
    def run_command(*command)
      stream(*command)
    end

    def stream(*command)
      command = [command].flatten.join(' ')
      capistrano_config.stream(command, hosts: SecurityGroup.new(name: security_group).ssh_hosts(ssh_user))
    end

    def capistrano_config
      @cap_config ||= Capistrano::Configuration.new
    end
  end
end

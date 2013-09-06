require 'elasticsnap/cli/application'

class ThorMain
  def initialize(argv, stdin, stdout, stderr, kernel)
    @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
  end

  def execute!
    $stdin  = @stdin
    $stdout = @stdout
    $stderr = @stderr

    Elasticsnap::Cli::Application.start(@argv)
    @kernel.exit(0)
  end
end

Aruba::InProcess.main_class = ThorMain
Aruba.process = Aruba::InProcess

def start(command, *args)
  cmd = './../../bin/elasticsnap'
  cmd << " #{command}" if command
  cmd << " #{args.join(' ')}" if args
  run_simple cmd
end

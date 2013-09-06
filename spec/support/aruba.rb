def start(command, *args)
  cmd = './../../bin/elasticsnap'
  cmd << " #{command}" if command
  cmd << " #{args.join(' ')}" if args
  run_simple cmd
end

function df -d "Display available diskspace" --no-scope-shadowing
  set command_alternatives dfc discus df
  # Command specific parameters
  set dfc "-T -t -tmpfs,devtmpfs,ecryptfs"

  for i in (seq (count $command_alternatives))
    set alternative $command_alternatives[$i]
    if command_exists $alternative
      set args $$command_alternatives[$i]
      eval (which $alternative) $args $argv
      break
    end
  end
end

function l -d "One letter ls -l alias"
  set -l param -lh --color=auto

  if isatty 1
    set param $param --indicator-style=classify
  end

  command ls $param $argv
end

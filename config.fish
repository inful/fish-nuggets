type byobu > /dev/null
if [ $status = 0 -a "$SSH_CLIENT" -a $TERM != "dumb" -a $TERM != "screen" ]
  exec byobu-launcher
else
   if status --is-interactive
      for p in /usr/bin /usr/local/bin /usr/local/sbin /opt/local/bin ~/.config/fish/bin ~/.local/bin ~/bin ~/scripts
         if test -d $p
            set PATH $p $PATH
         end
      end
   end

   set fish_greeting ""
   set -x CLICOLOR 1

   function parse_git_branch
      sh -c 'git branch --no-color 2> /dev/null' | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
   end

   function parse_svn_tag_or_branch
           sh -c 'svn info | grep "^URL:" | egrep -o "(tags|branches)/[^/]+|trunk" | egrep -o "[^/]+$"'
   end

   function parse_svn_revision
      sh -c 'svn info 2> /dev/null' | sed -n '/^Revision/p' | sed -e 's/^Revision: \(.*\)/\1/'
   end

   function parse_git_status
      git diff --quiet HEAD ^&-
      if test $status = 1
         printf ' %s≠%s%s' (set_color red) (git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/*\(.*\)/\1/') (set_color normal)
      else
         printf '%s%s%s' (set_color blue) (git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/*\(.*\)/\1/') (set_color normal)
      end
   end

   # Better (imho) Git prompt than the default from fish nuggets
   function fish_prompt -d "Write out the prompt"
      # User
      printf '%s%s%s ' (set_color yellow)(whoami)(set_color white)

      # Host (if remote)
      set --query SSH_CLIENT; and printf '%s %s %s' at (set_color red)(hostname|cut -d . -f 1)(set_color white)

      # Path
      printf 'in '
      # Color writeable dirs green, read-only dirs red
      if test -w "."
         printf '%s%s' (set_color green) (prompt_pwd)
      else
         printf '%s%s' (set_color red) (prompt_pwd)
      end

      if test -d ".svn"
         # Print subversion tag or branch
         printf ' %s%s%s' (set_color normal) (set_color blue) (parse_svn_tag_or_branch)
         # Print subversion revision
         printf '%s%s@%s' (set_color normal) (set_color blue) (parse_svn_revision)
      end

      # Print git branch
      printf '%s%s' (set_color normal) (parse_git_status)
      printf '%s> ' (set_color -o white)

      #Put dir in z history
      z --add (pwd)

      #Tell vre about dir so that it can open new tabs here
      if test "$COLORTERM" = "gnome-terminal"
        printf "\033]7;file://%s%s\a" (hostname) (pwd)
      end
   end

   # yarrr, add /var/lib/gems/1.8/bin to path so gems installed by the retarded ubuntu rubygems package are on the path
   set CUSTOM_GEM_PATH "/var/lib/gems/1.8/bin"
   if test -d $CUSTOM_GEM_PATH
       set -x PATH $PATH "/var/lib/gems/1.8/bin"
   end

   # Load custom settings for current hostname
   set HOST_SPECIFIC_FILE ~/.config/fish/(hostname).fish
   if test -f $HOST_SPECIFIC_FILE
      . $HOST_SPECIFIC_FILE
   else
      echo Creating host specific file: $HOST_SPECIFIC_FILE
      touch $HOST_SPECIFIC_FILE
   end

   # Load custom settings for current user
   set USER_SPECIFIC_FILE ~/.config/fish/(whoami).fish
   if test -f $USER_SPECIFIC_FILE
      . $USER_SPECIFIC_FILE
   else
      echo Creating user specific file: $USER_SPECIFIC_FILE
      touch $USER_SPECIFIC_FILE
   end

   # Load custom settings for current OS
   set PLATFORM_SPECIFIC_FILE ~/.config/fish/(uname -s).fish
   if test -f $PLATFORM_SPECIFIC_FILE
      . $PLATFORM_SPECIFIC_FILE
   else
      echo Creating platform specific file: $PLATFORM_SPECIFIC_FILE
      touch $PLATFORM_SPECIFIC_FILE
   end
end

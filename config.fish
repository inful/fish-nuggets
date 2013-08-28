type byobu > /dev/null 
if [ $status = 0 -a -z "$DISPLAY" -a $TERM != "dumb" -a $TERM != "screen" ] 
  exec byobu-launcher;
else
   if status --is-interactive
      for p in /usr/bin /usr/local/bin /opt/local/bin ~/.config/fish/bin ~/.local/bin
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
      printf '%s %s %s %s ' (set_color yellow)(whoami)(set_color white) at (set_color red)(hostname|cut -d . -f 1)(set_color white) in

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
   end

   bind \cr "rake"

   function ss -d "Run the script/server"
      script/server
   end

   function sc -d "Run the Rails console"
      script/console
   end

   if test -d "/opt/java"
      set -x JAVA_HOME "/opt/java"
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

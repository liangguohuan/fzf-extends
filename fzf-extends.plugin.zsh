#=======================================================================================================================
#=> function helper
#=======================================================================================================================
is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

# compatible
if [[ "$OSTYPE" == "darwin"* ]]; then
  OPENCOMD=open
else
  OPENCOMD=xdg-open
fi

#=======================================================================================================================
#=> Fzf extends
#=======================================================================================================================
#=> fasd
alias z="fcd"
alias j="fcd"

# Modified version where you can press
#   - CTRL-O to open with `xdg-open` command,
#   - Type any other key will open with the vi if filetype is text else open with xdg-open
fo() {
  local out file key
  IFS=$'\n' out=($(fzf --cycle --bind 'tab:down,btab:up' --query="$(echo $*)" --select-1 --exit-0 --expect=ctrl-o))
  key=$(head -1 <<< "$out")
  file=$(head -2 <<< "$out" | tail -1)
  if [ -n "$file" ]; then
    if [ "$key" = ctrl-o ]; then
      $OPENCOMD "$file" &>/dev/null 
    else
      file -b "$file" | grep -q "text" && vi "$file" || $OPENCOMD "$file" &>/dev/null
    fi
  fi
}

# ff - fuzzy open with vim from anywhere if filetype is text else open with xdg-open
# ex: ff word1 word2 ... (even part of a file name)
ff() {
  local files filesvi
  IFS=$'\n' files="$(fasd -Rfl "$1" | fzf --query="$*" -1 -0 --no-sort -m)"
  for file in $(echo "$files"); do
    if [ -f "$file"  ]; then
      file -b "$file" | grep -q "text" && filesvi="$filesvi $file" || $OPENCOMD "$file" &>/dev/null
    fi
  done
  if [ -n "$filesvi" ]; then
    eval "vi $filesvi"
  fi
}

# fcd - fuzzy cd from anywhere
# ex: cd word (even part of a dir name)
fcd() {
  local dir
  dir="$(fasd -Rdl "$1" | fzf --query="$*" --cycle --bind 'tab:down,btab:up' -1 -0 --no-sort)" && cd "${dir}" || return 1
}

# fb - fuzzy cd from ~/.bookmarks
# ex: cd word (even part of a dir name)
fb() {
  local dir
  dir="$(cat ~/.bookmarks |
  sed -r 's/\s*(#.*)/\x1b[38;5;8m  \1\x1b[0m/' |
  fzf --cycle --bind 'tab:down,btab:up' --ansi -1 -0 --no-sort -q "$1")" && cd "${dir}" || return 1
}

#=> Git widget
fzf-gitlog-widget() {
  is_in_git_repo || return
  git log-timeline |
  fzf -e --header="ctrl+t: toggle preview, enter: open git index file" \
  --ansi \
  --margin 0,0,5% \
  --height=100% \
  --preview-window right:50% \
  --preview "echo {} | grep -o '[a-f0-9]\{7\}' | head -1 |
             xargs -I % sh -c 'git show --color=always %'" \
  --bind "tab:down,btab:up,ctrl-t:toggle-preview,enter:execute:echo {} | grep -o '[a-f0-9]\{7\}' | head -1 |
              xargs -I % sh -c 'vim fugitive://\$(git rev-parse --show-toplevel)/.git//% < /dev/tty'"
}

fzf-gitalias-widget() {
  is_in_git_repo || return
  local out keyword
  out=$(git alias | awk -F "=" '{printf "%-20s -- %s\n",$1,$2}' | fzf --exact)
  keyword=$(echo "$out" | cut -d ' ' -f1) 
  LBUFFER=$(echo "${LBUFFER}${keyword}")
  zle redisplay
}

fzf-gitstatus-widget() {
  is_in_git_repo || return
  local out filename
  out="$(git status | 
    grep -o 'modified:.*' | 
    sed 's/modified:/M /' |
    fzf \
      --bind "tab:down,btab:up" \
      --cycle \
      --exact \
      --height=100% \
      --preview-window right:70% \
      --preview="echo {} | awk '{print \$2}' | xargs -I % sh -c 'git diff --color=always HEAD %'")"
  filename=$(awk '{print $2}' <<< $out) 
  if [ -n "$filename" ]; then
    vim "$filename" < /dev/tty
  fi
}

zle -N fzf-gitlog-widget
zle -N fzf-gitalias-widget
zle -N fzf-gitstatus-widget
bindkey '^g^v' fzf-gitlog-widget
bindkey '^g^i' fzf-gitalias-widget
bindkey '^g^s' fzf-gitstatus-widget

#=> htmldocs search engine via ag and fzf
fzf-htmldocs-search() {
  local out file key
  sdir="$1"
  IFS=$'\n' out=($( \
    ag -G 'html$' '.' "$sdir" |
    sed -r \
      -e "s#$1/##" -e 's/<[^>]+>//g' \
      -e '/<!--/,/-->/d' \
      -e 's/&nbsp;/ /g' -e 's/&gt;/>/g' -e 's/&lt;/</g' \
      -e 's/:([0-9]+):\s*(\W|[0-9])*/:\x1b[38;5;11m\1\x1b[0m:/' |
    grep -P -v ':.{0,10}\s*$' |
    fzf --exact \
      --header "$sdir" \
      --ansi \
      --margin 0,0,5% \
      --height=100% \
      --bind 'tab:down,btab:up,ctrl-t:toggle-preview' \
      --query="$2" \
      --select-1 \
      --exit-0 \
      --expect=ctrl-o,ctrl-e,enter))
  key=$(head -1 <<< "$out")
  matchline=$(head -2 <<< "$out" | tail -1)
  if [ "$key" = enter ]; then
    IFS=$' ' read file line linecontent <<< $(echo $matchline | awk -F ':' '{printf "%s %s %s",$1,$2,$3}')
    $OPENCOMD "$sdir/$file" &>/dev/null
    if [ -n "$linecontent" ]; then
      echo ${linecontent:0:20} | clipcopy
      sleep 1
      if type xdotool &> /dev/null; then
          xdotool key --delay 300 ctrl+f ctrl+v
      fi
    fi
    echo ":"$linecontent
  fi
}

#=======================================================================================================================
#=> auto complete
#=======================================================================================================================
_autocomplet_arrlist=(j z fo ff fcd fb)
zic-completion() {
  setopt localoptions noshwordsplit noksh_arrays noposixbuiltins
  local tokens cmd
  tokens=(${(z)LBUFFER})
  cmd=${tokens[1]}
  if [ ${_autocomplet_arrlist[(r)$(echo $cmd)]} ]; then
    if type xdotool &> /dev/null; then
        [ "${LBUFFER:${#cmd}:1}" = " " ] && xdotool key ctrl+m || zle ${__zic_default_completion:-expand-or-complete}
    else
        [ "${LBUFFER:${#cmd}:1}" = " " ] && cliclick kp:enter || zle ${__zic_default_completion:-expand-or-complete}
    fi
  else
    zle ${__zic_default_completion:-expand-or-complete}
  fi
}

zle -N zic-completion
bindkey '^I' zic-completion

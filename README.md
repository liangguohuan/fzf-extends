# Some function and ZLE widgets extend fzf in zsh

## Depends
- [zsh](http://www.zsh.org/) more powerful then bash  
- [fzf](https://github.com/junegunn/fzf) A command-line fuzzy finder written in Go
- [fasd](https://github.com/clvv/fasd) offers quick access to files and directories, inspired by autojump, z and v  
- [ag](https://github.com/ggreer/the_silver_searcher#linux) A code-searching tool similar to ack, but faster
- [fd](https://github.com/sharkdp/fd) A simple, fast and user-friendly alternative to 'find'

## j 
alias fcd

## z 
alias fgd

## fo
Open file with smart  
  - Ctrl+O to open with `xdg-open` command,
  - Type any other key will open with the vi if filetype is text else open with xdg-open

## ff
Fuzzy open with vim from anywhere if filetype is text else open with xdg-open  
`ff word1 word2 ...` (even part of a file name)

## fb
Fuzzy cd from ~/.bookmarks  
`fb word ...` (even part of a dir name)

## fcd
Fuzzy cd from anywhere via fasd result  
`fcd word ...` (even part of a dir name)

## fgd
Fuzzy cd from anywhere via fd result  
`fgd word ...` (even part of a dir name)

## fzf-gitlog-widget
Need git alias 
```
log-timeline = log --date=short --format='%Cred%h %C(yellow)%ar %Creset- %s %Cgreen%ad %Cblue%an'
```
git log show bind key <kbd>ctrl</kbd>+<kbd>g</kbd>+<kbd>ctrl</kbd>+<kbd>v</kbd>

## fzf-gitalias-widget
git alias show bind key <kbd>ctrl</kbd>+<kbd>g</kbd>+<kbd>ctrl</kbd>+<kbd>i</kbd> 

## fzf-gitstatus-widget
git status show bind key <kbd>ctrl</kbd>+<kbd>g</kbd>+<kbd>ctrl</kbd>+<kbd>s</kbd> 

## fzf-htmldocs-search
htmldocs search engine via ag and fzf  
`fzf-htmldocs-search path word ...`

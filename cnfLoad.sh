#!/usr/bin/env bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

### 
# Export awesome folder as simlink
################################################################################
### Awesome config
awesome_trgt_path=~/.config/nvim/init.vim
ln -i -s $SCRIPTPATH $awesome_trgt_path

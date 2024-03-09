# Claas Heuer, November 2015
#
# Setup Powerline on Debian and Centos for BASH, VIM and TMUX
# source: https://fedoramagazine.org/add-power-terminal-powerline/


# install on debian
sudo apt-get install python-pip
sudo apt-get install powerline

# Centos
sudo yum install python-pip
pip install --user powerline-status

# export path where powerline lives
echo export PATH=${PATH}:~/.local/bin >> ~/.bashrc

############
### BASH ###
############

## Tweak bashrc and config files
# find the daemon
bash_powerline_loc=$(sudo find / | grep -E 'bash.*powerline.sh')
chmod +x $bash_powerline_loc
# find the bash script
powerline_daemon_loc=$(sudo find / | grep powerline-daemon)
# put this in ~/.bashrc
echo "
if [ -f `which powerline-daemon` ]; then 
  ${bash_powerline_loc} -q 
  POWERLINE_BASH_CONTINUATION=1 
  POWERLINE_BASH_SELECT=1 
  . ${bash_powerline_loc} 
fi"


############
### TMUX ###
############

# find the conf
tmux_powerline_loc=$(sudo find / | grep -E 'tmux.*powerline.conf')

# add to .tmux.conf
echo source ${tmux_powerline_loc}  >> ~/.tmux.conf

# Note: tmux might not run in 256 color mode,
# can change that by using tmux -2; 
# export alias tmux="tmux -2" >> ~/.bashrc

###########
### VIM ###
###########

# find the vim script
vim_powerline=$(sudo find / | grep  "powerline\.vim")

# add to ~/-vimrc
echo "set rtp+='"${vim_powerline}"'
set laststatus=2 
set t_Co=256" >> ~/.vimrc

# tabs in Vim
# https://github.com/fweep/vim-tabber

# first install vim-pathogen
sudo apt-get install vim-pathogen

# add this to ~/.vimrc: execute pathogen#infect()
# now packages can very easily be installed

cd ~/.vim/bundle
git clone https://github.com/fweep/vim-tabber.git

# put this to ~/.vimrc: set tabline=%!tabber#TabLine()" >> ~/.vimrc


# color schemes: https://github.com/flazz/vim-colorschemes
# nice color scheme: https://github.com/altercation/vim-colors-solarized

#########################
### Best color scheme ###
#########################

cd ~/.vim/bundle
git clone https://github.com/morhetz/gruvbox


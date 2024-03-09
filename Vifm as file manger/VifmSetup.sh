# Claas Heuer, July 2016
#
# Vifm is a midnight commander like two-pane file
# manager for the terminal.
# Very intuitive to use for vim users
#
# https://github.com/vifm/vifm
# https://github.com/vifm/vifm-colors
# http://vifm.info/colorschemes.shtml
# http://vifm.info/manual.shtml#Pane manipulation

# get it
sudo apt-get install vifm

# get colorschemes
rm -rf ~/.vifm/colors
git clone https://github.com/vifm/vifm-colors ~/.vifm/colors

# set nice colorscheme as default
echo "colorscheme zenburn_1.vifm" >> ~/.vifm/vifmrc
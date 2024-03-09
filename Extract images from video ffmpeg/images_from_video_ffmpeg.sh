# Claas Heuer, October 2015
#
# first get ffmpeg (http://superuser.com/a/865744)
sudo echo deb http://www.deb-multimedia.org stable main non-free  >> /etc/apt/sources.list
sudo apt-get update
sudo apt-get install deb-multimedia-keyring
sudo apt-get update
sudo apt-get install ffmpeg

# go to video directory and extract images (http://unix.stackexchange.com/a/185879)
# -r indicates how many frames per second
ffmpeg -i inputfile.avi -r 1 -f image2 image-%3d.jpeg

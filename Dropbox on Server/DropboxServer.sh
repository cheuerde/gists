# Claas Heuer, July 2016
#
# Run Dropbox on a linux server

# from here: https://www.dropbox.com/install?os=lnx

# get and extract dropbox
cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -

# run for first time ussing x-forwarding and setup sync
~/.dropbox-dist/dropboxd

# get the python script and start dropbox silently
wget https://www.dropbox.com/download?dl=packages/dropbox.py -O ~/.dropbox-dist/dropbox.py
chmod +x ~/.dropbox-dist/dropbox.py

# start
~/.dropbox-dist/dropbox.py start

# autostart
echo "~/.dropbox-dist/dropbox.py start" >> ~/.bashrc

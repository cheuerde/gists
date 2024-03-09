# Claas Heuer, Oxtober 2015
#
# Helpful:
# https://docs.docker.com/installation/debian/
# https://hub.docker.com/u/rocker/
# https://hub.docker.com/_/debian/
# https://zeltser.com/docker-application-distribution/
# https://hub.docker.com/
# First install Docker: http://docs.docker.com/linux/step_one/

# load a docker image (r-base from rocker)
sudo docker pull rocker/r-base

# run something from that container
N=10
sudo docker run -it -v /home:/media/host rocker/r-base Rscript -e "date();rnorm(${N})"

# Note: -v let us mount filesystems from the host to the container

# stop an image
# first list all containers
sudo docker ps -l

# terminate
sudo docker stop CONTAINER_ID


















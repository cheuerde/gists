# Claas Heuer, 2015

# MPI on multiple machines

# Create a host file with your nodes:

echo 134.245.125.192 slots=2 max-slots=2 > hosts
echo 134.245.125.226 slots=4 max-slots=4 >> hosts

# copy your program to all machines, simply create symbolic links
# to one of your direcotries in $PATH

# run the program

mpirun --hostfile hosts -np 6 echo hallo

# note: -np 6 will create 2 processes on first and 4 ond second note. if np<3, the program will only run on the first host!
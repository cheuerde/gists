# Claas Heuer, August 2015
#
# links:
# http://www.rackspace.com/knowledge_center/article/installing-mysql-server-on-debian
# http://www.thegeekstuff.com/2008/09/backup-and-restore-mysql-database-using-mysqldump/
# https://mkmanu.wordpress.com/2014/07/24/r-and-mysql-a-tutorial-for-beginners/
# http://stackoverflow.com/questions/15420999/rodbc-odbcdriverconnect-connection-error
# http://www.w3schools.com/sql/sql_join.asp


# install MySQL Server
sudo aptitude install mysql-server

# start 
sudo /etc/init.d/mysql start

# create database
/usr/bin/mysql -u root -p[root_password]
CREATE DATABASE recessives;
exit;

# get the database dump
# this is our source: http://omia.angis.org.au/home/
wget http://omia.angis.org.au/dumps/omia.sql.zip
gunzip omia.sql.zip

# get the dump in our newly created database
mysql -u root -p[root_password] recessives < omia.sql


# connect to database from shell
mysql -h localhost -u root -p[root_password] recessives

###
###

# start R

#install.packages("RMySQL")
library(RMySQL)

# setup connection
drv = dbDriver("MySQL")

con = dbConnect(drv,host="localhost",dbname="recessives",user="root",pass="[root_password]")

# list all tables in the database
dbListTables(con)

# read a table
dat = dbGetQuery(con,statement="select * from Article_Breed")





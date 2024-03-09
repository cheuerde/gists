
#################################
### Without R - just terminal ###
#################################

# we do what this guy propses: http://stackoverflow.com/a/149418/2748031

# or maybe this guy: http://richbs.org/post/43142767072/connecting-to-microsoft-sql-server-from-unix

# install required packages
sudo apt-get install freetds-dev unixodbc iodbc sqsh tdsodbc unixodbc-dev libmyodbc

# this is supoosed to help with windows encoding problems:
# add: client charset = UTF-8 to /etc/freetds/freetds.conf
su
echo client charset = UTF-8 >> /etc/freetds/freetds.conf

# add this to /etc/freetds/freetds.conf

# Daniels ST Server
[ST]
        host = 172.17.0.224
        port = 1433
        tds version = 8.0


# test connection
sqsh -S ST -U cheuer

# register driver
touch freetds-driver

# put this in there
[FreeTDS]
Description     = TDS driver (Sybase/MS SQL)
Driver      = /usr/lib/x86_64-linux-gnu/odbc/libodbcpsqlS.so


sudo odbcinst -d -i  -f freetds-driver

# put this into /etc/odbc.ini
[STdsn]
Driver = FreeTDS
Description = MSSQL database for my nice app
# Servername corresponds to the section in freetds.conf
Servername = ST
Database =

[STdsn]
Description     = ST
Driver          = FreeTDS
Trace           = Yes
TraceFile       = /tmp/odbc.trace
Database        = NSDEPT-Access
Server          = 172.17.0.224
Port            = 1433
TDS_Version = 8.0

# start SQL shell
isql -v STdsn cheuer

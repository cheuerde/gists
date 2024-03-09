# Claas Heuer, September 2015

# JDBC
sudo apt-get install libpostgresql-jdbc-java

# get MSSQL driver from Microsoft

wget http://download.microsoft.com/download/D/6/A/D6A241AC-433E-4CD2-A1CE-50177E8428F0/1033/sqljdbc_3.0.1301.101_enu.tar.gz

# unpack
tar -xf sqljdbc_3.0.1301.101_enu.tar.gz

# copy to /opt
sudo cp -r sqljdbc_3.0 /opt/

#################################
### In R we use RJDBC package ###
#################################

# source: http://www.cerebralmastication.com/2010/09/connecting-to-sql-server-from-r-using-rjdbc/

R

require(RJDBC)
drv <- JDBC("com.microsoft.sqlserver.jdbc.SQLServerDriver",
  "/opt/sqljdbc_3.0/enu/sqljdbc4.jar") 
  conn <- dbConnect(drv, "jdbc:sqlserver://servername", "userID", "password")
#then build a query and run it
sqlText <- paste("
   SELECT * FROM myTable
  ", sep="")
dat <- dbGetQuery(conn, sqlText)

# get dabases
sqlText <- "
SELECT [name] 
FROM master.dbo.sysdatabases 
WHERE dbid > 4 
"

dbGetQuery(conn, sqlText)

# get my tables
sqlText <- "
SELECT TABLE_NAME FROM Claas.INFORMATION_SCHEMA.Tables 
"

dbGetQuery(conn, sqlText)


####################################################################
### A Linux alternative to MySQL Workbench that works with MSSQL ###
### DBEAVER                                                      ###
####################################################################

http://dbeaver.jkiss.org/download/

# software will download necessary MSSQL driver automatically!!




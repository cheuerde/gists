# Claas Heuer, October 2015

insert_sql <- function(conn, # the RJDBC connection
                       table, # the table in the database
                       dat, # an R dataframe
                       cols = NULL, # which columns to insert (non selected will be filled with NULL)
                       start_row = NULL, # from which row in 'dat' to start
                       end_row = NULL,  # at which row in 'dat' to stop
                       verbose = TRUE) # print progress to the screen

{

##########################
### get column classes ###
##########################

# we fetch the first row of the table and use the colclasses of the
# returned dataframe
  query <- paste("SELECT * from ",table,sep="")
  col_classes_sql <- unlist(lapply(fetch(dbSendQuery(conn, query), n = 1),class))
  col_classes_dat <- unlist(lapply(dat,class))

# check if colnames match
  if(any(toupper(names(col_classes_sql)) != toupper(names(col_classes_dat)))) stop("Column Names Differ")

# check if colclasses match
  if(any(col_classes_sql != col_classes_dat)) stop("Column Classes Differ")

###############################
### which columns to insert ###
###############################

# Note: columns not inserted will be filled with NULL/nothing
  if(is.null(cols)) cols <- names(col_classes_sql)

  if(!any(toupper(cols) %in% toupper(names(col_classes_sql)))) stop("Not all selected Columns are in the database table")

##########################
### Loop over the rows ###
##########################

# control start and end
  if(is.null(start_row)) start_row = 1
  if(is.null(end_row)) end_row = nrow(dat)

  if(start_row < 1) start_row = 1
  if(start_row > nrow(dat)) start_row = nrow(dat)
  if(end_row > nrow(dat)) end_row = nrow(dat)
  if(end_row < 1) end_row = 1

  if(end_row < start_row) stop("end_row smaller than start_row")

# set what cols are characters
  char_cols <- col_classes_sql=="character"

# loop over rows and make the queries
  pb <- txtProgressBar(min = start_row, max = end_row, style = 3)
  for(i in start_row:end_row) {

    this_row <- as.character(dat[i,])
# NAs will simply not be inserted
    is_na <- this_row == "NA"
    this_row[char_cols] <- paste("'",this_row[char_cols],"'",sep="")
    this_row <- this_row[!is_na]

    query <- paste0(
    "INSERT INTO ",table, " (",paste(cols[!is_na],collapse=","),")
    VALUES(",paste(this_row, collapse=","),")")

    dbSendUpdate(conn, query)

    if(verbose) setTxtProgressBar(pb, i)

  }

}



#' Join 1km Census attributes
#' 
#' @description 
#' Takes a dataframe as input, and joins 1km Census attributes on the INSPIRE ID
#' 
#' @usage 
#' z11_join_db_1km(df, inspire_column, con, var = NULL)
#' 
#' @param df A dataframe
#' @param A string containing the name of the 1km INSPIRE ID in the dataframe
#' @param con Connection to a database. Open with DBI::dbConnect, and remember to close it later.
#' @param var Optional. The name of a census variable as a string, or several variable names as a string vector. If no variable name is given, all 1km attributes will be joined to the dataframe.
#' 
#' @examples 
#' con <- dbConnect(RSQLite::SQLite(), "/path/to/db.sqlite3")
#' z11_join_db_1km(df, "inspire_id", con, c("Frauen_A", "Frauen_A_cat"))
#' dbDisconnect(con)
#' 
#' @importFrom magrittr %>%
#' @importFrom DBI dbWriteTable dbSendQuery dbFetch dbClearResult
#' @importFrom dplyr select bind_cols
#' 
#' @export
z11_join_db_1km <- function(df, inspire_column, con, var = NULL) {
  message("Prepare for joining...")
  #input <- data.frame(Gitter_ID_1km = gsub("^1km|[^0-9]", "", df[[inspire_column]]))
  input <- data.frame(Gitter_ID_1km = df[[inspire_column]])
  
  DBI::dbWriteTable(con, "temp", input, temporary = TRUE, overwrite = TRUE)
  
  message("Join data...")
  if (is.null(var)) {
    #Join all 1km variables
    query <- "SELECT * from temp 
    LEFT JOIN spitz1km USING (Gitter_ID_1km)
    LEFT JOIN klassiert1km USING (Gitter_ID_1km);"
  } else {
    #Only join select 1km variables
    tables <- ifelse(grepl("\\_cat$", var), "klassiert1km", "spitz1km")
    tables_query <- paste("LEFT JOIN", unique(tables), "USING (Gitter_ID_1km)",
                          sep = " ", collapse = "\n")
    vars_query <- paste(var, collapse = ", ")
    query <- sprintf("SELECT Gitter_ID_1km, %s from temp %s;", vars_query, tables_query)
  }
  
  res <- DBI::dbSendQuery(con, query)
  output <- DBI::dbFetch(res) %>%
    dplyr::select(-Gitter_ID_1km)
  DBI::dbClearResult(res)
  
  message("Done!")
  return(
    dplyr::bind_cols(df, output)
  )
}
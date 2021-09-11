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
#' @param var The name of a Census variable. Optional. If no variable name is given, all 1km attributes will be joined to the dataframe.
#' 
#' @examples 
#' con <- dbConnect(RSQLite::SQLite(), "/path/to/db.sqlite3")
#' z11_join_db_1km(df, "inspire_id", con, "Frauen_A_cat")
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
    query <- "SELECT * from temp 
    LEFT JOIN spitz1km USING (Gitter_ID_1km)
    LEFT JOIN klassiert1km USING (Gitter_ID_1km);"
  } else {
    table <- ifelse(grepl("\\_cat$", var), "klassiert1km", "spitz1km")
    query <- sprintf("SELECT Gitter_ID_1km, %s from temp
    LEFT JOIN %s USING (Gitter_ID_1km);", var, table)
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
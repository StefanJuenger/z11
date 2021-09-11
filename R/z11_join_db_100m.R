#' Join 100m Census attributes
#' 
#' @description 
#' Takes a dataframe as input, and joins 100m Census attributes on the INSPIRE ID
#' 
#' @usage 
#' z11_join_db_100m(df, inspire_column, con, var = NULL)
#' 
#' @param df A dataframe
#' @param A string containing the name of the 100m INSPIRE ID in the dataframe
#' @param con Connection to a database. Open with DBI::dbConnect, and remember to close it later.
#' @param var The name of a Census variable. Optional. If no variable name is given, all 100m attributes will be joined to the dataframe.
#' 
#' @examples 
#' con <- dbConnect(RSQLite::SQLite(), "/path/to/db.sqlite3")
#' z11_join_db_100m(df, "inspire_id", con, "GEB_HEIZTYP_1")
#' dbDisconnect(con)
#' 
#' @importFrom magrittr %>%
#' @importFrom DBI dbWriteTable dbSendQuery dbFetch dbClearResult
#' @importFrom dplyr select bind_cols
#' 
#' @export
z11_join_db_100m <- function(df, inspire_column, con, var = NULL) {
  message("Prepare for joining...")
  input <- data.frame(Gitter_ID_100m = gsub("^100m|[^0-9]", "", df[[inspire_column]]))
  
  DBI::dbWriteTable(con, "temp", input, temporary = TRUE, overwrite = TRUE)
  
  message("Join data...")
  if (is.null(var)) {
    query <- "SELECT * from temp 
    LEFT JOIN bevoelkerung100m USING (Gitter_ID_100m)
    LEFT JOIN demographie100m USING (Gitter_ID_100m)
    LEFT JOIN haushalte100m USING (Gitter_ID_100m)
    LEFT JOIN familien100m USING (Gitter_ID_100m)
    LEFT JOIN gebaeude100m USING (Gitter_ID_100m)
    LEFT JOIN wohnungen100m USING (Gitter_ID_100m);"
  } else {
    table <- c("Ein" = "bevoelkerung100m", "DEM" = "demographie100m", "HAU" = "haushalte100m", 
               "FAM" = "familien100m", "GEB" = "gebaeude100m", "WOH" = "wohnungen100m")[
                 substring(var, 1, 3)
               ]
    query <- sprintf("SELECT Gitter_ID_100m, %s from temp
    LEFT JOIN %s USING (Gitter_ID_100m);", var, table)
  }
  
  res <- DBI::dbSendQuery(con, query)
  output <- DBI::dbFetch(res) %>%
    dplyr::select(-Gitter_ID_100m)
  DBI::dbClearResult(res)
  
  message("Done!")
  return(
    dplyr::bind_cols(df, output)
  )
}
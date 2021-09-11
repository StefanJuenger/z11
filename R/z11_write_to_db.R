#' Add 2011 Census data to SQLite Database
#' 
#' @description 
#' Add a Census .csv file to a SQLite Database
#' 
#' @usage 
#' z11_write_to_db(name, file = NULL, con)
#' 
#' @param file Path to the .csv file
#' @param con Connection to a database. Open with DBI::dbConnect, and remember to close it later.
#' 
#' @details 
#' The data files are very large and use a lot of RAM, so use with caution. Don't run other things in the background.
#' 
#' @examples 
#' con <- dbConnect(RSQLite::SQLite(), "/path/to/db.sqlite3")
#' z11_fill_db("/home/yourname/Familien100m.csv", con = con)
#' dbDisconnect(con)
#' 
#' @importFrom magrittr %>%
#' @importFrom data.table fread setnames dcast setorder
#' @importFrom DBI dbConnect dbWriteTable dbDisconnect
#' @importFrom RSQLite SQLite
#' 
#' @export

z11_write_to_db <- function(file = NULL, con) {
  #Read data
  message("Reading file...")
  df <- data.table::fread(file, encoding = "Latin-1")
  
  #Prepare data
  message("Transforming data...")
  if (ncol(df) == 7) {
    identifier <- df$Merkmal[3]
    name <- switch(identifier, ALTER_KURZ = "demographie100m", FAMGROESS_KLASS = "familien100m", 
                   ZAHLWOHNGN_HHG = "gebaeude100m", WOHNEIGENTUM = "wohnungen100m", HHTYP_LEB = "haushalte100m")
    message("    Transform INSPIRE ID to numeric")
    df[, Gitter_ID_100m := as.numeric(gsub("^100m|[^0-9]", "", Gitter_ID_100m))]
    
    message("    Transform to wide format")
    df <- data.table::dcast(df, Gitter_ID_100m ~ Merkmal + Auspraegung_Code, value.var = "Anzahl")
    
    message("    Change variable names")
    prefix <- toupper(substring(name, 1, 3))
    colns <- colnames(df)
    colns <- c(colns[1], paste(prefix, colns[2:length(colns)], sep = "_"))
    setnames(df, colns)
    
    message("    Order by INSPIRE ID")
    data.table::setorder(df, Gitter_ID_100m)
    
  } else if ("x_mp_100m" %in% colnames(df)) {
    # 100m Bevoelkerung
    name <- "bevoelkerung100m"
    message("    Transform INSPIRE ID to numeric")
    df[, Gitter_ID_100m := as.numeric(gsub("^100m|[^0-9]", "", Gitter_ID_100m))]
    
    message("    Select and rename columns")
    df <- df[, .(Gitter_ID_100m, Einwohner)]
    data.table::setnames(df, old = "Einwohner", new = "Einwohner_100m")
    
    message("    Order by INSPIRE ID")
    data.table::setorder(df, Gitter_ID_100m)
    
  } else if ("x_mp_1km" %in% colnames(df)) {
    # 1km Data
    message("    Transform INSPIRE ID to numeric")
    df[, Gitter_ID_1km := as.numeric(gsub("^1km|[^0-9]", "", Gitter_ID_1km))]
    
    message("    Select and rename columns")
    df <- df[,.SD, .SDcols = !c('x_mp_1km', 'y_mp_1km')]
    name <- "spitz1km"
    if (df[Wohnfl_Whg_D >= 0, .N] > 100000) {
      colns <- colnames(df)
      colns <- c(colns[1], paste(colns[2:length(colns)], "cat", sep = "_"))
      setnames(df, colns)
      name <- "klassiert1km"
    }
    
    message("    Order by INSPIRE ID")
    data.table::setorder(df, Gitter_ID_1km)
    
  } else {
    stop("Something went wrong. Is this a correct 2011 Census .csv file?")
  }
  
  message(sprintf("Writing %s to database...", name))
  DBI::dbWriteTable(con, name, df, overwrite = TRUE)
  
  message("Cleaning up...")
  rm(df)
  invisible(gc())
}


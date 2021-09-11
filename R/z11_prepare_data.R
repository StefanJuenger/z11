#' Data Preparation
#' 
#' @description 
#' Reads in 2011 Census .csv files, splits it into smaller chunks, and saves it locally.
#' 
#' @usage 
#' z11_prepare_data(file, directory)
#' 
#' @param file Path to a either a census .csv file or a directory where the .csv files are saved
#' @param directory Path to the directory where the data should be saved.
#' 
#' @details 
#' The data files are very large and use a lot of RAM, so use with caution. Don't run other things in the background.
#' 
#' @examples 
#' z11_prepare_data("/home/yourname/Haushalte100m.csv", "/home/yourname/z11data")
#' 
#' @importFrom purrr walk
#' @importFrom magrittr %>%
#' @importFrom data.table fread setDT setnames
#' 
#' @export
z11_prepare_data <- function(file, directory) {
  if (dir.exists(file)) {
    #If file path is directory, read in all .csv files from directory
    files <- list.files(file, full.names = TRUE, pattern = "\\.csv$|\\.CSV$")
    purrr::walk(files, ~z11_prepare_data(file = .x, directory = directory))
    
  } else if (file.exists(file)) {
    
    #Read data
    message("Reading file...")
    df <- data.table::fread(file, encoding = "Latin-1")
    
    #100m grid data
    if (ncol(df) == 7) {
      identifier <- df$Merkmal[3]
      name <- switch(identifier, ALTER_KURZ = "demographie100m", FAMGROESS_KLASS = "familien100m", 
                     ZAHLWOHNGN_HHG = "gebaeude100m", WOHNEIGENTUM = "wohnungen100m", HHTYP_LEB = "haushalte100m")
      
      #Revome trailing whitespaces, paste Mermal and Auspraegung_Code columns together
      message("Clean up strings...")
      df <- df[, merkm := paste(trimws(Merkmal), Auspraegung_Code, sep = "_")]
      
      message("Transform and save data...")
      #Create subdirectory if it doesn't exist
      if (!dir.exists(file.path(directory, "100m"))) {
        dir.create(file.path(directory, "100m"))
      }
      #Prefix for variable names ("GEB", "FAM", etc.)
      prefix <- substring(name, 1, 3) %>% toupper() %>% paste0("_")
      #Subset data, rename Variables, save
      purrr::walk(unique(df$merkm),
                  ~df[merkm == .x, .(Gitter_ID_100m, Anzahl)][, data.table::setnames(.SD, new = c("Gitter_ID_100m", paste0(prefix, .x)))] %>%
                    saveRDS(file = file.path(directory, "100m", paste0(prefix, .x, ".rds")))
      )
    } else if ("x_mp_100m" %in% colnames(df)) {
      #100m population data
      
      #Create subdirectory if it doesn't exist
      if (!dir.exists(file.path(directory, "100m"))) {
        dir.create(file.path(directory, "100m"))
      }
      
      message("Select and rename columns...")
      df <- df[, .SD, .SDcols = !c('x_mp_100m', 'y_mp_100m')]
      data.table::setnames(df, old = "Einwohner", new = "Einwohner_100m")
      
      message("Save data...")
      saveRDS(df, file = file.path(directory, "100m", "Einwohner_100m.rds"))
      
    } else if ("x_mp_1km" %in% colnames(df)) {
      #1km grid data
      
      #Create subdirectory if it doesn't exist
      if (!dir.exists(file.path(directory, "1km"))) {
        dir.create(file.path(directory, "1km"))
      }
      
      message("Select and rename columns")
      df <- df[,.SD, .SDcols = !c('x_mp_1km', 'y_mp_1km')]
      if (df[Wohnfl_Whg_D >= 0, .N] > 100000) {
        colns <- colnames(df)
        colns <- c(colns[1], paste(colns[2:length(colns)], "cat", sep = "_"))
        setnames(df, colns)
      }
      
      #Create vector of column names to loop over, get suffix for variable names
      colns <- colnames(df)[-1]
      
      #Select columns, rename and save
      message("Save data...")
      purrr::walk(colns,
                  ~df[, .(Gitter_ID_1km, get(.x))] %>%
                    saveRDS(file = file.path(directory, "1km", paste0(.x, ".rds"))))
    } else {
      stop("Something went wrong :( Is this a correct 2011 Census .csv file?")
    }
    
    message("Cleaning up...")
    rm(df)
    invisible(gc())
  } else {
    stop("Not a valid file or directory!")
  }
}


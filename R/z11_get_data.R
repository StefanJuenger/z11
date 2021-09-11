#' Download Zensus 2011 data
#' 
#' @description 
#' Downloads Zensus 2011 data, splits it into smaller chunks, and saves it locally.
#' 
#' @usage 
#' z11_get_data(name, directory, all = FALSE)
#' 
#' @param name Which dataset should be downloaded? Possible values are "klassiert1km", "spitz1km", "bevoelkerung100m", "demographie100m", "familien100m", "haushalte100m", "gebaude100m", "wohnungen100m".
#' @param directory Path to the directory where the data should be saved.
#' @param all Should all datasets be downloaded? Defaults to FALSE. Use with caution.
#' 
#' @details 
#' The data files are very large and use a lot of RAM, so use with caution. Don't run other things in the background.
#' This was tested on Ubuntu 18, and I can't guarantee that it works on anything else.
#' 
#' @examples 
#' z11_get_data("spitz1km", "/home/yourname/z11data")
#' 
#' @importFrom purrr walk
#' @importFrom magrittr %>%
#' @importFrom data.table fread setDT setnames
#' 
#' @export
z11_get_data <- function(name, directory, all = FALSE) {
  #If all = TRUE, run this function on all datasets
  if (isTRUE(all)) {
    purrr::walk(names(z11::z11_download_links), ~z11_get_data(name = .x, directory = directory))
  }
  #100m Gitterzellen
  else if (name %in% c("demographie100m", "familien100m", "haushalte100m", "gebaeude100m", "wohnungen100m")) {
    #Download data from Zensus Website
    df <- z11_download(z11::z11_download_links[name])
    
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
  }
  #1km Gitterzellen und Bevölkerungstabelle
  else if (name %in% c("klassiert1km", "spitz1km", "bevoelkerung100m")) {
    #Download data from Zensus website
    df <- z11_download(z11::z11_download_links[name])
    
    #Create subdirectory if it doesn't exist
    subdir <- ifelse(name == "bevoelkerung100m", "100m", "1km")
    if (!dir.exists(file.path(directory, subdir))) {
      dir.create(file.path(directory, subdir))
    }
    
    #Create vector of column names to loop over, get suffix for variable names
    colns <- colnames(df)
    id_col <- colns[grepl("Gitter_ID_", colns)][[1]]
    colns <- base::subset(colns, !(colns %in% c("Gitter_ID_1km", "x_mp_1km", "y_mp_1km", "Gitter_ID_100m", "x_mp_100m", "y_mp_100m")))
    suffix <- switch(name, bevoelkerung100m = "_100m", klassiert1km = "_cat", spitz1km = "")
    
    data.table::setDT(df)
    
    #Select columns, rename and save
    message("Save data...")
    purrr::walk(colns,
                ~df[, .(get(id_col), get(.x))][, data.table::setnames(.SD, new = c(id_col, paste0(.x, suffix)))] %>%
                  saveRDS(file = file.path(directory, subdir, paste0(.x, suffix, ".rds"))))
  }
  else {
    stop("Not a valid name!")
  }
  
  message("Collecting garbage...")
  invisible(gc())
}

z11_download <- function(url) {
  #Create temporary files, download data
  tmp <-tempfile()
  tmp_dir <- tempdir()
  message("Download data...")
  download.file(url, destfile = tmp)
  
  #Get filename of .csv file in .zip archive
  outf <- unzip(tmp, list=TRUE)$Name
  csvfile <- outf[grepl("\\.csv|\\.CSV", outf)][[1]]
  
  #Unzip and read .csv file
  message("Unzip...")
  system2("unzip", args = c("-o", file.path(tmp), "-d", file.path(tmp_dir)))
  message("Read data...")
  df <- data.table::fread(file.path(tmp_dir, csvfile), encoding = "Latin-1")
  
  #Delete downloaded files, garbage collection
  message("Clean up downloaded files...")
  purrr::walk(outf, ~file.remove(file.path(tmp_dir, .x)))
  file.remove(file.path(tmp))
  unlink(tmp)
  unlink(tmp_dir)
  invisible(gc())
  
  return(df)
}
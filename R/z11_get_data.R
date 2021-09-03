#' Download Zensus 2011 data
#' 
#' @description 
#' Downloads Zensus 2011 data, splits it into smaller chunks, and saves it locally.
#' 
#' @usage 
#' z11_get_data(name, directory, all = FALSE)
#' 
#' @param name Which Dataset should be downloaded? Possible values are "klassiert1km", "spitz1km", "bevoelkerung100m", "demographie100m", "familien100m", "haushalte100m", "gebaude100m", "wohnungen100m".
#' @param directory Path to the directory where the data should be saved.
#' @param all Should all datasets be downloaded? Defaults to FALSE. Use with caution.
#' 
#' @details 
#' The data files are very large and use a lot of RAM, so use with caution. Don't run other things in the background.
#' This was tested on Ubuntu 18, and I can't guarantee that it works on anything else.
#' 
#' @examples 
#' \dontrun{
#' z11_get_data("spitz1km", "/home/yourname/z11data")
#' }
#' 
#' @importFrom purrr walk
#' @importFrom data.table fread
#' @importFrom magrittr %>%
#' 
#' @export

z11_download <- function(url) {
  tmp <-tempfile()
  tmp_dir <- tempdir()
  message("Download data...")
  download.file(url, destfile = tmp)
  outf <- unzip(tmp, list=TRUE)$Name
  csvfile <- outf[grepl("\\.csv|\\.CSV", outf)][[1]]
  
  message("Unzip...")
  system2("unzip", args = c("-o", file.path(tmp), "-d", file.path(tmp_dir)))
  message("Read data...")
  df <- data.table::fread(file.path(tmp_dir, csvfile), encoding = "Latin-1")
  
  message("Clean up downloaded files...")
  purrr::walk(outf, ~file.remove(file.path(tmp_dir, .x)))
  file.remove(file.path(tmp))
  unlink(tmp)
  unlink(tmp_dir)
  invisible(gc())
  
  return(df)
}

z11_get_data <- function(name, directory, all = FALSE) {
  if (isTRUE(all)) {
    purrr::walk(names(z11_download_links), ~z11_get_data(name = .x, directory = directory))
  }
  #100m Gitterzellen
  else if (name %in% c("demographie100m", "familien100m", "haushalte100m", "gebaeude100m", "wohnungen100m")) {
    df <- z11_download(z11_download_links[name])
    
    message("Clean up strings...")
    df <- df[, merkm := paste(trimws(Merkmal), Auspraegung_Code, sep = "_")]
    
    message("Transform and save data...")
    if (!dir.exists(file.path(directory, "100m"))) {
      dir.create(file.path(directory, "100m"))
    }
    prefix <- substring(name, 1, 3) %>% toupper() %>% paste0("_")
    purrr::walk(unique(df$merkm),
                ~df[merkm == .x, .(Gitter_ID_100m, Anzahl)][, data.table::setnames(.SD, new = c("Gitter_ID_100m", paste0(prefix, .x)))] %>%
                  saveRDS(file = file.path(directory, "100m", paste0(prefix, .x, ".rds")))
    )
  }
  #1km Gitterzellen und Bevölkerungstabelle
  else if (name %in% c("klassiert1km", "spitz1km", "bevoelkerung100m")) {
    df <- z11_download(z11_download_links[name])
    
    subdir <- ifelse(name == "bevoelkerung100m", "100m", "1km")
    if (!dir.exists(file.path(directory, subdir))) {
      dir.create(file.path(directory, subdir))
    }
    
    colns <- colnames(df)
    id_col <- colns[grepl("Gitter_ID_", colns)][[1]]
    raster <- paste0(c("x_mp", "y_mp"), stri_extract_last_regex(id_col, "\\_1.+$"))
    colns <- base::subset(colns, !(colns %in% c("Gitter_ID_1km", "x_mp_1km", "y_mp_1km", "Gitter_ID_100m", "x_mp_100m", "y_mp_100m")))
    suffix <- ifelse(name == "klassiert1km", "_cat", "")
    
    df <- sf::st_as_sf(coords = raster, crs = 3035)
    data.table::setDT(df)
    
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
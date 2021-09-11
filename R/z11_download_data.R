#' Download Census 2011 data
#' 
#' @description 
#' Downloads Census 2011 data, unzips it and saves it to a local folder
#' 
#' @usage 
#' z11_get_data(name, directory, all = FALSE)
#' 
#' @param directory Path to the directory where the data should be saved.
#' 
#' @details 
#' This was written on Ubuntu 18, and I can't guarantee that it works on anything else. If you're on Windows or Mac, download and unzip the data manually instead.
#' 
#' @examples 
#' z11_download_data("/home/yourname/z11data")
#' 
#' @importFrom purrr walk
#' @importFrom magrittr %>%
#' 
#' @export
z11_download_data <- function(directory) {
  download_links <- c(
    "bevoelkerung100m" = "https://www.zensus2011.de/SharedDocs/Downloads/DE/Pressemitteilung/DemografischeGrunddaten/csv_Bevoelkerung_100m_Gitter.zip?__blob=publicationFile&v=3",
    "demographie100m" = "https://www.zensus2011.de/SharedDocs/Downloads/DE/Pressemitteilung/DemografischeGrunddaten/csv_Demographie_100m_Gitter.zip?__blob=publicationFile&v=2",
    "familien100m" = "https://www.zensus2011.de/SharedDocs/Downloads/DE/Pressemitteilung/DemografischeGrunddaten/csv_Familien_100m_Gitter.zip?__blob=publicationFile&v=2",
    "haushalte100m" = "https://www.zensus2011.de/SharedDocs/Downloads/DE/Pressemitteilung/DemografischeGrunddaten/csv_Haushalte_100m_Gitter.zip?__blob=publicationFile&v=2",
    "wohnungen100m" = "https://www.zensus2011.de/SharedDocs/Downloads/DE/Pressemitteilung/DemografischeGrunddaten/csv_Wohnungen_100m_Gitter.zip?__blob=publicationFile&v=5",
    "gebaeude100m" = "https://www.zensus2011.de/SharedDocs/Downloads/DE/Pressemitteilung/DemografischeGrunddaten/csv_Gebaeude_100m_Gitter.zip?__blob=publicationFile&v=2",
    "klassiert1km" = "https://www.zensus2011.de/SharedDocs/Downloads/DE/Pressemitteilung/DemografischeGrunddaten/csv_Zensusatlas_klassierte_Werte_1km_Gitter.zip?__blob=publicationFile&v=8", 
    "spitz1km" = "https://www.zensus2011.de/SharedDocs/Downloads/DE/Pressemitteilung/DemografischeGrunddaten/csv_Zensusatlas_spitze_Werte_1km_Gitter.zip?__blob=publicationFile&v=7"
  )
  
  if (dir.exists(directory)) {
    purrr::walk(download_links, ~z11_download_file(.x, directory))
  } else {
    stop("Not a valid directory!")
  }
}

z11_download_file <- function(url, directory) {
  #Create temporary files, download data
  tmp <- tempfile()
  message("Download data...")
  download.file(url, destfile = tmp)
  
  #Get filename of .csv file in .zip archive
  outf <- unzip(tmp, list=TRUE)$Name
  csvfile <- outf[grepl("\\.csv|\\.CSV", outf)][[1]]
  doc_files <- outf[outf != csvfile]
  
  #Unzip
  message("Unzip...")
  system2("unzip", args = c("-o", file.path(tmp), "-d", file.path(directory)))
  
  if (length(doc_files) > 0) {
    message("Move documentation to subdirectory...")
    subdir <- file.path(directory, "docs")
    #Create subdirectory for documentation if it doesn't exist
    if (!dir.exists(subdir)) {
      dir.create(subdir)
    }
    
    #Move documentation to subdirectory
    purrr::walk(doc_files, ~file.copy(from = file.path(directory, .x), 
                                      to = file.path(subdir, .x),
                                      overwrite = TRUE))
    purrr::walk(doc_files, ~file.remove(file.path(directory, .x)))
  }
  
  #Delete downloaded file
  message("Clean up...")
  file.remove(file.path(tmp))
  unlink(tmp)
}
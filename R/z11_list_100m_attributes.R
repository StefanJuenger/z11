#' List 1 hectare attributes of the German Census 2011
#'
#' This function lists all attributes of the German Census 2011 with a raster
#' resolution of 1 hectare. These data were the last that have been published.
#' While they comprise more attributes than the 1 km² ones, the data were
#' prepared in a less easy to be used format. Note that the returned vector
#' of attribute names includes the attribute names as they were defined by the
#' Census folks plus a pattern denoting the code of the attribute in the
#' original dumped CSV file.
#'
#' @return Character vector
#'
#' @importFrom magrittr %>%
#'
#' @export
z11_list_100m_attributes <- function() {
  system.file("extdata", "index_100m", package = "z11") %>%
    readr::read_lines()
  # system.file("extdata", package = "z11") %>%
  #   paste0("/100m/") %>%
  #   list.files() %>%
  #   sub(".rds", "", .) %>%
  #   setdiff(c("Gitter_ID_100m_x_y", "INSGESAMT_0"))
}

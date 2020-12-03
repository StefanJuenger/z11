#' List 1km^2 attributes of the German Census 2011
#'
#' This function lists all attributes of the German Census 2011 with a raster
#' resolution of 1km^2. These data were the first that have been published. And
#' while they comprise fewer attributes than the 1 hectare ones, the data were
#' prepared in a way more easy to be used format. Note that the returned vector
#' of attribute names includes the attribute names as they were defined by the
#' Census folks.
#'
#' @return Character vector#'
#'
#' @importFrom magrittr %>%
#'
#' @export
z11_list_1km_attributes <- function() {
  system.file("extdata", "z11_attributes_1km.rds", package = "z11") %>%
    readRDS()  %>%
    sf::st_drop_geometry() %>%
    dplyr::select(-Gitter_ID_1km) %>%
    names()
}

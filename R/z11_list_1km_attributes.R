#' @export
z11_list_1km_attributes <- function() {
  system.file("extdata", "z11_attributes_1km.rds", package = "z11") %>%
    readRDS()  %>%
    sf::st_drop_geometry() %>%
    dplyr::select(-Gitter_ID_1km) %>%
    names()
}

z11_list_1km_attributes()

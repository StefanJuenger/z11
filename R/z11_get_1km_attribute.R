
#' @export
z11_get_1km_attribute <- function(attribute, as_raster = TRUE) {

    attribute <- rlang::enquo(attribute)

    requested_attribute <-
      system.file("extdata", "z11_attributes_1km.rds", package = "z11") %>%
      readRDS() %>%
      dplyr::select(!!attribute)

    if (isTRUE(as_raster)) {
      requested_attribute %>%
        stars::st_rasterize(xdim = 1000, ydim = 1000) %>%
        as("Raster")
    } else {
      requested_attribute
    }
}


z11_get_1km_attribute("Einwohner_cat")

#' Retrieve 1km^2 attribute of the German Census 2011
#'
#' This function retrieves an attribute with a raster resolution of 1km². You
#' can either choose to have it converted directly into the raster format
#' (default) or you can return it as a \code{sf} tibble object with point
#' geometries.
#'
#' @param attribute attribute name as definded in
#' \code{z11::z11_list_1km_attributes}
#' @param as_raster logical; shall the attribute be returned as raster or sf
#' object
#'
#' @return Raster or sf
#'
#' @importFrom magrittr %>%
#'
#' @export
z11_get_1km_attribute <- function(attribute, as_raster = TRUE) {

    attribute <- rlang::enquo(attribute)

    requested_attribute <-
      system.file("extdata", "z11_attributes_1km.rds", package = "z11") %>%
      readRDS() %>%
      dplyr::select(!!attribute)

    if (isTRUE(as_raster)) {
      requested_attribute %>%
      stars::st_rasterize(dx = 1000, dy = 1000) %>%
        as("Raster")
    } else {
      requested_attribute
    }
}

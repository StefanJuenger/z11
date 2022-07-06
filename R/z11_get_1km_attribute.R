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
#' @param data_location character string; location of the downloaded census data
#' from https://github.com/StefanJuenger/z11data; default is NULL - data are
#' downloaded from the internet
#'
#' @return Raster or sf
#'
#' @importFrom magrittr %>%
#' @importFrom sf st_as_sf
#' @importFrom stars st_rasterize
#' @importFrom dplyr bind_cols
#'
#' @export
z11_get_1km_attribute <-
  function(attribute, geometry = TRUE, as_raster = TRUE, data_location = NULL) {

    attribute <- rlang::enquo(attribute)  %>% rlang::as_label()

    # Load data in session
    if (is.null(data_location)) {
      requested_attribute <-
        paste0(
          "https://github.com/StefanJuenger/z11data/raw/main/1km/",
          attribute,
          ".rds"
        ) %>%
        url("rb") %>%
        readRDS()
    } else {
      requested_attribute <-
        paste0(data_location, "/1km/", attribute, ".rds") %>%
        readRDS()
    }

    # Extract coordinates from inspire ID
    if (isTRUE(geometry)) {
      requested_attribute <- requested_attribute %>%
        dplyr::bind_cols(., z11_extract_inspire_coordinates(.$Gitter_ID_1km)) %>%
        sf::st_as_sf(coords = c("X", "Y"), crs = 3035)

      #Transform to raster
      if (isTRUE(as_raster)) {
        requested_attribute <- stars::st_rasterize(requested_attribute, dx = 1000, dy = 1000) %>%
          terra::rast()
      }
    }

    return(requested_attribute)
}

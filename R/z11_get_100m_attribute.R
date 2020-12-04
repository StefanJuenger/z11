#' Retrieve 1 hectare attribute of the German Census 2011
#'
#' This function retrieves an attribute with a raster resolution of 1 hectare.
#' You can either choose to have it converted directly into the raster format
#' (default) or you can return it as a `sf` tibble object with point
#' geometries.
#'
#' @param attribute attribute name as definded in
#' \code{z11::z11_list_100m_attributes}
#' @param as_raster logical; shall the attribute be returned as raster or sf
#' object
#'
#' @return Raster or sf
#'
#' @importFrom magrittr %>%
#'
#' @export
z11_get_100m_attribute <- function(attribute, as_raster = TRUE) {

  attribute <- rlang::enquo(attribute)

  requested_attribute <-
    paste0("./100m/", attribute, ".rds") %>%
    system.file("extdata", ., package = "z11") %>%
    readRDS()

  # extract coordinates from inspire id
  requested_attribute <-
    requested_attribute %>%
    dplyr::bind_cols(
      z11_extract_inspire_coordinates(.$Gitter_ID_100m)
    ) %>%
    sf::st_as_sf(coords = c("X", "Y"), crs = 3035)

  # correspondence_table <-
  #   system.file("extdata", "./100m/Gitter_ID_100m_x_y.rds", package = "z11") %>%
  #   readRDS()
  #
  # # link
  # requested_attribute <-
  #   dplyr::left_join(
  #     correspondence_table,
  #     requested_attribute,
  #     by = "Gitter_ID_100m"
  #   ) %>%
  #   sf::st_as_sf(coords = c("x_mp_100m", "y_mp_100m"), crs = 3035)
  #
  # rm(correspondence_table)
  #
  # gc()

  if (isTRUE(as_raster)) {
    requested_attribute <-
      requested_attribute %>%
      stars::st_rasterize(dx = 100, dy = 100) %>%
      as("Raster")

    requested_attribute
  } else {
    requested_attribute
  }
}




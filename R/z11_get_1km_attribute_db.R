#' Retrieve 1km^2 attribute of the German Census 2011
#'
#' This function retrieves an attribute with a raster resolution of 1km². You
#' can either choose to have it converted directly into the raster format
#' (default) or you can return it as a \code{sf} tibble object with point
#' geometries.
#'
#' @param attribute attribute name as defined in
#' \code{z11::z11_list_1km_attributes}, as a string
#' @param con Connection to the database
#' @param as_raster logical; shall the attribute be returned as raster or sf
#' object
#'
#' @return Raster or sf
#'
#' @importFrom magrittr %>%
#' @importFrom sf st_as_sf
#' @importFrom stars st_rasterize
#' @importFrom dplyr bind_cols
#' @importFrom DBI dbSendQuery dbFetch dbClearResult
#'
#' @export
z11_get_1km_attribute_db <- function(attribute, con, as_raster = TRUE) {
  # Get attribute from database
  message("Fetch attribute from database...")
  tab <- ifelse(grepl("\\_cat$", attribute), "klassiert1km", "spitz1km")
  query <- sprintf('SELECT "Gitter_ID_1km", "%s" FROM %s;', attribute, tab)
  res <- DBI::dbSendQuery(con, query)
  requested_attribute <- DBI::dbFetch(res)
  DBI::dbClearResult(res)

  # Extract coordinates from inspire ID
  message("Extract coordinates from inspire ID...")
  requested_attribute <- requested_attribute %>%
    dplyr::bind_cols(., z11_extract_inspire_coordinates(.$Gitter_ID_1km)) %>%
    sf::st_as_sf(coords = c("X", "Y"), crs = 3035)

  #Transform to raster
  if (isTRUE(as_raster)) {
    message("Transform to raster...")
    requested_attribute <- stars::st_rasterize(requested_attribute, dx = 1000, dy = 1000) %>%
      as("Raster")
  }

  return(requested_attribute)
}

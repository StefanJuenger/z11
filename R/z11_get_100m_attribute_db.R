#' Retrieve 1 hectare attribute of the German Census 2011
#'
#' This function retrieves an attribute with a raster resolution of 1 hectare.
#' You can either choose to have it converted directly into the raster format
#' (default) or you can return it as a `sf` tibble object with point
#' geometries.
#'
#' @param attribute attribute name as definded in
#' \code{z11::z11_list_100m_attributes}, as a string
#' @param con Connection to the database
#' @param as_raster logical; shall the attribute be returned as raster or sf
#' object
#'
#' @examples
#' con <- DBI::dbConnect(RSQLite::SQLite(), "/home/user/z11data.sqlite3")
#' df <- z11_get_100m_attribute_db("GEB_HEIZTYP_1", con)
#' DBI::dbDisconnect(con)
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
z11_get_100m_attribute_db <- function(attribute, con, as_raster = TRUE) {
  # Get attribute from database
  message("Fetch attribute from database...")
  table <- switch(substring(attribute, 1, 3),
                  Ein = "bevoelkerung100m", DEM = "demographie100m", HAU = "haushalte100m",
                  FAM = "familien100m", GEB = "gebaeude100m", WOH = "wohnungen100m")
  query <- sprintf("SELECT Gitter_ID_100m, %s FROM %s WHERE %s IS NOT NULL;", attribute, table, attribute)
  res <- DBI::dbSendQuery(con, query)
  requested_attribute <- DBI::dbFetch(res)
  DBI::dbClearResult(res)

  # Extract coordinates from inspire ID
  message("Extract coordinates from inspire ID...")
  requested_attribute <- requested_attribute %>%
    dplyr::bind_cols(
      z11_extract_inspire_coordinates(.$Gitter_ID_100m)
    ) %>%
    sf::st_as_sf(coords = c("X", "Y"), crs = 3035)

  #Transform to raster
  if (isTRUE(as_raster)) {
    message("Transform to raster...")
    requested_attribute <- requested_attribute %>%
      stars::st_rasterize(dx = 100, dy = 100) %>%
      as("Raster")
  }

  return(requested_attribute)
}



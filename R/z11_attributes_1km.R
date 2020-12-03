#' Census 2011 Data (1km^2)
#'
#' A dataset containing centroid geocoordinates and other attributes of
#' 361478 census grid cells in Germany
#'
#' @format A simple features tibble with 361478 rows and 22 variables
#' \describe{
#' \item{...}{...}
#' }
#' @source © Statistisches Bundesamt: \url{https://www.zensus2011.de}
# "z11_attributes_1km"

# z11_attributes_1km_continuous <-
#   data.table::fread(
#     "../z11_data-raw/Zensus_spitze_Werte_1km-Gitter.csv",
#     dec = ","
#     ) %>%
#   dtplyr::lazy_dt()
#
# z11_attributes_1km_categorical <-
#   data.table::fread("../z11_data-raw/Zensus_klassierte_Werte_1km-Gitter.csv") %>%
#   dtplyr::lazy_dt() %>%
#   dplyr::rename_at(
#     dplyr::vars(-Gitter_ID_1km, -x_mp_1km, -y_mp_1km),
#     ~glue::glue("{.}_cat")
#   )
#
# z11_attributes_1km <-
#   dplyr::left_join(
#     z11_attributes_1km_continuous, z11_attributes_1km_categorical
#   ) %>%
#   tibble::as_tibble() %>%
#   sf::st_as_sf(coords = c("x_mp_1km", "y_mp_1km"), crs = 3035)
#
# saveRDS(z11_attributes_1km, "./inst/extdata/z11_attributes_1km.rds")

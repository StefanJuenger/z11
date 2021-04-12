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
#     "../z11data-raw/Zensus_spitze_Werte_1km-Gitter.csv",
#     dec = ","
#     ) %>%
#   dtplyr::lazy_dt()
#
# z11_attributes_1km_categorical <-
#   data.table::fread("../z11data-raw/Zensus_klassierte_Werte_1km-Gitter.csv") %>%
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
# # create and write index
# names_1km <-
#   names(z11_attributes_1km) %>%
#   setdiff(c("Gitter_ID_1km", "geometry"))
#
# index_1km <-
#   names_1km %>%
#   readr::write_lines(file = "./inst/extdata/index_1km")
#
# # save files
# lapply(names_1km, function (i) {
#   z11_attributes_1km %>%
#     dplyr::select(Gitter_ID_1km, dplyr::all_of(i)) %>%
#     saveRDS(paste0("../z11data/1km/", i, ".rds"))
# })

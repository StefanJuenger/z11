#' Extract Geocoordinates (EPSG:3035) from INSPIRE IDs
#'
#' Retrieve centroid geocoordinates for 1km^2 and 1 hectare INSPIRE Grid IDs.
#' This function is particularly helpful when working with German Census data.
#'
#' @param inspire_ids Character vector containing INSPIRE IDs
#' @return tibble
#'
#' @export
#'
#' @importFrom magrittr %>%
z11_extract_inspire_coordinates <- function (inspire_ids) {

  if (grepl("1km", inspire_ids[1])) {
    inspire_coordinates <-
      tibble::tibble(
        X =
          substr(inspire_ids, 10, 13) %>%
          as.numeric() * 1000 + 500,
        Y =
          substr(inspire_ids, 5, 8) %>%
          as.numeric() * 1000 + 500,
      )
  }

  if (grepl("100m", inspire_ids[1])) {
    inspire_coordinates <-
      tibble::tibble(
        X =
          substr(inspire_ids, 12, 16) %>%
          as.numeric() * 100 + 50,
        Y =
          substr(inspire_ids, 6, 10) %>%
          as.numeric() * 100 + 50,
      )
  }

  inspire_coordinates
}

#' Extract Geocoordinates (EPSG:3035) from INSPIRE IDs
#'
#' Retreive centroid geocoordinates for 1km^2 and 1 hectare INSPIRE Grid IDs
#'
#' @param inspire_ids Character vector containing INSPIRE IDs
#' @return tibble
#'
#' @noRd
#'
#' @importFrom magrittr %>%
z11_extract_inspire_coordinates <- function (inspire_ids) {

  if (stringr::str_detect(inspire_ids[1], "1km")) {
    inspire_coordinates <-
      tibble::tibble(
        X =
          substr(inspire_ids, 10, 13) %>%
          paste0(., "500") %>%
          as.numeric(),
        Y =
          substr(inspire_ids, 5, 8) %>%
          paste0(., "500") %>%
          as.numeric()
      )
  }

  if (stringr::str_detect(inspire_ids[1], "100m")) {
    inspire_coordinates <-
      tibble::tibble(
        X =
          substr(inspire_ids, 12, 16) %>%
          paste0(., "50") %>%
          as.numeric(),
        Y =
          substr(inspire_ids, 6, 10) %>%
          paste0(., "50") %>%
          as.numeric()
      )
  }

  inspire_coordinates
}

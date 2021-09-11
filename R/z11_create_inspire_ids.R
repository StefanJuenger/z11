#' Create 1km and 100m INSPIRE IDs
#'
#' Create 1 km² and 100m X 100m INSPIRE IDs from coordinates
#'
#' @param data Object of class ```sf``` containing point geometries
#' @param type Character string for the requested ID type
#' @return tibble
#'
#' @importFrom magrittr %>%
#'
#' @export

z11_create_inspire_ids <- function(
  data,
  type = c("1km", "100m"),
  column_name = "Gitter_ID_",
  combine = FALSE
) {

  if (sf::st_crs(data)$epsg != 3035) {
    data <- data %>% sf::st_transform(3035)
  }

  coordinate_pairs <-
    data %>%
    sf::st_coordinates() %>%
    tibble::as_tibble()

  id_name <-
    glue::glue("{column_name}{type}")

  if (type == "1km") {
    inspire <- glue::glue(
      "1kmN{substr(coordinate_pairs$Y %>% as.character(), 1, 4)}",
      "E{substr(coordinate_pairs$X %>% as.character(), 1, 4)}"
    ) %>% as.character()
  } else if (type == "100m") {
    inspire <- glue::glue(
      "100mN{substr(coordinate_pairs$Y %>% as.character(), 1, 5)}",
      "E{substr(coordinate_pairs$X %>% as.character(), 1, 5)}"
    ) %>% as.character()
  } else {
    stop("Not a valid type!")
  }
  
  if (isTRUE(combine)) {
    return(
      dplyr::bind_cols(data, !!id_name := inspire)
    )
  } else {
    return(inspire)
  }

}
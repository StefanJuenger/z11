#' Simple join of data with census 1 km attributes
#'
#' Merge input data with census 1 km data by simple matching of INSPIRE IDs
#'
#' @param data input data
#' @param inspire_colum Character string for column name in input data
#' containing the inspire ID
#' @param attribute Name of the census variable which is aimed to be merged with
#' input data (used for calling \code{z11::z11_get_1km_attribute()})
#' @param all logical; should all census attributes be merged? default: `FALSE`
#' @param ... arguments passed to \code{z11::z11_get_1km_attribute()}
#'
#' @importFrom magrittr %>%
#'
#' @export
z11_simple_join_1km_attribute <-
  function(
    data,
    inspire_column,
    attribute,
    all = FALSE,
    ...
  ) {

    inspire_column <- rlang::enquo(inspire_column) %>% rlang::as_label()

    if (isFALSE(all)) {
      attribute <- rlang::enquo(attribute)

      attribute <-
        z11::z11_get_1km_attribute(!!attribute, as_raster = FALSE, ...) %>%
        sf::st_drop_geometry()

      linked_data <-
        dplyr::left_join(
          data %>%
            dplyr::mutate(
              Gitter_ID_1km = data[[inspire_column]]
            ),
          attribute,
          by = "Gitter_ID_1km"
        )
    }

    if (isTRUE(all)) {
      linked_data <- data

      for (i in z11::z11_list_1km_attributes()) {

        message(i)

        attribute <- rlang::sym(i)

        attribute <-
          z11::z11_get_1km_attribute(!!attribute, as_raster = FALSE, ...) %>%
          sf::st_drop_geometry()

        linked_data <-
          dplyr::left_join(
            linked_data %>%
              dplyr::mutate(
                Gitter_ID_1km = data[[inspire_column]]
              ),
            attribute,
            by = "Gitter_ID_1km"
          )
      }
    }

    linked_data
  }



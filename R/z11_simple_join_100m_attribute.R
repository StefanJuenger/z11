#' Simple join of data with census 100m attributes
#'
#' Merge input data with census 100m data by simple matching of INSPIRE IDs
#'
#' @param data input data
#' @param inspire_colum Character string for column name in input data
#' containing the inspire ID
#' @param attribute Name of the census variable which is aimed to be merged with
#' input data (used for calling \code{z11::z11_get_100m_attribute()})
#' @param all logical; should all census attributes be merged? default: `FALSE`
#' @param ... arguments passed to \code{z11::z11_get_100m_attribute()}
#'
#' @importFrom magrittr %>%
#'
#' @export
z11_simple_join_100m_attribute <-
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

      #Get attribute data
      #add "z11::"later
      attribute <- z11_get_100m_attribute(!!attribute, geometry = FALSE, as_raster = FALSE, ...)
      data.table::setDT(attribute)
      data.table::setnames(attribute, old = "Gitter_ID_100m", new = inspire_column)
      
      #Merge
      linked_data <- attribute[data.table::data.table(data), on = inspire_column]
    }

    if (isTRUE(all)) {
      linked_data <- data.table(data)

      for (i in z11::z11_list_100m_attributes()) {

        message(i)

        attribute <- rlang::sym(i)

        #Get attribute data
        attribute <- z11::z11_get_100m_attribute(!!attribute, geometry = FALSE, as_raster = FALSE, ...)
        data.table::setDT(attribute)
        data.table::setnames(attribute, old = "Gitter_ID_100m", new = inspire_column)

        #Merge
        linked_data <- attribute[linked_data, on = inspire_column]
      }
    }

    linked_data
  }



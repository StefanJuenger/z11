#' Convert German Census 100m X 100m long format files in wide format
#'
#' This function expects an R object containing the census data in the long
#' format. It processes the data as following: \\
#' 1. Deleting all non-substantial rows from the data (e.g. "INSGESAMT"
#' rows) \\
#' 2. Creating identifier for all attribute-code-combinations \\
#' 3. Transforming of data using the previously created identifier \\
#' 4. Lastly, all missing values are converted to zeros
#'
#' @param x R object containing the census data
#'
#' @noRd
#'
#' @importFrom magrittr %>%
z11_wide_100m <- function (x) {
  x %>%
    dplyr::arrange(Gitter_ID_100m) %>%
    # dplyr::filter(Merkmal != " INSGESAMT") %>% #, Anzahl_q != 1) %>%
    dplyr::mutate(merk_code = paste0(Merkmal, "_", Auspraegung_Code)) %>%
    dplyr::select(Gitter_ID_100m, merk_code, Anzahl) %>%
    data.table::as.data.table() %>%
    tidyfast::dt_pivot_wider(names_from = merk_code, values_from = Anzahl)
    # tidyr::pivot_wider(., names_from = merk_code, values_from = Anzahl)
}

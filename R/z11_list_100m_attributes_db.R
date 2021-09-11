#' List 1 hectare attributes of the German Census 2011
#'
#' This function lists all attributes of the German Census 2011 with a raster
#' resolution of 1 hectare. These data were the last that have been published.
#' While they comprise more attributes than the 1 km² ones, the data were
#' prepared in a less easy to be used format. Note that the returned vector
#' of attribute names includes the attribute names as they were defined by the
#' Census folks plus a pattern denoting the code of the attribute in the
#' original dumped CSV file.
#'
#' @return List
#'
#' @importFrom magrittr %>%
#' @importFrom DBI dbListFields
#'
#' @export
z11_list_100m_attributes_db <- function(con) {
  c("Population" = "bevoelkerung100m", 
    "Demography" = "demographie100m", 
    "Households" = "haushalte100m",
    "Families" = "familien100m", 
    "Buildings" = "gebaeude100m", 
    "Flats" = "wohnungen100m") %>%
    lapply(function(x) DBI::dbListFields(con, x) %>% 
             base::subset(., . != "Gitter_ID_100m")
           )
}
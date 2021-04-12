# "z11_attributes_100m"

library(dplyr)

census_100m_files_directory <- "../z11data-raw/"

census_100m_files <-
  c(
    "Zensus_Bevoelkerung_100m-Gitter.csv", "Bevoelkerung100M.csv",
    "Familie100m.csv", "Geb100m.csv", "Haushalte100m.csv",
    "Wohnungen100m.csv"
    )


# # large inhabitants table as attribute
# Zensus_Bevoelkerung_100m_Gitter <-
#   data.table::fread(
#     paste0(census_100m_files_directory, census_100m_files[1])
#   ) %>%
#   dtplyr::lazy_dt() %>%
#   dplyr::select(Gitter_ID_100m, Einwohner) %>%
#   dplyr::mutate(Einwohner = dplyr::na_if(Einwohner, -1)) %>%
#   tibble::as_tibble() %>%
#   tidyr::drop_na() %>%
#   saveRDS(paste0("../z11data/100m/Einwohner.rds"))

# store all other attributes as small as possible
purrr::map(2:length(census_100m_files), function (i) {

  # load file as data.table
  whole_file <-
    data.table::fread(
      paste0(census_100m_files_directory, census_100m_files[i])
    ) %>%
    dtplyr::lazy_dt() %>%
    z11_wide_100m()

  names(whole_file) <- stringr::str_trim(names(whole_file))

  if ("INSGESAMT_0" %in% colnames(whole_file)) {
    insgesamt_name <-
      paste0(
        "INSGESAMT_",
        census_100m_files[i] %>%
          gsub("100m.csv", "", .) %>%
          gsub("100M.csv", "", .)
      )

    whole_file <-
      whole_file %>%
      dplyr::rename(!!insgesamt_name := "INSGESAMT_0")
  }

  # get names apart from gitter id
  names_whole_file <- whole_file$vars %>% .[-1]

  # store individual files for each attribute
  purrr::map(names_whole_file, function (j) {
    whole_file %>%
      dtplyr::lazy_dt() %>%
      dplyr::select(Gitter_ID_100m, !!j) %>%
      tibble::as_tibble() %>%
      tidyr::drop_na() %>%
      saveRDS(., paste0("../z11data/100m/", j, ".rds"))
      # saveRDS(., paste0("./inst/extdata/100m/", j, ".rds"))
  })
})
#
# # create and save index
# index_100m <-
#   list.files("../z11data/100m/") %>%
#   sub(".rds", "", .) %>%
#   setdiff(c("Gitter_ID_100m_x_y", "INSGESAMT_0")) %>%
#   readr::write_lines(file = "./inst/extdata/index_100m")

#### OLD

# tmp <-
#   dplyr::left_join(
#     readRDS("./inst/extdata/100m/Gitter_ID_100m_x_y.rds"),
#     readRDS("./inst/extdata/100m/STAATZHL_1.rds"),
#   )


# tmp <-
#   Bevoelkerung100M %>%
#   dplyr::select(Gitter_ID_100m, ALTER_10JG_1) %>%
#   tibble::as_tibble() %>%
#   tidyr::drop_na()
#
#   dplyr::left_join(
#     Zensus_Bevoelkerung_100m_Gitter %>%
#       dplyr::select(Gitter_ID_100m, x_mp_100m, y_mp_100m),
#     .
#   )
#
# readr::write_csv(tmp %>% as_tibble(), "./inst/extdata/tmp.csv")
#
# saveRDS(tmp %>% as_tibble(), "./inst/extdata/tmp.rds")
#
#
# Bevoelkerung100M <-
#   data.table::fread("./data-raw/Bevoelkerung100M.csv") %>%
#   dtplyr::lazy_dt() %>%
#   z11_wide_100m() %>%
#   dtplyr::lazy_dt() %>%
#   dplyr::mutate(source = "Bevoelkerung100M")
#
# saveRDS(
#   Bevoelkerung100M,
#   "./inst/extdata/Bevoelkerung100M.rds"
# )
#
# gc()
#
# Familie100m <-
#   data.table::fread("./data-raw/Familie100m.csv") %>%
#   dtplyr::lazy_dt() %>%
#   z11_wide_100m() %>%
#   dtplyr::lazy_dt() %>%
#   dplyr::mutate(source = "Familie100m")
#
# saveRDS(
#   Familie100m,
#   "./inst/extdata/Familie100m.rds"
# )
#
# gc()
#
# Geb100m <-
#   data.table::fread("./data-raw/Geb100m.csv") %>%
#   dtplyr::lazy_dt() %>%
#   z11_wide_100m() %>%
#   dtplyr::lazy_dt() %>%
#   dplyr::mutate(source = "Geb100m")
#
# saveRDS(
#   Geb100m,
#   "./inst/extdata/Geb100m.rds"
# )
#
# gc()
#
# Haushalte100m <-
#   data.table::fread("./data-raw/Haushalte100m.csv") %>%
#   dtplyr::lazy_dt() %>%
#   z11_wide_100m() %>%
#   dtplyr::lazy_dt() %>%
#   dplyr::mutate(source = "Haushalte100m")
#
# saveRDS(
#   Haushalte100m,
#   "./inst/extdata/Haushalte100m.rds"
# )
#
# gc()
#
# Wohnungen100m <-
#   data.table::fread("./data-raw/Wohnungen100m.csv") %>%
#   dtplyr::lazy_dt() %>%
#   z11_wide_100m() %>%
#   dtplyr::lazy_dt() %>%
#   dplyr::mutate(source = "Wohnungen100m")
#
# saveRDS(
#   Wohnungen100m,
#   "./inst/extdata/Wohnungen100m.rds"
# )
#
# gc()

# z11_attributes_100m <-
#   Zensus_Bevoelkerung_100m_Gitter %>%
#   dplyr::left_join(Bevoelkerung100M) %>%
#   dplyr::left_join(Familie100m) %>%
#   dplyr::left_join(Geb100m) %>%
#   dplyr::left_join(Haushalte100m) %>%
#   dplyr::left_join(Wohnungen100m)
#
# gc()
#
# rm(
#   Zensus_Bevoelkerung_100m_Gitter, Bevoelkerung100M, Familie100m, Geb100m,
#   Haushalte100m, Wohnungen100m
# )
#
# gc()
#
# saveRDS(z11_attributes_100m, "./inst/extdata/z11_attributes_100m_dt.rds")
#
# z11_attributes_100m <- readRDS("./inst/extdata/z11_attributes_100m_dt.rds")
#
# z11_attributes_100m <-
#   z11_attributes_100m %>%
#   tibble::as_tibble() %>%
#   sf::st_as_sf(coords = c("x_mp_1km", "y_mp_1km"), crs = 3035)


# Introduction
The `z11` package provides an `R`-interface to the geospatial raster data of the German Census 2011. `z11` can be used to list all available attributes from the Census (1 km$^2$ attributes and 1-hectare attribute) and import them either as [simple features](https://r-spatial.github.io/sf/) spatial points object or as [raster](https://cran.r-project.org/web/packages/raster/index.html) object with the resolution of the corresponding attribute. I felt that such a package may be of interest for other userRs since the Census data 'only' exists as [CSV data dump on the internet](https://www.zensus2011.de/DE/Home/Aktuelles/DemografischeGrunddaten.html). However, to use them in a Geographic Information System (GIS), the data must be prepared, which is time-consuming and computationally demanding. As such, the package aims to fill the gap of making the data easily accessible by providing a straightforward method.

Generally, the German Census 2011 data are available under a [Data licence Germany – attribution – version 2.0](https://www.govdata.de/dl-de/by-2-0) and can be manipulated and openly shared. **Yet, as part of this package, use them at your own risk and do not take the results of the functions for granted.**

# Installing and Loading the Package

~~~{r}
remotes::install_github("StefanJuenger/z11")
~~~

Be aware that the package is quite large (~640 Megabytes). It includes all census data in its `./inst/extdata/` folder for offline-access. I was thinking of pointing the package's functions to an online archive, but this would mean that users always have an existing online connection. See the "Future" section for more thoughts on that.

After installing, the package can be loaded using `R`'s standard method:

~~~{r}
library(z11)
~~~

For more details, please refer to the package vignette(s).

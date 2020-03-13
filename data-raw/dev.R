# https://www.r-bloggers.com/how-to-build-an-api-wrapper-package-in-10-minutes/

install.packages("devtools")
install.packages("roxygen2")
install.packages("usethis")
install.packages("curl")
install.packages("httr")
install.packages("jsonlite")
install.packages("attempt")
install.packages("purrr")
devtools::install_github("r-lib/desc")



library(devtools)
library(usethis)
library(desc)

unlink("DESCRIPTION")
my_desc <- description$new("!new")
my_desc$set("Package", "XsearchLIBRIS")
my_desc$set("Authors@R", "person('Markus', 'Skyttner', email = 'markussk@kth.se', role = c('cre', 'aut'))")

my_desc$del("Maintainer")

my_desc$set_version("0.0.0.9000")

my_desc$set(Title = "Data from LIBRIS - Swedish National Library Systems Xsearch API")
my_desc$set(Description = "Xsearch is a lightweight API provided by LIBISH - the Swedish National Library Systems. This R package interfaces with the API, making data available to use from R.")
my_desc$set("URL", "https://github.com/KTH-Library/XsearchLIBRIS")
my_desc$set("BugReports", "https://github.com/KTH-Library/XsearchLIBRIS/issues")
my_desc$set("License", "MIT")

use_mit_license(name = "Markus Skyttner")
#use_code_of_conduct()
use_lifecycle_badge("Experimental")
use_news_md()
my_desc$write(file = "DESCRIPTION")

use_package("httr")
use_package("jsonlite")
use_package("curl")
use_package("attempt")
use_package("purrr")
use_package("progress")
use_package("dplyr")
use_package("tibble")
use_package("rlang")
use_package("htmltools")

use_tidy_description()

use_testthat()
use_vignette("XsearchLIBRIS")
use_readme_rmd()
use_mit_license(name = "Markus Skyttner")
use_data_raw()
use_pkgdown()
use_lifecycle_badge("experimental")

use_test("crawl")
use_test("search")

pkgdown::build_site()

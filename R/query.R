# this file is the main file of `crimer` package

get_apikey <- function() {

  apikey <- as.character(Sys.getenv()["CRIMER_APIKEY"])
  # TODO: edit the assertion message to be more informative
  assertthat::assert_that(!is.na(apikey), msg = "API key not found")
  apikey
}

map_agency_crime <- function(agency_ori, since, until, sleep = 0) {
  stringf <- sprintf("/api/summarized/agencies/%s/offenses/%s/%s",
                     agency_ori, since, until)
  agency_crime <- get_url(stringf)
  Sys.sleep(sleep)
  agency_crime
}

#' The most basic function in crimer
#'
#' @param endpoint (character) endpoint defined by (https://crime-data-explorer.fr.cloud.gov/api)
#'
#' @return NULL if encounter error in requesting,
#' otherwise tibble::tibble from result JSON
#' @export
#'
#' @examples
#' # this is equivalent to get_agencies() function
#' # in fact, get_agencies() is defined by doing so
#' agencies <- get_url("api/agencies/list")
get_url <- function(endpoint) {

  apikey <- get_apikey()
  base_url <- "https://api.usa.gov/crime/fbi/sapi/%s?api_key=%s"
  # paste("lsjf", "lsjfls", sep = "/")
  url <- sprintf(base_url, endpoint, apikey)

  res <- httr::GET(url)

  assertthat::assert_that(!httr::http_error(res), msg = httr::content(res, as = "text"))

  resjson <- jsonlite::fromJSON(httr::content(res, as="text"))
  if (is.data.frame(resjson)) {
    jstb <- tibble::as_tibble(resjson)
  } else {
    jstb <- tibble::as_tibble(resjson$results)
  }
  jstb
}

#' Title
#'
#' @return a tibble::tibble of all agencies listed by the API
#' @export
#'
#' @examples
#' agencies <- get_agencies()
get_agencies <- function() {

  agencies <- get_url("api/agencies/list")
  agencies
}

#' Title
#'
#' @param ori (character) agency ori, an identifier defined by API
#'
#' @return a tibble::tibble of pariticipation info of agencies
#' @export
#'
#' @examples \dontrun{
#' agency_par <- get_agency_participation("AK0010100")
#' }
get_agency_participation <- function(ori) {

  agency_participation <- get_url(paste("api/participation/agencies", ori, sep = "/"))
  agency_participation
}

#' Title
#'
#' @param agency_ori (character vector), denoting the agency ori, could be looked up by get_agencies()
#'        default: NULL, which means getting all agencies
#' @param since (integer), starting year of query
#' @param until (integer), ending year of query
#' @details
#' since >= 1985, until <= 2018
#'
#' (https://www.ucrdatatool.gov/)
#'
#' national crime estimates from 1960 through the most recent year available
#'
#' state crime estimates from 1960 through the most recent year available
#'
#' city and county crime counts from 1985 through the most recent year available
#'
#' @return tibble::tibble
#' @export
#'
#' @examples \dontrun{
#' as <- get_agency_crime("AK0010100", since = 1984, until = 2018)
#' asny <- get_agency_crime("NY330SS00", since = 1985, until = 2018)
#' }
get_agency_crime <- function(agency_ori = NULL, since = NULL, until = NULL) {
  library(dplyr)

  if (is.null(since)) since <- 1985
  if (is.null(until)) {
    # if (!is.null(agency_ori)) {
    #   ag_par <- get_agency_participation(agency_ori)
    #   until <- max(ag_par$data_year)
    # } else {
    until <- 2018
    # }
  }

  # get agency characteristics
  agencies <- get_agencies()

  if (is.null(agency_ori)) {
    # default to get all agencies
    oris <- agencies %>%
      select(ori) %>%
      pull()
  } else {
    # provide a vector of oris
    oris <- agency_ori
  }

  agency_crime <- purrr::map(oris,
                             map_agency_crime,
                             since,
                             until) %>%
    bind_rows()

  agency_crime
}


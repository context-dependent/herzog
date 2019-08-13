#' Collect herzog results for specific ids from your designated url
#'
#' @param url
#' @param ids
#'
#' @return
#' @export
#'
#' @examples
get_herzog_results <- function(url, ids = NULL) {

  dat_raw <-

    xml2::read_html(url) %>%
    rvest::html_table(header = TRUE) %>%
    purrr::pluck(1) %>%
    tibble::as_tibble() %>%
    na_if("-")

  dat_long <-

    dat_raw %>%

      tidyr::gather(var, val, -matches("ID")) %>%
      janitor::clean_names() %>%
      dplyr::filter(!is.na(val))

  dat_clean <-

    dat_long %>%

      dplyr::select(-matches("Reading")) %>%
      dplyr::mutate(
        skill = var %>% str_extract("Document Use|Numeracy"),
        test = var %>% str_extract("Baseline|Post"),
        stat = var %>% str_remove_all("Document Use|Numeracy|Baseline|Post")
      ) %>%
      dplyr::select(-var) %>%
      dplyr::group_by_all() %>%
      dplyr::slice(1) %>%
      dplyr::filter(stat %in% c("Level", "Score", "Duration (mins)", "Start Date")) %>%
      tidyr::spread(stat, val) %>%
      janitor::clean_names() %>%
      dplyr::mutate_at(
        vars(duration_mins, level, score),
        list(as.integer)
      ) %>%
      dplyr::mutate(start_date = lubridate::as_datetime(start_date))

  res <- dat_clean

  res

}


filter_for_pre_post_cases <- function(herzog_results) {

  complete_cases <-

    herzog_results %>%
      group_by(case_id, skill) %>%
      filter("Baseline" %in% test, "Post" %in% test)

  res <- complete_cases

  res

}

calculate_differences <- function(herzog_results) {

  post_compared_to_baseline <-

    herzog_results %>%

      filter_for_pre_post() %>%
      arrange(test) %>%
      group_by(case_id, skill) %>%
      summarize_at(vars(duration_mins, level, score, start_date), list(~ last(.) - first(.)))

  res <- post_compared_to_baseline

  res

}

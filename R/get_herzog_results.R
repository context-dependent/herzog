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
    dplyr::na_if("-")

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
      dplyr::filter(stat %in% c("Level", "Score", "Duration (mins)", "Start Date", "# Items", "# Correct")) %>%
      tidyr::spread(stat, val) %>%
      janitor::clean_names() %>%
      dplyr::mutate_at(
        vars(duration_mins, level, score),
        list(as.integer)
      ) %>%
      dplyr::mutate(start_date = lubridate::as_datetime(start_date)) %>%
      dplyr::mutate(correct_responses = glue::glue("{number_correct} / {number_items}")) %>%
      dplyr::select(-number_correct, -number_items)

  res <- dat_clean

  res

}


#' filter herzog results for eligible pre-post cases
#'
#' @param herzog_results
#'
#' @return
#' @export
#'
#' @examples
filter_for_pre_post_cases <- function(herzog_results) {

  complete_cases <-

    herzog_results %>%
      dplyr::group_by(case_id, skill) %>%
      dplyr::filter("Baseline" %in% test, "Post" %in% test)

  res <- complete_cases

  res

}

#' Calculate pre-post differences
#'
#' @param herzog_results
#'
#' @return
#' @export
#'
#' @examples
calculate_differences <- function(herzog_results) {

  post_compared_to_baseline <-

    herzog_results %>%

      filter_for_pre_post_cases() %>%
      dplyr::arrange(test) %>%
      dplyr::group_by(case_id, skill) %>%
      dplyr::summarize_at(vars(duration_mins, level, score, start_date), list(~ last(.) - first(.)))

  res <- post_compared_to_baseline

  res

}

#' Pivot results wide to printable format for communication with clients
#'
#' @param herzog_results
#'
#' @return
#' @export
#'
#' @examples
pivot_to_print <- function(herzog_results) {

  res <- herzog_results %>%

    tidyr::pivot_wider(names_from = c(skill, test), values_from = c(duration_mins, level, score, start_date, correct_responses)) %>%
    dplyr::select(esg_user_id, case_id, matches("Numeracy"), matches("Document Use")) %>% select(matches("Baseline"), matches("Post")) %>%
    janitor::clean_names() %>%
    dplyr::select(-matches("start_date|duration_mins"))

  res

}

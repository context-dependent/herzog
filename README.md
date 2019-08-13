`herzog` is an R package designed to automatically scrape Herzog
assessment results from the assessment\_summary page for your
organization.

Get results
-----------

`get_herzog_results` takes the assessment summary url and returns a data
frame where each row is an assessment.

    devtools::install_github("context-dependent/herzog")

    ## Skipping install of 'herzog' from a github remote, the SHA1 (76aabc9e) has not changed since last install.
    ##   Use `force = TRUE` to force installation

    library(tidyverse)

    ## Registered S3 methods overwritten by 'ggplot2':
    ##   method         from 
    ##   [.quosures     rlang
    ##   c.quosures     rlang
    ##   print.quosures rlang

    ## Registered S3 method overwritten by 'rvest':
    ##   method            from
    ##   read_xml.response xml2

    ## -- Attaching packages ------------------------------------------------------------------------------------ tidyverse 1.2.1 --

    ## v ggplot2 3.1.1       v purrr   0.3.2  
    ## v tibble  2.1.1       v dplyr   0.8.0.1
    ## v tidyr   0.8.3       v stringr 1.4.0  
    ## v readr   1.3.1       v forcats 0.4.0

    ## -- Conflicts --------------------------------------------------------------------------------------- tidyverse_conflicts() --
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

    library(herzog)


    url <- "https://bpade.essentialskillsgroup.com/custom_reports/assessment_summary.php"

    herzog_results <- get_herzog_results(url)

    knitr::kable(head(herzog_results), format = "markdown")

<table>
<thead>
<tr class="header">
<th style="text-align: right;">esg_user_id</th>
<th style="text-align: left;">case_id</th>
<th style="text-align: left;">skill</th>
<th style="text-align: left;">test</th>
<th style="text-align: right;">duration_mins</th>
<th style="text-align: right;">level</th>
<th style="text-align: right;">score</th>
<th style="text-align: left;">start_date</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: right;">97041</td>
<td style="text-align: left;">HO-827092</td>
<td style="text-align: left;">Document Use</td>
<td style="text-align: left;">Baseline</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">2018-05-11 07:26:51</td>
</tr>
<tr class="even">
<td style="text-align: right;">97041</td>
<td style="text-align: left;">HO-827092</td>
<td style="text-align: left;">Numeracy</td>
<td style="text-align: left;">Baseline</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">2018-05-11 07:30:03</td>
</tr>
<tr class="odd">
<td style="text-align: right;">97154</td>
<td style="text-align: left;">HO-313554</td>
<td style="text-align: left;">Document Use</td>
<td style="text-align: left;">Baseline</td>
<td style="text-align: right;">16</td>
<td style="text-align: right;">2</td>
<td style="text-align: right;">263</td>
<td style="text-align: left;">2018-05-14 09:15:56</td>
</tr>
<tr class="even">
<td style="text-align: right;">97154</td>
<td style="text-align: left;">HO-313554</td>
<td style="text-align: left;">Document Use</td>
<td style="text-align: left;">Post</td>
<td style="text-align: right;">20</td>
<td style="text-align: right;">2</td>
<td style="text-align: right;">249</td>
<td style="text-align: left;">2018-06-18 07:20:36</td>
</tr>
<tr class="odd">
<td style="text-align: right;">97154</td>
<td style="text-align: left;">HO-313554</td>
<td style="text-align: left;">Numeracy</td>
<td style="text-align: left;">Baseline</td>
<td style="text-align: right;">50</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">191</td>
<td style="text-align: left;">2018-05-14 09:38:23</td>
</tr>
<tr class="even">
<td style="text-align: right;">97154</td>
<td style="text-align: left;">HO-313554</td>
<td style="text-align: left;">Numeracy</td>
<td style="text-align: left;">Post</td>
<td style="text-align: right;">40</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">216</td>
<td style="text-align: left;">2018-06-18 07:50:20</td>
</tr>
</tbody>
</table>

The returned table has 7 meaningful columns:

-   `case_id`: unique identifier for the assessed participant
-   `skill`: skill tested. Currently the only skills returned are
    Document Use and Numeracy, though that will be made flexible in
    future versions.
-   `test`: whether this is the first (Baseline) or second (Post) test
    completed by the participant for the skill
-   `duration_mins`: how long the test took the participant to complete,
    rounded to the nearest minute
-   `score`: the score achieved on the assessment
-   `level`: the category of aptitude associated with the `score`
-   `start_date`: the date and time at which the assessment was started

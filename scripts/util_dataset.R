############################################################################
#                                                                          #
#   Defines some laboratory database specific retrieval functions          #
#                                                                          #
############################################################################

LAB_DB_LOCATION <- "~/Datasets/LabResults/"
LB_PARAM_TABLE_COLNAMES <- c(
    "db_row", "patient_id", "gender", "age", "order_id", "date", "time", "param",
    "value_c", "value_n", "is_numeric", "needs_revision", "qc_comment", "instrument",
    "unit", "normal_range", "ward_id", "lab_comment"
  )


#' Retrieve an archived labparam table from drive
#' 
#' @param drive_path string          Path to labparam table on Drive
#' @param colnames_to_add character  Column names for the table retrieved from Drive
#' @param keep_file logical          Keep downloaded file or not
#' 
#' @return data.frame                Clinical chemistry results for a given parameter code.
read_from_drive <- function(drive_path, colnames_to_add=LB_PARAM_TABLE_COLNAMES, keep_file=FALSE) {
  path <- drive_get(drive_path)
  drive_download(path, overwrite = TRUE)
  data_file <- basename(drive_path)
  data_table <- data_file %>%
    gzfile() %>%
    read.csv(sep="|", stringsAsFactors=FALSE, header=FALSE)
  colnames(data_table) <- colnames_to_add
  data_table$file_name <- data_file
  if(!keep_file) unlink(data_file)
  return(data_table)
}


#' Wrap multiple labparam code retrievals into a single function
#' 
#' @param param_codes character      A list of parameter codes to retrieve results for
#' @param lab_db_location string     Path to labparam folder on Drive
#' @param keep_file logical          Keep downloaded file or not
#' 
#' @return data.frame                Clinical chemistry results for a given set of parameter codes.
retrieve_labresults_by_paramcodes <- function(param_codes, lab_db_location=LAB_DB_LOCATION, keep_file=FALSE){
  param_codes %>%
    paste(lab_db_location, ., ".txt.gz", sep="") %>%
    map(read_from_drive) %>%
    map(mutate_all, as.character) %>%
    bind_rows() %>%
    mutate(
      value_n = as.numeric(value_n),
      age     = as.numeric(age)
    )
}


#' Join a second parameter to the main labparam table (for correlations)
#' 
#' @param primary_result_tab df      A table of labparameter results as primary basis to join to
#' @param additional_param_codes chr A list of parameter codes to retrieve and join
#' @param lab_param_name string      Name of the paramater set to refer to after join
#' @param days_flexible integer      Number of days difference in paired measurements to tolerate
#' 
#' @return data.frame                Clinical chemistry results paired with the primary parameter.
join_additional_measured_param <- function(
  primary_result_tab,
  additional_param_codes,
  lab_param_name,
  days_flexible=7
){
  
  lab_param_level <- paste(lab_param_name, "level", sep="_")
  lab_param_date <- paste(lab_param_name, "date", sep="_")
  lab_param_unit <- paste(lab_param_name, "unit", sep="_")
  
  additional_param_codes %>%
    retrieve_labresults_by_paramcodes() %>%
    mutate(
      !!lab_param_unit := unit,
      !!lab_param_level := as.numeric(value_n),
      !!lab_param_date := as.Date(date, format = "%Y.%m.%d"),
    ) %>%
    filter(!is.na(!!lab_param_level)) %>%
  select(!!lab_param_date, !!lab_param_level, !!lab_param_unit, patient_id) %>%
  right_join(primary_result_tab, by="patient_id") %>%
  filter(!is.na(!!lab_param_date)) %>%
  mutate(
    SECDIFF = abs(as.numeric(difftime(!!sym(lab_param_date), DATE, units="days")))
  ) %>%
  filter(SECDIFF < days_flexible) %>%
  arrange(SECDIFF) %>%
  select(-SECDIFF) %>%
  distinct(db_row, .keep_all=TRUE)
}

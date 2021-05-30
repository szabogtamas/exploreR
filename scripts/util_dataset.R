############################################################################
#                                                                          #
#   Defines some laboratory database specific retrieval functions          #
#                                                                          #
############################################################################


LB_PARAM_TABLE_COLNAMES <- c(
    "db_row", "patient_id", "gender", "age", "order_id", "date", "time", "param",
    "value_c", "value_n", "is_numeric", "needs_revision", "qc_comment", "instrument", "unit",
    "normal_range", "ward_id", "lab_comment"
  )

### Retrieve an archived labparam table from drive
read_from_drive <- function(drive_path, colnames_to_add=LB_PARAM-TABLE_COLNAMES) {
  path <- drive_get(drive_path)
  drive_download(path, overwrite = TRUE)
  data_file <- basename(drive_path)
  data_table <- data_file %>%
    gzfile() %>%
    read.csv(sep="|", stringsAsFactors=FALSE, header=FALSE)
  colnames(data_table) <- colnames_to_add
  data_table$file_name <- data_file
  unlink(data_file)
  return(data_table)
}

### Wrap multiple labparam code retrievals int a single function
retrieve_labresults_by_paramcodes <- function(param_codes, lab_db_location=LAB_DB_LOCATION){
  param_codes %>%
  paste(lab_db_location, ., ".txt.gz", sep="") %>%
  map(read_from_drive) %>%
  bind_rows()
}

### Join a second parameter to the main labparam table (for correlations)
join_additional_measured_param <- function(
  primary_result_tab,
  additional_param_codes,
  lab_param_name,
  days_flexible=7
){
  
  lab_param_level <- paste(lab_param_name, "level", sep="_")
  lab_param_date <- paste(lab_param_name, "date", sep="_")
  
  additional_param_codes %>%
    retrieve_labresults_by_paramcodes() %>%
    mutate(
      !!lab_param_level := as.numeric(value_n),
      !!lab_param_date := as.Date(date, format = "%Y.%m.%d"),
    ) %>%
    filter(!is.na(!!lab_param_level)) %>%
  select(!!lab_param_date, !!lab_param_level, patient_id) %>%
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

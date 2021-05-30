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

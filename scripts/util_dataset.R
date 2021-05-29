read_from_drive <- function(drive_path) {
  path <- drive_get(drive_path)
  drive_download(path, overwrite = TRUE)
  data_file <- basename(drive_path)
  data_table <- data_file %>%
    gzfile() %>%
    read.csv(sep="|", stringsAsFactors=FALSE, header=FALSE)
  colnames(data_table) <- c(
    "db_row", "patient_id", "gender", "age", "order_id", "date", "time", "param",
    "value_c", "value_n", "is_numeric", "needs_revision", "qc_comment", "instrument", "unit",
    "normal_range", "ward_id", "lab_comment"
  )
  data_table$file_name <- data_file
  unlink(data_file)
  return(data_table)
}

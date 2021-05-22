#!/usr/bin/env Rscript

############################################################################
#                                                                          #
#   Uploads contents of a given local folder to Google drive.              #
#   Sync is probably a bit of an exacerbation, as nothing is downloaded    #
#                                                                          #
############################################################################

args <- commandArgs(trailingOnly=TRUE)
LOCAL_FOLDER <- args[[1]]
DRIVE_FOLDER <- args[[2]]

library("googledrive")

drive_auth(cache = "/home/rstudio/local_files/.secrets", use_oob = TRUE)

already_uploaded_files <- drive_ls(file.path("~", DRIVE_FOLDER))
locally_present_files <- dir(LOCAL_FOLDER, full.names=TRUE)
presence_in_cloud <- basename(locally_present_files) %in% already_uploaded_files$name

upload_as_missing <- locally_present_files[!presence_in_cloud]
present_but_comapare <- data.frame(
  LOCAL_PATH = locally_present_files[presence_in_cloud],
  stringsAsFactors = FALSE
)
present_but_comapare$LOCAL_HASH <- md5sum(present_but_comapare$LOCAL_PATH)
present_but_comapare$DRIVE_PATH <- basename(present_but_comapare$LOCAL_PATH)

for(local_file in upload_as_missing){
  drive_upload(
    local_file,
    path = file.path("~", DRIVE_FOLDER, basename(local_file))
  )
}

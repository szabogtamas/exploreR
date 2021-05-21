#!/usr/bin/env Rscript

############################################################################
#                                                                          #
#   Uploads contents of a given local folder to Google drive.              #
#   Sync is probably a bit of an exacerbation, as nothing is downloaed     #
#                                                                          #
############################################################################

args <- commandArgs(trailingOnly=TRUE)
LOCAL_FOLDER <- args[[1]]
DRIVE_FOLDER <- args[[2]]

library("googledrive")

drive_auth(cache = "/home/rstudio/local_files/.secrets", use_oob = TRUE)

all_files <- dir(LOCAL_FOLDER, full.names=TRUE)

for(local_file in all_files){
  drive_upload(
    local_file,
    path = file.path("~", DRIVE_FOLDER, basename(local_file))
  )
}

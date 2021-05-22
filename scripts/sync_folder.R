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

library(tools)
library(googledrive)

drive_auth(cache = "/home/rstudio/local_files/.secrets", use_oob = TRUE)

already_uploaded_files <- drive_ls(file.path("~", DRIVE_FOLDER))
locally_present_files <- dir(LOCAL_FOLDER, full.names=TRUE)
presence_in_cloud <- basename(locally_present_files) %in% already_uploaded_files$name

for(local_file in locally_present_files[!presence_in_cloud]){
  drive_upload(
    local_file,
    path = file.path("~", DRIVE_FOLDER, basename(local_file))
  )
}

for(local_file in locally_present_files[presence_in_cloud]){
  
  local_file_md5 <- md5sum(local_file)
  local_file_bn <- basename(local_file)
  full_pth_on_drive <- file.path("~", DRIVE_FOLDER, local_file_bn)
  
  drive_download(full_pth_on_drive, overwrite=TRUE)
  if(local_file_md5 != md5sum(local_file_bn)){
    drive_upload(local_file, path = full_pth_on_drive)
  }
  unlink(local_file_bn)
  
}
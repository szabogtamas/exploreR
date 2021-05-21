#!/usr/bin/env Rscript

############################################################################
#                                                                          #
#   Uploads contents of a given local folder to Google drive.              #
#   Sync is probably a bit of an exacerbation, as nothing is downloaed     #
#                                                                          #
############################################################################

args <- commandArgs(trailingOnly=TRUE)
LOCAL_FOLDER <- args[[1]]

library("googledrive")

all_files <- drive_find(pattern = "chicken")

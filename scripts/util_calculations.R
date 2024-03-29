############################################################################
#                                                                          #
#   Defines some utility functions for basic stats calculations            #
#                                                                          #
############################################################################


# Define small function summarizing median, iqr and outlier boundaries
calc_quantile_boundaries <- function(serum_level, th=NULL) {
  out <- serum_level %>%
    quantile(probs=c(0.25, 0.75), na.rm=TRUE) %>%
    t() %>%
    data.frame() %>%
    `colnames<-`(c("LQ", "UQ")) %>%
    mutate(
      MEDIAN = median(serum_level, na.rm=TRUE),
      RANGE = 1.5 * (UQ - LQ),
      LB = LQ - RANGE,
      UB = UQ + RANGE,
      N_MEASURED = length(serum_level)
    )
  if(!is.null(th)){
    out$NPATH <- sum(serum_level > th)
  }
  return(out)
}

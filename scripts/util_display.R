############################################################################
#                                                                          #
#   Defines some functions that help display tables and plots in reports   #
#                                                                          #
############################################################################


show_tab <- function(tab){
  datatable(
    tab, extensions = "Buttons",
    options = list(
      scrollX="400px",
      dom = "Bfrtip",
      buttons = list(
        list(
          extend = "collection",
          buttons = c("csv", "excel"),
          text = "Download"
        )
      )
    )
  )
}

### Patching Pheatmap with diagonal column labels;
### Idea from https://www.thetopsites.net/article/54919955.shtml
draw_colnames_30 <- function (coln, gaps, ...) {
    coord = pheatmap:::find_coordinates(length(coln), gaps)
    x = coord$coord - 0.5 * coord$size
    res = grid:::textGrob(coln, x = x, y = unit(1, "npc") - unit(3,"bigpts"), vjust = 0.5, hjust = 1, rot = 30, gp = grid:::gpar(...))
    return(res)}

assignInNamespace(x="draw_colnames", value="draw_colnames_30", ns=asNamespace("pheatmap"))

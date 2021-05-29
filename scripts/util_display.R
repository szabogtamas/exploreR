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


# Setup ------------------------------------------------------------------------------


## Packages =======================================================================================

box::use(data.table[...],
         shiny[...],
         bslib[...],
         bsicons[...],
         data.table[...],
         magrittr[...],
         react[...],
         highcharter[...],
         reactable[...],
         waiter[...],
         shinycssloaders[withSpinner],
         shinyWidgets[...],
         DBI[...],
         duckdb[...],
         shinyjs[...],
         shinymanager[...]
)

box::use(md = ./db_operations)

## App Options =======================================================================================

options(warn = -1)
options(shiny.maxRequestSize = 200*1024^2)
options(semantic.themes = TRUE)

credentials = data.frame(
    user = c("admin", "mestre", 'thechain'),
    password = c("6789", "Cafezinho.2024", 'botinha'),
    admin = c(TRUE, FALSE, FALSE),
    stringsAsFactors = FALSE
)



## Connect to DB ======================================================================

if(!exists('conn')) {
    md$connect_md(store_conn = TRUE, apikey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImRldm1pbGFuaW1hbEBnbWFpbC5jb20iLCJzZXNzaW9uIjoiZGV2bWlsYW5pbWFsLmdtYWlsLmNvbSIsInBhdCI6Ijgyc0NzNy1tMnl4b1VWNG9ZYmhINU5rc2VJLVlmR3Q3azMwZ0o0T2pRWTQiLCJ1c2VySWQiOiIxNmM3MDlmMi1hYTYxLTQxYzgtOTM4OC01ZmMzNjc1MTRhMTgiLCJpc3MiOiJtZF9wYXQiLCJpYXQiOjE3Mjk0MjkzODd9.p0waIa4bRYQ-2DGrfK4Fa2CDgDV03gIoUzex3uySjqo')
} else {
    message(glue::glue("{crayon::bgGreen('[OK]')} MotherDuck DB Already connected."))
}
if(exists('conn')) {
    check_db = md$check_database_md(conn, database_name = 'my_db')
}
if(exists('conn') & isTRUE(check_db)) {
    check_dt_clients = md$check_table_md(conn, table_name = 'dt_clients_info', verbose = TRUE)
}
if(exists('conn') & isTRUE(check_db) & isTRUE(check_dt_clients)) {
    DBI::dbExecute(conn, 'USE my_db')
}


## Theme =======================================================================================

shinyWidgets::chooseSliderSkin('Round', color = '#49566c')

### Dashboard
mlm_theme = bs_theme(
    version = 5,
    font_scale = 1,
    primary = "#313c52",  
    secondary = '#9ba9be',
    success = '#0ca678',
    info = '#17a2b8',
    warning = '#f59f00',
    danger = '#d63939',
    base_font = font_google("Libre Franklin", local = TRUE),
    code_font = c("Courier", "monospace"),
    heading_font = font_google("Libre Franklin", wght = 900, local = TRUE),
)


### Reactable
mlm_reactable_theme = reactableTheme(
    color = '#49566c',
    backgroundColor = 'f8fafc',
    borderColor = "#e2e8f0",
    stripedColor = "#c8d3e1",
    highlightColor = "#c8d3e1",
    headerStyle = list(fontSize = '12px', paddingTop = '10px', paddingBottom = '5px', color = '#242526', fontWeight = 'bold'),
    cellStyle = list(fontFamily = "Inter, sans-serif", fontSize = '10px'),
    style = list(fontFamily = "Inter, sans-serif", fontSize = '10px', color = '#49566c'),
    searchInputStyle = list(width = "100%")
)


mlm_reactable = function(DTW, filter = TRUE, ...) {
    reactable(DTW,
              theme = mlm_reactable_theme,
              highlight = TRUE,
              outlined = FALSE,
              compact = TRUE,
              wrap = FALSE,
              defaultPageSize = 16,
              filterable = filter
    )
}



# Info ==========================================================================================

link_github = tags$a(
    shiny::icon("github"), "Github",
    href = "https://github.com/abrahammbs93/autoreporting",
    target = "_blank"
)

link_milanimal = tags$a(
    shiny::icon("web"), "Milanimal",
    href = "https://milanimal.com",
    target = "_blank"
)


# Load App =======================================================================================

source(file.path('00_functions.R'))
source(file.path('01_z_overview.R'))
source(file.path('01_z_table_newcustomermodal.R'))
source(file.path('01_z_table.R'))
source(file.path('01_ui.R'))
source(file.path('02_server.R'))

# Setup ------------------------------------------------------------------------------


## Packages =======================================================================================

box::use(data.table[...],
         shiny[...],
         googledrive[...],
         waiter[...],
         react[...],
         bslib[...],
         bsicons[...],
         highcharter[...],
         reactable[...],
         reactablefmtr[...],
         htmltools[...],
         shinycssloaders[withSpinner],
         magrittr[...],
         openxlsx[...],
         jsonlite[...],
         lubridate[...],
         duckdb[...],
         DBI[...],
         lubridate[...],
         shinymanager[...]
         
)



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



## Connect to Google Drive API ======================================================================

googledrive::drive_auth(path = "ethereal-runner-333607-19d761b0b18d.json")
file.remove("data/production.duckdb")
drive_download(drive_get(id="1fF2lrk2OvvNER-SsnFqir4l26Yl4jzwG"), path = "data/production.duckdb", overwrite = TRUE)
con = dbConnect(duckdb::duckdb(), file.path('data', "production.duckdb"))



## Theme =======================================================================================

### Dashboard
mlm_theme = bs_theme(
    # bootswatch = 'zephyr',
    version = 5,
    font_scale = 0.8,
    primary = "black",
    base_font = font_google("Libre Franklin", local = TRUE),
    code_font = c("Courier", "monospace"),
    heading_font = font_google("Libre Franklin", wght = 900, local = TRUE),
)



### Reactable
mlm_reactable_theme = reactableTheme(
    color = '#3E4C52',
    backgroundColor = 'white',
    borderColor = "#dfe2e5",
    stripedColor = "#f2f2f2",
    highlightColor = "#e6e6e6",
    headerStyle = list(fontSize = '12px', paddingTop = '10px', paddingBottom = '5px', color = '#242526', fontWeight = 'bold'),
    cellStyle = list(fontFamily = "Helvetica, sans-serif", fontSize = '10px'),
    style = list(fontFamily = "Helvetica, sans-serif", fontSize = '10px', color = '#3E4C52'),
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

paths = file.path('modules')

source(file.path(paths, '00_functions.R'))
source(file.path(paths, '01_z_overview.R'))
source(file.path(paths, '01_z_table_newcustomermodal.R'))
source(file.path(paths, '01_z_table.R'))
source(file.path(paths, '01_ui.R'))
source(file.path(paths, '02_server.R'))
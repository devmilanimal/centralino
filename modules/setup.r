


# : ========================================================================================================================================================



# Setup ------------------------------------------------------------------------------


## Packages =======================================================================================

box::use(data.table[...],
         shiny[...],
         shinyWidgets[...],
         waiter[...],
         react[...],
         tablerDash[...],
         pushbar[...],
         highcharter[...],
         reactable[...],
         shinycssloaders[withSpinner],
         magrittr[...],
         duckdb[...],
         DBI[...],
         shinymanager[...]
)

library(palmerpenguins)
box::use(md = modules/`00_functions`)


## App Options =======================================================================================

options(warn = -1)
options(shiny.maxRequestSize = 200*1024^2)

#credentials = data.frame(
#    user = c("admin", "mestre", 'thechain'),
#    password = c("6789", "Cafezinho.2024", 'botinha'),
#    admin = c(TRUE, FALSE, FALSE),
#    stringsAsFactors = FALSE
#)


## Connect to Motherduck ---------------------------------------------
if(!exists('conn')) {
    md$connect_md(store_conn = TRUE, apikey = Sys.getenv('MOTHERDUCK'))
}

if(exists('conn')) {
    check_1 = md$check_table_md(conn, table_name = 'dt_clients_info', verbose = FALSE)
    check_2 = md$check_table_md(conn, table_name = 'dt_client_training', verbose = FALSE)
    check_3 = md$check_table_md(conn, table_name = 'dt_client_contracts', verbose = FALSE)
    check_connection = all(check_1, check_2, check_3)
    rm(check_1, check_2, check_3)
    check_connection
}

DBI::dbExecute(conn, 'USE my_db')



## App Sections =======================================================================================

source(file.path('modules', "modules.R"))
source(file.path('modules', "home.R"))
source(file.path('modules', "customers.R"))
source(file.path('modules', "subscriptions.R"))
source(file.path('modules', "lessons.R"))
source(file.path('modules', "automations.R"))
source(file.path('modules', "main_ui.R"))
source(file.path('modules', "server.R"))

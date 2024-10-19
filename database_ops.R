
# Connect to DB ---------------------------------------------------------------------

## Packages ---------------------------------------------
box::use(data.table[...],
        DB=DBI[...],
        duckdb[...])


## Connect to Motherduck ---------------------------------------------

md$connect_md(store_conn = TRUE, apikey = Sys.getenv('MOTHERDUCK'))
if(exists('conn')) {
    check_1 = md$check_table_md(conn, table_name = 'dt_clients_info', verbose = FALSE)
    check_2 = md$check_table_md(conn, table_name = 'dt_client_training, verbose = FALSE')
    check_3 = md$check_table_md(conn, table_name = 'dt_client_contracts', verbose = FALSE)
    check_connection = all(check_1, check_2, check_3)
    rm(check_1, check_2, check_3)
    check_connection
}

DB$dbExecute(conn, 'USE my_db')
dt_clients = DB$dbGetQuery(conn, "SELECT * FROM dt_clients_info")

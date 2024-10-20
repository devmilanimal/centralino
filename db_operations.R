
connect_md <- function(store_conn = TRUE, apikey = FALSE) {
    # Create a DuckDB connection to local.duckdb
    conn <- DBI::dbConnect(duckdb::duckdb(), "local.duckdb")

    # Install and load MotherDuck extension
    DBI::dbExecute(conn, "INSTALL 'motherduck';")
    DBI::dbExecute(conn, "LOAD 'motherduck';")

    # Check if apikey is provided, otherwise fallback to environment variable
    if (is.character(apikey)) {
        auth_token <- apikey
    } else {
        auth_token <- Sys.getenv('MOTHERDUCK')
    }

    # Authenticate with MotherDuck
    auth_query <- glue::glue_sql("SET motherduck_token = {`auth_token`};", .con = conn)
    DBI::dbExecute(conn, auth_query)

    # Control variable to check if connection was successful
    connection_successful <- FALSE

    # Try connecting to MotherDuck
    tryCatch({
        DBI::dbExecute(conn, "PRAGMA MD_CONNECT")
        connection_successful <- TRUE  # Set to TRUE only if PRAGMA MD_CONNECT succeeds
    }, error = function(e) {
        if (grepl("Request failed: Your request is not authenticated. Please check your MotherDuck token.", e$message)) {
            message(glue::glue("{crayon::bgRed('[ERROR]')} MotherDuck API TOKEN is MISSING or INCORRECT."))
        } else {
            stop(e)
        }
    })

    # If connection was successful, check if conn is valid and store in global env if needed
    if (connection_successful) {
        if (isTRUE(DBI::dbIsValid(conn))) {
            message(glue::glue("{crayon::bgGreen('[OK]')} Connected to Flux MotherDuck."))
        } else {
            message(glue::glue("{crayon::bgRed('[ERROR]')} Could NOT connect to Flux MotherDuck."))
        }

        # Store the connection in the global environment if requested
        if (isTRUE(store_conn)) {
            assign('conn', conn, envir = .GlobalEnv)
        }
    }
}

check_database_md = function(connection, database_name) {

    conn = connection

    if (isTRUE(DBI::dbIsValid(conn))) {
        md_databases = DBI::dbGetQuery(conn, 'SELECT * FROM MD_ALL_DATABASES();')
        data.table::setDT(md_databases) 
        md_databases = md_databases[type == 'motherduck' & is_attached == TRUE]$alias
        if (database_name %in% md_databases) {
            message(glue::glue("{crayon::bgGreen('[OK]')} Database '{crayon::bgGreen(database_name)}' exists."))
            return(TRUE)
        } else {
            message(glue::glue("{crayon::bgYellow('[MISSING]')} Database '{crayon::bgYellow(database_name)}' does NOT exist."))
            return(FALSE)
        }
    } else {
        message(crayon::red("{crayon::bgRed('[ERROR]')} Connection is invalid or closed."))
        return(FALSE)
    }

}


check_table_md = function(connection, table_name, verbose = TRUE) {

    conn = connection

    if (isTRUE(DBI::dbIsValid(conn))) {
        md_tables = DBI::dbListTables(conn)
        if (table_name %in% md_tables) {
            if(isTRUE(verbose)) {
                message(glue::glue("{crayon::bgGreen('[OK]')} Table '{crayon::bgGreen(table_name)}' exists."))
            }
            return(TRUE)
        } else {
            if(isTRUE(verbose)) {
                message(glue::glue("{crayon::bgYellow('[MISSING]')} Table '{crayon::bgYellow(table_name)}' does NOT exist."))
                return(FALSE)
                }
        }
    } else {
        message(crayon::red("{crayon::bgRed('[ERROR]')} Connection is invalid or closed."))
        return(FALSE)
    }
}

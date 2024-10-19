
increment_id <- function(input_id) {
    # Define the prefix manually or extract dynamically
    prefix <- sub("([A-Z]+).*", "\\1", input_id)
    
    # Extract the numeric part
    numeric_part <- gsub("[^0-9]", "", input_id)
    
    # Convert to integer and increment
    numeric_value <- as.integer(numeric_part) + 1
    
    # Reconstruct the ID with the same number of leading zeros
    new_id <- sprintf("%s%05d", prefix, numeric_value)
    
    return(new_id)
}


calculate_age <- function(dob) {
    dob <- as.Date(dob)  # Parses dates in "YearMonthDay" format, adjust with dmy(), mdy(), etc., as needed
    current_date <- Sys.Date()
    age <- as.numeric(difftime(current_date, dob, units = "days")) / 365.25
    age <- floor(age)
    return(age)
}

calculate_expiry_date <- function(pass_type, start_date = Sys.Date()) {
    # Convert the start date to a Date object if it's not already
    start_date <- as.Date(start_date)
    
    # Calculate the expiry date based on the type of pass
    if (pass_type == "Monthly") {
        expiry_date <- start_date %m+% months(1)
    } else if (pass_type == "Quarter") {
        expiry_date <- start_date %m+% months(3)
    } else if (pass_type == "Semester") {
        expiry_date <- start_date %m+% months(6)
    } else if (pass_type == "Yearly") {
        expiry_date <- start_date %m+% months(12)
    } else {
        expiry_date <- start_date + 1
    }
    
    return(expiry_date)
}


#' Connect to a MotherDuck Database
#'
#' This function establishes a connection to a local DuckDB database and connects
#' to the MotherDuck API using the authentication token stored in the environment
#' variable `MOTHERDUCK`. It optionally stores the connection in the global
#' environment for future use.
#'
#' The function also handles authentication errors and informs the user if the
#' connection was successful or not.
#'
#' @param store_conn Logical, default is `TRUE`. If `TRUE`, the function stores the
#'   established DuckDB connection object (`conn`) in the global environment. If
#'   `FALSE`, it does not store the connection.
#' @param apikey Optional character. MotherDuck API token. If not provided, the
#'   function will use the token from the environment variable `MOTHERDUCK`.
#'
#' @details
#' The function first establishes a local DuckDB connection and installs and loads
#' the `motherduck` extension. It then sets the MotherDuck token using the token
#' stored in the `MOTHERDUCK` environment variable. If the connection is successful,
#' it confirms the connection status and optionally stores the connection.
#'
#' - If the MotherDuck token is missing or invalid, the function returns an error message.
#' - If the connection is successful, a message indicating success is displayed.
#'
#' @return
#' The function returns no value but will optionally store the `conn` object
#' in the global environment if `store_conn = TRUE`. On failure, error messages
#' are printed, and the function will stop execution if the error is not related
#' to authentication.
#'
#' @examples
#' \dontrun{
#'   # Connect and store the connection globally
#'   connect_md(TRUE)
#'
#'   # Connect without storing the connection globally
#'   connect_md(FALSE)
#' }
#'
#' @export
#' @import DBI
#' @import duckdb
#' @import glue
#' @import crayon
#' @importFrom DBI dbConnect dbExecute dbIsValid
#' @importFrom glue glue_sql
#' @importFrom crayon bgGreen bgRed

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


#' Check if a Table Exists in a MotherDuck Database
#'
#' This function checks whether a specified table exists in the connected
#' MotherDuck environment using an active DuckDB connection.
#'
#' @param connection A valid DuckDB connection object, typically returned by
#'   `DBI::dbConnect()`. This connection must be established and remain active.
#' @param table_name A character string representing the name of the table you want to check.
#' @param verbose A bolean to print messages
#'
#' @details
#' The function retrieves all tables in the currently connected database using
#' `DBI::dbListTables()`. If the specified `table_name` exists in the list of
#' tables, the function returns `TRUE` and prints a success message. Otherwise,
#' it returns `FALSE` and notifies the user that the table does not exist.
#'
#' If the connection object is invalid or closed, the function will return
#' `FALSE` and print an error message.
#'
#' @return
#' A logical value:
#' - `TRUE` if the specified `table_name` exists in the connected database.
#' - `FALSE` if the table does not exist or the connection is invalid.
#'
#' @examples
#' \dontrun{
#'   # Assuming you have an active connection named 'conn'
#'   check_table_md(conn, "my_table")
#' }
#'
#' @export
#' @import DBI
#' @import glue
#' @import crayon
#' @importFrom DBI dbListTables dbIsValid
#' @importFrom glue glue
#' @importFrom crayon bgGreen bgYellow bgRed red

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

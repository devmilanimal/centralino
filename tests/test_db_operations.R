
# Packages -----------------------------------------------
box::use(data.table[...],
         duckdb[...],
         googledrive[...],
         lubridate[...],
         DBI[...])

source(file.path('modules', '00_functions.R'))


# Load DB ------------------------------------------------
googledrive::drive_auth(path = "data/ethereal-runner-333607-19d761b0b18d.json")
drive_download(drive_get(id="1fF2lrk2OvvNER-SsnFqir4l26Yl4jzwG"), path = "data/production.duckdb", overwrite = TRUE)
con = dbConnect(duckdb::duckdb(), file.path('data', "production.duckdb"))


dbGetQuery(con, "SELECT COUNT(*) AS total_records FROM anagrafica")


DTS = dbGetQuery(con, "SELECT *  FROM anagrafica")
setDT(DTS)

DTS[, Start_Date := as.IDate(paste0(year(Sys.Date()) - ANNI_CLIENTE,'-', month(SCADENZA_ABBONAMENTO),'-01'), "%Y-%m-%d")]
DTS[, Start_Date := format(ceiling_date(Start_Date, "month") - days(1), "%Y-%m-%d")]

DTS[, RATA_SCADUTA := fcase(RATA < Sys.Date() + 15, 'LATE', 
                            RATA > Sys.Date() + 15, 'OK')]
DTS[, RATA_SCADUTA := fifelse(is.na(RATA_SCADUTA), 'NULL', RATA_SCADUTA)]

fwrite(DTS, 'sample_expanded.csv')



# ADD NEW RECORD ---------------------------------------

newcustomer_data = data.table(
    ID = 'BJJ00000', 
    NOME = 'cust_name', 
    COGNOME = 'cust_surnname', 
    CODICE_FISCALE = 'cust_cf', 
    EMAIL = 'email',
    TELEFONO = 39,
    INDIRIZZO = 'cust_address',
    PROVINCIA =  'cust_province',
    DATA_NASCITA = Sys.Date()- 6000,
    ETA = calculate_age(Sys.Date() - 6000),
    CINTURA = 'WHITE',
    DATA_CINTURA = Sys.Date(),
    ATLETA = TRUE,
    RELAZIONI_FAM = 'cust_fam',
    NAZIONE = 'cust_nation',
    SESSO = 'M',
    TIPO_ABBONAMENTO = 'Monthly',
    SCADENZA_ABBONAMENTO = calculate_expiry_date(pass_type = 'Monthly', Sys.Date()),
    ANNI_CLIENTE = 0,
    ATTIVO = TRUE,
    SOCIAL_INST = '@cust_social',
    FOTO = NULL
)
newcustomer_data


# Make sure to format the DATE and BOOLEAN values correctly for SQL
sql_command <- sprintf("INSERT INTO anagrafica (ID, NOME, COGNOME, CODICE_FISCALE, EMAIL, TELEFONO, INDIRIZO, PROVINCIA, DATA_NASCITA, ETA, CINTURA, DATA_CINTURA, ATLETA, RELAZIONI_FAM, NAZIONE, SESSO, TIPO_ABBONAMENTO, SCADENZA_ABBONAMENTO, ANNI_CLIENTE, ATTIVO, SOCIAL_INST, FOTO) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', %d, '%s', '%s', %s, '%s', '%s', '%s', '%s', '%s', %d, %s, '%s', %s);",
                       newcustomer_data[[1, "ID"]], newcustomer_data[[1, "NOME"]], newcustomer_data[[1, "COGNOME"]], newcustomer_data[[1, "CODICE_FISCALE"]],
                       newcustomer_data[[1, "EMAIL"]], newcustomer_data[[1, "TELEFONO"]], newcustomer_data[[1, "INDIRIZZO"]], newcustomer_data[[1, "PROVINCIA"]],
                       format(newcustomer_data[[1, "DATA_NASCITA"]], "%Y-%m-%d"), as.integer(newcustomer_data[[1, "ETA"]]), newcustomer_data[[1, "CINTURA"]], format(newcustomer_data[[1, "DATA_CINTURA"]], "%Y-%m-%d"), 
                       newcustomer_data[[1, "ATLETA"]], newcustomer_data[[1, "RELAZIONI_FAM"]], newcustomer_data[[1, "NAZIONE"]], newcustomer_data[[1, "SESSO"]],
                       newcustomer_data[[1, "TIPO_ABBONAMENTO"]], format(newcustomer_data[[1, "SCADENZA_ABBONAMENTO"]], "%Y-%m-%d"), as.integer(newcustomer_data[[1, "ANNI_CLIENTE"]]), newcustomer_data[[1, "ATTIVO"]],
                       newcustomer_data[[1, "SOCIAL_INST"]], if (is.null(newcustomer_data[[1, "FOTO"]])) "NULL" else sprintf("'%s'", newcustomer_data[[1, "FOTO"]]))

# Execute the SQL command
dbExecute(con, sql_command)
dbGetQuery(con, "SELECT COUNT(*) AS total_records FROM anagrafica")
DTS = dbGetQuery(con, "SELECT *  FROM anagrafica")
setDT(DTS)
DTS[nrow(DTS)]

dbDisconnect(con)
drive_update(file = drive_get(id="1fF2lrk2OvvNER-SsnFqir4l26Yl4jzwG"), media = file.path('data', "production.duckdb"))
con = dbConnect(duckdb::duckdb(), file.path('data', "production.duckdb"))





# DELETE RECORD -----------------------------------------------

# Replace 'your_table_name' with the actual name of your table
value_to_delete = 'BJJ00000'
sql_command <- sprintf("DELETE FROM anagrafica WHERE ID = '%s'", value_to_delete)
dbExecute(con, sql_command)




# CREATE TABLE --------------------------------------------------
dbExecute(con, "DROP TABLE IF EXISTS anagrafica")

dbWriteTable(con, "anagrafica", DTS, overwrite = TRUE, row.names = FALSE)
dbDisconnect(con)

drive_upload(media = 'data/production.duckdb',
             name = 'production.duckdb',
             path = as_id('1fF2lrk2OvvNER-SsnFqir4l26Yl4jzwG'))

drive_update(file = drive_get(id="1fF2lrk2OvvNER-SsnFqir4l26Yl4jzwG"), media = file.path('data', "production.duckdb"))







# Create Awesome Reactable:
library(reactable)
library(reactablefmtr)
mlm_reactable_theme = reactableTheme(
    color = '#3E4C52',
    backgroundColor = 'white',
    borderColor = "#dfe2e5",
    stripedColor = "#f2f2f2",
    highlightColor = "#e6e6e6",
    headerStyle = list(fontSize = '12px', paddingTop = '10px', paddingBottom = '5px', backgroundColor = 'black', color = 'white', fontWeight = 'bold'),
    cellStyle = list(fontFamily = "Helvetica, sans-serif", fontSize = '10px'),
    style = list(fontFamily = "Helvetica, sans-serif", fontSize = '10px', color = '#3E4C52'),
    searchInputStyle = list(width = "100%")
)

reactable(DTS,
          theme = mlm_reactable_theme,
          highlight = TRUE,
          outlined = FALSE,
          compact = TRUE,
          wrap = FALSE,
          paginationType = "jump",
          defaultPageSize = 12,
          filterable = TRUE,
          selection = "single",
          onClick = "select",
          defaultColDef = colDef(na = "–", minWidth = 70)
          # columns = list()
)

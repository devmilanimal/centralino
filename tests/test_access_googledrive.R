

# Packages -----------------------------------------------
box::use(data.table[...],
         googledrive[...],
         duckdb[...],
         DBI[...])


# Load DB ------------------------------------------------


drive_auth(path = "data/ethereal-runner-333607-19d761b0b18d.json")
drive_ls()



# List some files to find your specific file
# drive_ls(pattern = "production.duckdb")

# Or directly find your file by name
drive_download(drive_get(id="1fF2lrk2OvvNER-SsnFqir4l26Yl4jzwG"), path = "data/production.duckdb", overwrite = TRUE)



# Upload backup 
backupdate = paste0('mlm-', Sys.Date(), '-backup', '.duckdb')
uploaded_file = drive_upload(media = 'data/production.duckdb',
                             name = backupdate,
                             path = as_id('14EoCWBgMPJ96KRuvqcjf4p2n5m8k-DyT'))




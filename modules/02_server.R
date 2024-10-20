


server_app = function(input, output, session) {
    
    ### Login
    
    res_auth = secure_server(
        check_credentials = check_credentials(credentials)
    )
    
    ### Download locally the DuckDB from Google Drive
    
    conn = reactiveVal(con)
    
    ### Retrieve DB from Drive
    observeEvent(input$act_tbl_retrievedb, {
        if(!file.exists(file.path('data', "production.duckdb"))){
            waiter_show(html = tagList(
                spin_fading_circles(),
                br(),
                "Loading data... Please wait.")
            )
        drive_download(drive_get(id="1fF2lrk2OvvNER-SsnFqir4l26Yl4jzwG"), path = "data/production.duckdb", overwrite = TRUE)
        con = dbConnect(duckdb::duckdb(), file.path('data', "production.duckdb"))
        conn(con)
            waiter_hide()
        } else {
            file.remove("data/production.duckdb")
            waiter_show(html = tagList(
                spin_fading_circles(),
                br(),
                "Loading data... Please wait.")
            )
            drive_download(drive_get(id="1fF2lrk2OvvNER-SsnFqir4l26Yl4jzwG"), path = "data/production.duckdb", overwrite = TRUE)
            con = dbConnect(duckdb::duckdb(), file.path('data', "production.duckdb"))
            conn(con)
            waiter_hide()
        }
    })
    
    ### Upload Backup DB to Drive
    observeEvent(input$act_tbl_backupdb, {
        # req(react$conn)
        
        if (is.null(react$conn)) {
            showModal(modalDialog(
                title = "Warning",
                "Warning, you need to retrieve the DB first.",
                footer = modalButton("Close")
            ))} else {
        
        waiter_show(html = tagList(
            spin_fading_circles(),
            br(),
            "Uploading backup data... Please wait.")
        )
        con = react$conn
        dbDisconnect(con)
        
        backupdate = paste0('mlm-', Sys.Date(), '-backup', '.duckdb')
        uploaded_file = drive_upload(media = 'data/production.duckdb',
                                     name = backupdate,
                                     path = as_id('14EoCWBgMPJ96KRuvqcjf4p2n5m8k-DyT'))
        
        con = dbConnect(duckdb::duckdb(), file.path('data', "production.duckdb"))
        conn(con)
        
        waiter_hide()
        
        showNotification(
            paste("Backup DB completed"),
            type = "warning",
            duration = 1500  # Notification duration in milliseconds
        )
            }
        
    })
    
    ### Load DB
    DTW = reactiveVal(NULL)
    
    observe({
        req(react$conn)
        con = react$conn
        DTS = dbGetQuery(con, "SELECT *  FROM anagrafica")
        setDT(DTS)
        DTS[, Start_Date := as.IDate(paste0(year(Sys.Date()) - ANNI_CLIENTE,'-', month(SCADENZA_ABBONAMENTO),'-01'), "%Y-%m-%d")]
        DTS[, Start_Date := format(ceiling_date(Start_Date, "month") - days(1), "%Y-%m-%d")]
        DTS[, RATA_SCADUTA := fcase(RATA < Sys.Date() + 15, 'LATE', 
                                    RATA > Sys.Date() + 15, 'OK')]
        DTS[, RATA_SCADUTA := fifelse(is.na(RATA_SCADUTA), 'NULL', RATA_SCADUTA)]
        DTW(DTS)
    })
    
    
    # Overview ------------------------------------------------------------------
    
    ### Create Customer table
    table_customer_ov = reactiveVal(NULL)
    
    observe({
        req(react$DTW)
        table_customer_ov(react$DTW)
    })
    
    table_customer_ov_business = reactiveVal(NULL)
    
    observe({
        req(react$DTW)
        
        DTS = copy(react$DTW)
        # DTS = DTS[RATA_SCADUTA >= as.Date(input$ov_customer_range[1]) & RATA_SCADUTA <= as.Date(input$ov_customer_range[2])]
        DTS = DTS[RATA >= as.Date(input$ov_customer_range[1]) & RATA <= as.Date(input$ov_customer_range[2])]
        
        table_customer_ov_business(DTS)
    })     
    
    output$plot_ov_new_customers = 
    
    output$plot_ov_due_payment = renderHighchart({
        req(react$table_customer_ov_business)
        DTS = copy(react$table_customer_ov_business)
        
        DTS[, .N, by = 'RATA_SCADUTA'][RATA_SCADUTA != 'NULL'] %>%
            hchart(
                "pie", hcaes(x = as.character(RATA_SCADUTA), y = N),
            ) %>%
            hc_exporting(enabled = TRUE) %>% 
            hc_colors(c('#FFB807', '#D2E8E3')) %>%
            hc_xAxis(title = list(text = NULL), categories = DTS[order(-RATA_SCADUTA)]$RATA_SCADUTA) %>%
            hc_exporting(enabled = TRUE) 
    })     
    
    output$tbl_ov_due_payment = renderReactable({
        req(react$table_customer_ov_business)
        
        DTS = copy(react$table_customer_ov_business)
        DTS[, ID_col := '#8CBEB2']
        DTS[, CINTURA_col := fcase(CINTURA == 'White', '#e6e6e6',
                                   CINTURA == 'Blue', '#0099DD',
                                   CINTURA == 'Purple', '#7275A6',
                                   CINTURA == 'Brown', '#736355',
                                   CINTURA == 'Black', '#242526')]
        DTS[, ATLETA_col := fcase(ATLETA == TRUE, '#C78880',
                                  ATLETA == FALSE, '#F2EBBF')]
        DTS[, SESSO_col := fcase(SESSO == 'M', '#94A69F',
                                 SESSO == 'F', '#F7D6D2')]
        DTS[, RATA_SCADUTA_col := fcase(RATA_SCADUTA == 'LATE', '#FFB807',
                                        RATA_SCADUTA == 'OK', '#A2A632',
                                        RATA_SCADUTA == 'NULL', '#DDDEC6')]
        DTS[, ATTIVO_col := fcase(ATTIVO == TRUE, '#26C4A5',
                                  ATTIVO == FALSE, '#D2E8E3')]
        setcolorder(DTS, neworder = c("ID", "NOME", 'COGNOME', "CINTURA", 'DATA_CINTURA', 'ATLETA', "TIPO_ABBONAMENTO", 'ATTIVO', "SCADENZA_ABBONAMENTO", 'RATA', 'RATA_SCADUTA', 'ANNI_CLIENTE'))
        reactable(DTS[RATA_SCADUTA == 'LATE'],
                  theme = mlm_reactable_theme,
                  highlight = TRUE,
                  outlined = FALSE,
                  compact = TRUE,
                  wrap = FALSE,
                  paginationType = "jump",
                  defaultPageSize = 10,
                  filterable = TRUE,
                  resizable = TRUE,
                  selection = "single",
                  onClick = "select",
                  defaultColDef = colDef(na = "–", minWidth = 70),
                  columns = list(
                      ID = colDef(sticky = 'left', cell = pill_buttons(data = DTS, color_ref = 'ID_col')),
                      ID_col = colDef(show = FALSE),
                      CINTURA = colDef(cell = pill_buttons(data = DTS, color_ref = 'CINTURA_col')),
                      CINTURA_col = colDef(show = FALSE),
                      ATLETA = colDef(cell = pill_buttons(data = DTS, color_ref = 'ATLETA_col')),
                      ATLETA_col = colDef(show = FALSE),
                      SESSO = colDef(cell = pill_buttons(data = DTS, color_ref = 'SESSO_col')),
                      SESSO_col = colDef(show = FALSE),
                      ATTIVO = colDef(cell = pill_buttons(data = DTS, color_ref = 'ATTIVO_col')),
                      ATTIVO_col = colDef(show = FALSE),
                      RATA_SCADUTA = colDef(cell = pill_buttons(data = DTS, color_ref = 'RATA_SCADUTA_col')),
                      RATA_SCADUTA_col = colDef(show = FALSE)
                  ),
                  columnGroups = list(
                      colGroup(name = "Personal", columns = c("ID", "NOME", 'COGNOME'), headerStyle = list(fontSize = '10px', paddingTop = '10px', paddingBottom = '5px', backgroundColor = 'black', color = 'white', fontWeight = 'bold')),
                      colGroup(name = "PASS", columns = c("TIPO_ABBONAMENTO", 'ATTIVO', "SCADENZA_ABBONAMENTO", 'RATA', 'RATA_SCADUTA', 'ANNI_CLIENTE'),
                               headerStyle = list(fontSize = '10px', paddingTop = '10px', paddingBottom = '5px', backgroundColor = 'black', color = 'white', fontWeight = 'bold')),                
                      colGroup(name = "Details", columns = c('SESSO', 'NAZIONE', 'CODICE_FISCALE', 'EMAIL', 'TELEFONO', 'INDIRIZO', 'PROVINCIA', 'DATA_NASCITA', 'ETA', 'RELAZIONI_FAM'),
                               headerStyle = list(fontSize = '10px', paddingTop = '10px', paddingBottom = '5px', backgroundColor = 'black', color = 'white', fontWeight = 'bold')),
                      colGroup(name = "BJJ", columns = c("CINTURA", 'DATA_CINTURA', 'ATLETA'),
                               headerStyle = list(fontSize = '10px', paddingTop = '10px', paddingBottom = '5px', backgroundColor = 'black', color = 'white', fontWeight = 'bold')),
                      colGroup(name = "SOCIAL", columns = c('SOCIAL_INST', "FOTO"),
                               headerStyle = list(fontSize = '10px', paddingTop = '10px', paddingBottom = '5px', backgroundColor = 'black', color = 'white', fontWeight = 'bold'))
                  )
        )
        
    })
    
    
    observeEvent(input$act_tbl_filter_ov, {
        # req(react$conn)
        if (is.null(react$conn)) {
            showModal(modalDialog(
                title = "Warning",
                "Warning, you need to retrieve the DB first.",
                footer = modalButton("Close")
            ))} else {
                
                DTS = copy(react$DTW)
                
                if (input$ov_name != "") {
                    DTS = DTS[grep(input$ov_name, paste(NOME, COGNOME), ignore.case = TRUE)]
                }
                
                DTS_1 = DTS[ATTIVO %chin% unique(input$ov_isactive)]
                DTS_2 = DTS_1[CINTURA %chin% unique(input$ov_belt)]
                DTS_3 = DTS_2[ETA >= as.numeric(input$ov_agerange[1]) & ETA <= as.numeric(input$ov_agerange[2])]
                DTS_4 = DTS_3[SCADENZA_ABBONAMENTO >= as.Date(input$ov_expirydate[1]) & SCADENZA_ABBONAMENTO <= as.Date(input$ov_expirydate[2])]
                
                table_customer_ov(DTS_4)
            }
    })    
    
    output$plot_ov_customers_belts = renderHighchart({
        req(react$table_customer_ov)
        DTS = react$table_customer_ov
        DTS2 = DTS[, .N, by = .(CINTURA)]
        DTS2[, CINTURA_ov := fcase(CINTURA == 'White', '1. White',
                                   CINTURA == 'Blue', '2. Blue',
                                   CINTURA == 'Purple', '3. Purple',
                                   CINTURA == 'Brown', '4. Brown',
                                   CINTURA == 'Black', '5. Black')]
        ov_colors <- c("#e6e6e6","#0099DD", "#7275A6", "#736355", "#242526")
        DTS2[, CINTURA_ov := as.character(CINTURA_ov)]
        
        highchart() %>%
            hc_chart(type = "bar", inverted = TRUE) %>%
            hc_add_series(data = DTS2[order(CINTURA_ov)], name = "Count", type = "bar",
                          hcaes(x = CINTURA_ov, y = N), 
                          colorByPoint = TRUE) %>%
            hc_colors(ov_colors) %>%
            hc_xAxis(title = list(text = NULL), categories = DTS2[order(CINTURA_ov)]$CINTURA_ov) %>%
            hc_yAxis(title = list(text = NULL), labels = list(format = '{value}')) %>%
            hc_tooltip(pointFormat = 'Count: <b>{point.y}</b><br/>Category: {point.category}') %>%
            hc_legend(enabled = FALSE) %>%
            hc_plotOptions(series = list(
                borderRadius = 10,
                borderWidth = 1,
                showInLegend = FALSE
            )) %>%
            hc_exporting(enabled = TRUE)
    })
    
    output$plot_ov_customers_athletes = renderHighchart({
        req(react$table_customer_ov)
        DTS = react$table_customer_ov
        DTS2 = DTS[, .N, by = ATLETA] 
        DTS2 %>%
            hchart(
                "pie", hcaes(x = as.character(ATLETA), y = N),
            ) %>%
            hc_exporting(enabled = TRUE) %>% 
            hc_colors(c('#26C4A5', '#D2E8E3')) %>%
            hc_xAxis(title = list(text = NULL), categories = DTS2[order(-ATLETA)]$ATLETA) %>%
            hc_exporting(enabled = TRUE) 
    })    
    
    output$plot_ov_customers_age = renderHighchart({
        req(react$table_customer_ov)
        DTS = react$table_customer_ov
        dt_age = DTS[, .N, by = .(Age_Group = cut(ETA, breaks = seq(min(ETA), max(ETA) + 5, by = 5)))]
        dt_age[, Age_Group := as.character(Age_Group)]
        
        highchart() %>%
            hc_chart(type = "bar", inverted = TRUE) %>%
            hc_add_series(dt_age[order(-Age_Group)], "bar", hcaes(x = Age_Group, y = N), name = "Count",
                          colorByPoint = TRUE) %>%
            hc_colors('#3E4C52') %>%
            hc_xAxis(title = list(text = NULL), categories = dt_age[order(-Age_Group)]$Age_Group) %>%
            hc_yAxis(title = list(text = NULL), labels = list(format = '{value}')) %>%
            hc_legend(enabled = FALSE) %>%
            hc_plotOptions(series = list(
                borderRadius = 10,
                borderWidth = 1,
                showInLegend = FALSE
            )) %>%
            hc_exporting(enabled = TRUE) 
    })
    
    output$plot_ov_customers_sex = renderHighchart({
        req(react$table_customer_ov)
        DTS = react$table_customer_ov
        DTS[, .N, by = SESSO] %>%
            hchart(
                "pie", hcaes(x = SESSO, y = N),
            ) %>%
            hc_exporting(enabled = TRUE) %>% 
            hc_colors(c('#94A69F', '#F7D6D2')) %>%
            hc_exporting(enabled = TRUE) 
    })    
    
    
    # Customers Detail ------------------------------------------------------------------
    
    ### Create Customer table
    table_customer_cd = reactiveVal(NULL)
    
    observe({
        req(react$DTW)
        table_customer_cd(react$DTW)
    })
    
    observeEvent(input$act_tbl_filter, {
        # req(react$conn)
        if (is.null(react$conn)) {
            showModal(modalDialog(
                title = "Warning",
                "Warning, you need to retrieve the DB first.",
                footer = modalButton("Close")
            ))} else {
                
        DTS = copy(react$DTW)
        
        if (input$cd_name != "") {
            DTS = DTS[grep(input$cd_name, paste(NOME, COGNOME), ignore.case = TRUE)]
        }
        
        DTS_1 = DTS[ATTIVO %chin% unique(input$cd_isactive)]
        DTS_2 = DTS_1[CINTURA %chin% unique(input$cd_belt)]
        DTS_3 = DTS_2[ETA >= as.numeric(input$cd_agerange[1]) & ETA <= as.numeric(input$cd_agerange[2])]
        DTS_4 = DTS_3[SCADENZA_ABBONAMENTO >= as.Date(input$cd_expirydate[1]) & SCADENZA_ABBONAMENTO <= as.Date(input$cd_expirydate[2])]
        
        table_customer_cd(DTS_4)
        
        }
    })
    
    output$table_customer_full = renderReactable({
        req(react$table_customer_cd)
        
        DTS = copy(react$table_customer_cd)
        DTS[, ID_col := '#8CBEB2']
        DTS[, CINTURA_col := fcase(CINTURA == 'White', '#e6e6e6',
                                   CINTURA == 'Blue', '#0099DD',
                                   CINTURA == 'Purple', '#7275A6',
                                   CINTURA == 'Brown', '#736355',
                                   CINTURA == 'Black', '#242526')]
        DTS[, ATLETA_col := fcase(ATLETA == TRUE, '#C78880',
                                  ATLETA == FALSE, '#F2EBBF')]
        DTS[, SESSO_col := fcase(SESSO == 'M', '#94A69F',
                                 SESSO == 'F', '#F7D6D2')]
        DTS[, RATA_SCADUTA_col := fcase(RATA_SCADUTA == 'LATE', '#FFB807',
                                        RATA_SCADUTA == 'OK', '#A2A632',
                                        RATA_SCADUTA == 'NULL', '#DDDEC6')]
        DTS[, ATTIVO_col := fcase(ATTIVO == TRUE, '#26C4A5',
                                  ATTIVO == FALSE, '#D2E8E3')]
        setcolorder(DTS, neworder = c("ID", "NOME", 'COGNOME', "CINTURA", 'DATA_CINTURA', 'ATLETA', "TIPO_ABBONAMENTO", 'ATTIVO', "SCADENZA_ABBONAMENTO", 'RATA', 'RATA_SCADUTA', 'ANNI_CLIENTE'))
        reactable(DTS,
                  theme = mlm_reactable_theme,
                  highlight = TRUE,
                  outlined = FALSE,
                  compact = TRUE,
                  wrap = FALSE,
                  paginationType = "jump",
                  defaultPageSize = 12,
                  filterable = TRUE,
                  resizable = TRUE,
                  selection = "single",
                  onClick = "select",
                  defaultColDef = colDef(na = "–", minWidth = 70),
                  columns = list(
                      ID = colDef(sticky = 'left', cell = pill_buttons(data = DTS, color_ref = 'ID_col')),
                      ID_col = colDef(show = FALSE),
                      CINTURA = colDef(cell = pill_buttons(data = DTS, color_ref = 'CINTURA_col')),
                      CINTURA_col = colDef(show = FALSE),
                      ATLETA = colDef(cell = pill_buttons(data = DTS, color_ref = 'ATLETA_col')),
                      ATLETA_col = colDef(show = FALSE),
                      SESSO = colDef(cell = pill_buttons(data = DTS, color_ref = 'SESSO_col')),
                      SESSO_col = colDef(show = FALSE),
                      ATTIVO = colDef(cell = pill_buttons(data = DTS, color_ref = 'ATTIVO_col')),
                      ATTIVO_col = colDef(show = FALSE),
                      RATA_SCADUTA = colDef(cell = pill_buttons(data = DTS, color_ref = 'RATA_SCADUTA_col')),
                      RATA_SCADUTA_col = colDef(show = FALSE)
                  ),
                  columnGroups = list(
                      colGroup(name = "Personal", columns = c("ID", "NOME", 'COGNOME'), headerStyle = list(fontSize = '10px', paddingTop = '10px', paddingBottom = '5px', backgroundColor = 'black', color = 'white', fontWeight = 'bold')),
                      colGroup(name = "PASS", columns = c("TIPO_ABBONAMENTO", 'ATTIVO', "SCADENZA_ABBONAMENTO", 'RATA', 'RATA_SCADUTA', 'ANNI_CLIENTE'),
                               headerStyle = list(fontSize = '10px', paddingTop = '10px', paddingBottom = '5px', backgroundColor = 'black', color = 'white', fontWeight = 'bold')),                
                      colGroup(name = "Details", columns = c('SESSO', 'NAZIONE', 'CODICE_FISCALE', 'EMAIL', 'TELEFONO', 'INDIRIZO', 'PROVINCIA', 'DATA_NASCITA', 'ETA', 'RELAZIONI_FAM'),
                               headerStyle = list(fontSize = '10px', paddingTop = '10px', paddingBottom = '5px', backgroundColor = 'black', color = 'white', fontWeight = 'bold')),
                      colGroup(name = "BJJ", columns = c("CINTURA", 'DATA_CINTURA', 'ATLETA'),
                               headerStyle = list(fontSize = '10px', paddingTop = '10px', paddingBottom = '5px', backgroundColor = 'black', color = 'white', fontWeight = 'bold')),
                      colGroup(name = "SOCIAL", columns = c('SOCIAL_INST', "FOTO"),
                               headerStyle = list(fontSize = '10px', paddingTop = '10px', paddingBottom = '5px', backgroundColor = 'black', color = 'white', fontWeight = 'bold'))
                  )
        )
        
    })
    
    
    #### THIS PART IS FOR CLICKING THE REACTABLE AND SEEING THE CUSTOMER
    tbl_customer_select = reactiveVal(NULL)
    observe({
        selected = getReactableState("table_customer_full", "selected")
        tbl_customer_select(selected)
    })
    
    
    
    ### Modify Customer ----------------------------------------------
    
    customer_tomodify = reactiveVal(NULL)
    
    observeEvent(input$act_tbl_modifycustomer, {
        
        if (is.null(react$conn)) {
            showModal(modalDialog(
                title = "Warning",
                "Warning, you need to retrieve the DB first.",
                footer = modalButton("Close")
            ))} else {
        
        showModal(modalDialog(
            title = "Confirm Modification",
            "Are you sure you want to modify this record?",
            textInput(inputId = 'id_modify', label = "Insert the Customer's ID to modify:", ''),
            footer = tagList(
                modalButton("Cancel"),
                actionButton("confirm_modification", "Confirm", class = "btn-primary")
            )
        ))
            }
    })    
    
    observeEvent(input$confirm_modification, {
        
        con = react$conn
        value_to_modify = input$id_modify
        before_mod = react$DTW[ID %in% value_to_modify]
        customer_tomodify(react$DTW[ID %in% value_to_modify])
        sql_command <- sprintf("DELETE FROM anagrafica WHERE ID = '%s'", value_to_modify)
        dbExecute(con, sql_command)
        
        tbl_customer_select(NULL)
        table_customer_cd_selected(NULL)
        
        removeModal()
        
        showModal(modalDialog(
            title = "Modify Customer",
            easyClose = TRUE,  
            footer = modalButton("Close"),
            
            # Form inputs
            fluidRow(column(width = 6, textInput("cust_name_mod", "Name", before_mod$NOME)), column(width = 6, textInput("cust_surname_mod", "Surname", before_mod$COGNOME))),
            fluidRow(column(width = 6, textInput("cust_cf_mod", "CF", before_mod$CODICE_FISCALE)), column(width = 6, textInput("cust_email_mod", "Email", before_mod$EMAIL))),
            fluidRow(column(width = 4, textInput("cust_tel_mod", "Telefono", before_mod$TELEFONO)), column(width = 6, textInput("cust_address_mod", "Address", before_mod$INDIRIZO)),column(width = 2, textInput("cust_province_mod", "Province", before_mod$PROVINC))),
            fluidRow(column(width = 6, textInput("cust_nation_mod", "Nation", before_mod$NAZIONE)), column(width = 6, selectInput("cust_sex_mod", "Sex", choices = c('M', 'F', 'Other'), selected = before_mod$SESSO))),
            dateInput("cust_birth_mod", "Birth date", before_mod$DATA_NASCITA),
            fluidRow(column(width = 3, selectInput("cust_belt_mod", "BJJ Belt", choices = c('White', 'Blue', 'Purple', 'Brown', 'Black'), selected = before_mod$CINTURA)), column(width = 6, dateInput("cust_beltdata_mod", "Belt earned", before_mod$DATA_CINTURA)), column(width = 3, selectInput("cust_athlete_mod", "Athlete", choices = c(TRUE, FALSE), selected = before_mod$ATLETA))),
            fluidRow(column(width = 4, selectInput("cust_pass_mod", "Pass", choices = c('Daily', 'Monthly', 'Quarter', 'Semester', 'Yearly'), selected = before_mod$TIPO_ABBONAMENTO)), column(width = 4, textInput("cust_social_mod", "Social networks", before_mod$SOCIAL_INST)), column(width = 4, textInput("cust_fam_mod", "Family", before_mod$RELAZIONI_FAM))),
            dateInput("cust_pass_scadenza", "Expiry date pass", before_mod$SCADENZA_ABBONAMENTO),
            dateInput("cust_rata_mod", "Next payment", Sys.Date() + 30),
            # A submit button that does something with the input
            actionButton("act_tbl_submitcustomermod", "Modify", class = "btn-primary")
        ))        
        
        
    })    
    
    observeEvent(input$act_tbl_submitcustomermod, {
        waiter_show(html = tagList(
            spin_fading_circles(),
            br(),
            "Modifying customer data... Please wait.")
        )
        # Assuming data processing is successful
        name <- paste(input$cust_name_mod, input$cust_name_mod)
        cust_name <- input$cust_name_mod; cust_surnname = input$cust_surname_mod; cust_cf = input$cust_cf_mod; email <- input$cust_email_mod
        cust_tel <- input$cust_tel_mod; cust_address <- input$cust_address_mod; cust_province <- input$cust_province_mod; cust_nation <- input$cust_nation_mod
        cust_sex <- input$cust_sex_mod; cust_birth <- input$cust_birth_mod
        cust_belt <- input$cust_belt_mod; cust_beltdata <- input$cust_beltdata_mod; cust_athlete <- input$cust_athlete_mod
        cust_pass <- input$cust_pass_mod; cust_social <- input$cust_social_mod; cust_fam <- input$cust_fam_mod
        cust_pass_scadenza <- input$cust_pass_scadenza; cust_rata <- input$cust_rata_mod

        ids = react$customer_tomodify$ID
        newcustomer_data = data.table(
            ID = ids, NOME = cust_name, COGNOME = cust_surnname, CODICE_FISCALE = cust_cf, EMAIL = email,
            TELEFONO = cust_tel,
            INDIRIZZO = cust_address,
            PROVINCIA =  cust_province,
            DATA_NASCITA = cust_birth,
            ETA = calculate_age(cust_birth),
            CINTURA = cust_belt,
            DATA_CINTURA = cust_beltdata,
            ATLETA = cust_athlete,
            RELAZIONI_FAM = cust_fam,
            NAZIONE = cust_nation,
            SESSO = cust_sex,
            TIPO_ABBONAMENTO = cust_pass,
            SCADENZA_ABBONAMENTO = cust_pass_scadenza,
            ANNI_CLIENTE = 0,
            ATTIVO = TRUE,
            SOCIAL_INST = cust_social,
            FOTO = FALSE,
            RATA = cust_rata
        )

        con = react$conn
        sql_command = sprintf("INSERT INTO anagrafica (ID, NOME, COGNOME, CODICE_FISCALE, EMAIL, TELEFONO, INDIRIZO, PROVINCIA, DATA_NASCITA, ETA, CINTURA, DATA_CINTURA, ATLETA, RELAZIONI_FAM, NAZIONE, SESSO, TIPO_ABBONAMENTO, SCADENZA_ABBONAMENTO, ANNI_CLIENTE, ATTIVO, SOCIAL_INST, FOTO, RATA) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', %d, '%s', '%s', %s, '%s', '%s', '%s', '%s', '%s', %d, %s, '%s', '%s', '%s');",
                              newcustomer_data[[1, "ID"]], newcustomer_data[[1, "NOME"]], newcustomer_data[[1, "COGNOME"]], newcustomer_data[[1, "CODICE_FISCALE"]],
                              newcustomer_data[[1, "EMAIL"]], newcustomer_data[[1, "TELEFONO"]], newcustomer_data[[1, "INDIRIZZO"]], newcustomer_data[[1, "PROVINCIA"]],
                              format(newcustomer_data[[1, "DATA_NASCITA"]], "%Y-%m-%d"), as.integer(newcustomer_data[[1, "ETA"]]), newcustomer_data[[1, "CINTURA"]], format(newcustomer_data[[1, "DATA_CINTURA"]], "%Y-%m-%d"),
                              newcustomer_data[[1, "ATLETA"]], newcustomer_data[[1, "RELAZIONI_FAM"]], newcustomer_data[[1, "NAZIONE"]], newcustomer_data[[1, "SESSO"]],
                              newcustomer_data[[1, "TIPO_ABBONAMENTO"]], format(newcustomer_data[[1, "SCADENZA_ABBONAMENTO"]], "%Y-%m-%d"), as.integer(newcustomer_data[[1, "ANNI_CLIENTE"]]), newcustomer_data[[1, "ATTIVO"]],
                              newcustomer_data[[1, "SOCIAL_INST"]], "NULL" , newcustomer_data[[1, "RATA"]])

        # Execute the SQL command
        dbExecute(con, sql_command)
        DTS = dbGetQuery(con, "SELECT *  FROM anagrafica")

        DTW(DTS)
        table_customer_cd(DTS)
        table_customer_ov(DTS_3)

        dbDisconnect(con)
        drive_update(file = drive_get(id="1fF2lrk2OvvNER-SsnFqir4l26Yl4jzwG"), media = file.path('data', "production.duckdb"))
        con = dbConnect(duckdb::duckdb(), file.path('data', "production.duckdb"))
        conn(con)

        # Close the modal after submission
        removeModal()
        waiter_hide()

        # Display a toast notification
        showNotification(
            paste("Modified customer:", paste(cust_name, cust_surnname)),
            type = "message",
            duration = 1500  # Notification duration in milliseconds
        )

    })
    
    
    ### Delete customer -------------------------------------------
    observeEvent(input$act_tbl_deletecustomer, {
        
        if (is.null(react$conn)) {
            showModal(modalDialog(
                title = "Warning",
                "Warning, you need to retrieve the DB first.",
                footer = modalButton("Close")
            ))} else {
        
        showModal(modalDialog(
            title = "Confirm Deletion",
            "Are you sure you want to delete this record?",
            textInput(inputId = 'id_delete', label = "Insert the Customer's ID to remove:", ''),
            footer = tagList(
                modalButton("Cancel"),
                actionButton("confirm_delete", "Confirm", class = "btn-primary")
            )
        ))
                
            }
        
    })
        
    observeEvent(input$confirm_delete, {
        waiter_show(html = tagList(
            spin_fading_circles(),
            br(),
            "Deleting data... Please wait.")
        )
        con = react$conn
        value_to_delete = input$id_delete
        sql_command <- sprintf("DELETE FROM anagrafica WHERE ID = '%s'", value_to_delete)
        dbExecute(con, sql_command)
        
        tbl_customer_select(NULL)
        table_customer_cd_selected(NULL)
        
        DTS = dbGetQuery(con, "SELECT *  FROM anagrafica")
        
        DTW(DTS)
        table_customer_cd(DTS)
        table_customer_ov(DTS_3)
        
        dbDisconnect(con)
        drive_update(file = drive_get(id="1fF2lrk2OvvNER-SsnFqir4l26Yl4jzwG"), media = file.path('data', "production.duckdb"))
        con = dbConnect(duckdb::duckdb(), file.path('data', "production.duckdb"))
        conn(con)
        
        waiter_hide()
        removeModal()
        
        # Display a toast notification
        showNotification(
            paste("Customer removed:", input$id_delete),
            type = "message",
            duration = 1500  # Notification duration in milliseconds
        )
        
    })

    
    ### Add Customer ----------------------------------------------
    
    observeEvent(input$act_tbl_addcustomer, {
        
        if (is.null(react$conn)) {
            showModal(modalDialog(
                title = "Warning",
                "Warning, you need to retrieve the DB first.",
                footer = modalButton("Close")
            ))} else {
        
        showModal(modalDialog(
            title = "Add New Customer",
            easyClose = TRUE,  
            footer = modalButton("Close"),
            
            # Form inputs
            fluidRow(column(width = 6, textInput("cust_name", "Name", "")), column(width = 6, textInput("cust_surname", "Name", ""))),
            fluidRow(column(width = 6, textInput("cust_cf", "CF", "")), column(width = 6, textInput("cust_email", "Email", ""))),
            fluidRow(column(width = 4, textInput("cust_tel", "Telefono", "")), column(width = 6, textInput("cust_address", "Address", "")),column(width = 2, textInput("cust_province", "Province", ""))),
            fluidRow(column(width = 6, textInput("cust_nation", "Nation", "")), column(width = 6, selectInput("cust_sex", "Sex", choices = c('M', 'F', 'Other')))),
            dateInput("cust_birth", "Birth date", ""),
            fluidRow(column(width = 3, selectInput("cust_belt", "BJJ Belt", choices = c('White', 'Blue', 'Purple', 'Brown', 'Black'))), column(width = 6, dateInput("cust_beltdata", "Belt earned", Sys.Date())), column(width = 3, selectInput("cust_athlete", "Athlete", choices = c(TRUE, FALSE)))),
            fluidRow(column(width = 4, selectInput("cust_pass", "Pass", choices = c('Daily', 'Monthly', 'Quarter', 'Semester', 'Yearly'))), column(width = 4, textInput("cust_social", "Social networks", '')), column(width = 4, textInput("cust_fam", "Family", ''))),
            dateInput("cust_rata", "Next payment", Sys.Date() + 30),
            # A submit button that does something with the input
            actionButton("act_tbl_submitcustomer", "Add", class = "btn-primary")
        ))
        }
    })
    
    observeEvent(input$act_tbl_submitcustomer, {
        waiter_show(html = tagList(
            spin_fading_circles(),
            br(),
            "Adding data... Please wait.")
        )
        # Assuming data processing is successful
        name <- paste(input$cust_name, input$cust_name)
        cust_name <- input$cust_name; cust_surnname = input$cust_surname; cust_cf = input$cust_cf; email <- input$cust_email
        cust_tel <- input$cust_tel; cust_address <- input$cust_address; cust_province <- input$cust_province; cust_nation <- input$cust_nation
        cust_sex <- input$cust_sex; cust_birth <- input$cust_birth
        cust_belt <- input$cust_belt; cust_beltdata <- input$cust_beltdata; cust_athlete <- input$cust_athlete
        cust_pass <- input$cust_pass; cust_social <- input$cust_social; cust_fam <- input$cust_fam
        cust_rata <- input$cust_rata
        
        ids = increment_id(last(react$DTW$ID)) 
        
        newcustomer_data = data.table(
            ID = ids, NOME = cust_name, COGNOME = cust_surnname, CODICE_FISCALE = cust_cf, EMAIL = email,
            TELEFONO = cust_tel,
            INDIRIZZO = cust_address,
            PROVINCIA =  cust_province,
            DATA_NASCITA = cust_birth,
            ETA = calculate_age(cust_birth),
            CINTURA = cust_belt,
            DATA_CINTURA = cust_beltdata,
            ATLETA = cust_athlete,
            RELAZIONI_FAM = cust_fam,
            NAZIONE = cust_nation,
            SESSO = cust_sex,
            TIPO_ABBONAMENTO = cust_pass,
            SCADENZA_ABBONAMENTO = calculate_expiry_date(pass_type = cust_pass, Sys.Date()),
            ANNI_CLIENTE = 0,
            ATTIVO = TRUE,
            SOCIAL_INST = cust_social,
            FOTO = FALSE,
            RATA = cust_rata
    )
        
        con = react$conn
        
        sql_command = sprintf("INSERT INTO anagrafica (ID, NOME, COGNOME, CODICE_FISCALE, EMAIL, TELEFONO, INDIRIZO, PROVINCIA, DATA_NASCITA, ETA, CINTURA, DATA_CINTURA, ATLETA, RELAZIONI_FAM, NAZIONE, SESSO, TIPO_ABBONAMENTO, SCADENZA_ABBONAMENTO, ANNI_CLIENTE, ATTIVO, SOCIAL_INST, FOTO, RATA) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', %d, '%s', '%s', %s, '%s', '%s', '%s', '%s', '%s', %d, %s, '%s', '%s', '%s');",
                              newcustomer_data[[1, "ID"]], newcustomer_data[[1, "NOME"]], newcustomer_data[[1, "COGNOME"]], newcustomer_data[[1, "CODICE_FISCALE"]],
                              newcustomer_data[[1, "EMAIL"]], newcustomer_data[[1, "TELEFONO"]], newcustomer_data[[1, "INDIRIZZO"]], newcustomer_data[[1, "PROVINCIA"]],
                              format(newcustomer_data[[1, "DATA_NASCITA"]], "%Y-%m-%d"), as.integer(newcustomer_data[[1, "ETA"]]), newcustomer_data[[1, "CINTURA"]], format(newcustomer_data[[1, "DATA_CINTURA"]], "%Y-%m-%d"),
                              newcustomer_data[[1, "ATLETA"]], newcustomer_data[[1, "RELAZIONI_FAM"]], newcustomer_data[[1, "NAZIONE"]], newcustomer_data[[1, "SESSO"]],
                              newcustomer_data[[1, "TIPO_ABBONAMENTO"]], format(newcustomer_data[[1, "SCADENZA_ABBONAMENTO"]], "%Y-%m-%d"), as.integer(newcustomer_data[[1, "ANNI_CLIENTE"]]), newcustomer_data[[1, "ATTIVO"]],
                              newcustomer_data[[1, "SOCIAL_INST"]], "NULL" , newcustomer_data[[1, "RATA"]])
        
        # Execute the SQL command
        dbExecute(con, sql_command)        
        DTS = dbGetQuery(con, "SELECT *  FROM anagrafica")
        
        DTW(DTS)
        table_customer_cd(DTS)
        table_customer_ov(DTS_3)

        dbDisconnect(con)
        drive_update(file = drive_get(id="1fF2lrk2OvvNER-SsnFqir4l26Yl4jzwG"), media = file.path('data', "production.duckdb"))
        con = dbConnect(duckdb::duckdb(), file.path('data', "production.duckdb"))
        conn(con)
        
        # Close the modal after submission
        waiter_hide()
        
        removeModal()
        
        # Display a toast notification
        showNotification(
            paste("New customer added:", name),
            type = "message",
            duration = 1500  # Notification duration in milliseconds
        )
        
    })
    
    
    
    table_customer_cd_selected = reactiveVal(NULL)
    
    observe({
        req(react$table_customer_cd)
        DTS = copy(react$table_customer_cd)
        DTS_filtered = DTS[react$tbl_customer_select]
        table_customer_cd_selected(DTS_filtered)
    })
    
    ### FULL NAME
    output$tbl_fullname = renderText({
        req(react$table_customer_cd_selected)
        vec = paste(react$table_customer_cd_selected$NOME, react$table_customer_cd_selected$COGNOME)
        vec
    })
    output$tbl_fullname_age = renderText({
        req(react$table_customer_cd_selected)
        vec = paste('Età:', react$table_customer_cd_selected$ETA)
        vec
    })
    output$tbl_fullname_indirizzo = renderText({
        req(react$table_customer_cd_selected)
        vec = paste('Indirizzo:', react$table_customer_cd_selected$INDIRIZO)
        vec
    })
    
    ### BJJ
    output$tbl_bjj_belt = renderText({
        req(react$table_customer_cd_selected)
        vec = paste(react$table_customer_cd_selected$CINTURA)
        vec
    })
    output$tbl_bjj_belt_time = renderText({
        req(react$table_customer_cd_selected)
        vec = paste('Data cintura:', react$table_customer_cd_selected$DATA_CINTURA)
        vec
    })
    output$tbl_bjj_belt_athlete = renderText({
        req(react$table_customer_cd_selected)
        vec = paste('Gareggia:', react$table_customer_cd_selected$ATLETA)
        vec
    })    
    
    ### PASS
    output$tbl_pass_active = renderText({
        req(react$table_customer_cd_selected)
        if(nrow(react$table_customer_cd_selected) > 0) {
        if(react$table_customer_cd_selected$ATTIVO == TRUE) {vec = paste('Pass ATTIVO')
        } else if(react$table_customer_cd_selected$ATTIVO == FALSE) {vec = paste('Pass SCADUTO')
        } else {vec = paste('Pass')} 
        } else {vec = 'Pass'}
        vec
    })
    output$tbl_pass_type = renderText({
        req(react$table_customer_cd_selected)
        vec = paste(react$table_customer_cd_selected$TIPO_ABBONAMENTO)
        vec
    })
    output$tbl_pass_expire = renderText({
        req(react$table_customer_cd_selected)
        vec = paste('Scadenza:', react$table_customer_cd_selected$SCADENZA_ABBONAMENTO)
        vec
    })
    output$tbl_pass_rata = renderText({
        req(react$table_customer_cd_selected)
        vec = paste('Next payment:', react$table_customer_cd_selected$RATA)
        vec
    })    
    
    #### THIS PART IS FOR CLICKING THE REACTABLE AND SEEING THE CUSTOMER
    
    
    output$table_customer_cd_ov = renderReactable({
        req(react$table_customer_cd)
        mlm_reactable(react$table_customer_cd,
                      selection = "multiple", onClick = "select")
    })    
    
} 

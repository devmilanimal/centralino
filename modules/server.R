


server_app = function(input, output, session) {
    
    ### Login
    
    #res_auth = secure_server(
    #    check_credentials = check_credentials(credentials)
    #)

    setup_pushbar(blur = TRUE, overlay = TRUE)
    
    ### Connect to Motherduck
    
    ### Load DB
    DTW = reactiveVal(NULL)
    
    observe({
        con = conn
        DTS = dbGetQuery(con, "SELECT *  FROM dt_clients_info")
        setDT(DTS)
        DTW(DTS)
    })

    observeEvent(input$act_csm_pushbar, {
        pushbar_open(id = "customersPushbar")
  }) 

}
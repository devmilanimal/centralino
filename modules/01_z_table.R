

# Page Customer details ==============================================================================

page_customers = 
    
    layout_sidebar(
        
        sidebar = sidebar(
            title = NULL,
            open = 'open',
            bg = 'white',
            width = '40vh',
            actionButton(inputId = 'act_tbl_addcustomer', label = 'Add customer', icon = icon('person'), class = 'btn-primary'),
            actionButton(inputId = 'act_tbl_modifycustomer', label = 'Modify customer', icon = icon('person'), class = 'btn-secondary'),
            actionButton(inputId = 'act_tbl_deletecustomer', label = 'Delete customer', icon = icon('person'), class = 'btn-error'),
            p('Filter table:', style = 'font-weight:bold'),
            # padding = '1vh', gap = '1vh',
            selectInput(
                inputId = 'cd_isactive',
                label = 'Active:',
                choices = c("ACTIVE" = TRUE, "NON ACTIVE" = FALSE),
                selected = unique(c("ACTIVE" = TRUE, "NON ACTIVE" = FALSE)),
                multiple = TRUE
            ),
            textInput(
                inputId = 'cd_name', 
                label = 'Name search',
                placeholder = 'Insert name or surname ...'
            ),
            selectInput(
                inputId = 'cd_belt',
                label = 'BJJ Belt:',
                choices = c('White', 'Blue', 'Purple', 'Brown', 'Black'),
                selected = c('White', 'Blue', 'Purple', 'Brown', 'Black'),
                multiple = TRUE
            ),
            sliderInput(
                inputId = 'cd_agerange',
                label = 'Age range:',
                min = 1,
                max = 100,
                step = 1,
                value = c(16, 65),
                width = '95%'
            ),
            sliderInput(
                inputId = 'cd_expirydate',
                label = 'Expiry date:',
                min = as.Date('2023-01-01'),
                max = Sys.Date() + 365,
                value = c(as.Date('2023-01-01'), Sys.Date() + 30),
                width = '95%'
            ),
            
            actionButton(inputId = 'act_tbl_filter', label = 'Filter', class = 'btn-primary', icon = icon('filter')),
            actionButton(inputId = 'act_tbl_backupdb', label = 'Back-up DB', icon = icon('upload'), class = 'btn-success'),
            actionButton(inputId = 'act_tbl_retrievedb', label = 'Retreive Backup DB', icon = icon('server'), class = 'btn-warning'),
        ),
        
        page_fluid(
            
            fluidRow(
                card(min_height = '640px',
                    fluidRow(                
                        layout_column_wrap(
                            value_box(
                                title = "Full name",
                                value = textOutput(outputId = 'tbl_fullname'),
                                showcase = bs_icon("person-circle"),
                                p(textOutput(outputId = 'tbl_fullname_age')),
                                p(textOutput(outputId = 'tbl_fullname_indirizzo')),
                                min_height = '220px'
                            ),
                            value_box(
                                title = "Info",
                                value = textOutput(outputId = 'tbl_bjj_belt'),
                                showcase = bs_icon("fire"),
                                p(textOutput(outputId = 'tbl_bjj_belt_time')),
                                p(textOutput(outputId = 'tbl_bjj_belt_athlete')),
                                min_height = '220px'
                            ),
                            value_box(
                                title = textOutput(outputId = 'tbl_pass_active'),
                                value = textOutput(outputId = 'tbl_pass_type'),
                                showcase = bs_icon("credit card"),
                                p(textOutput(outputId = 'tbl_pass_expire')),
                                p(textOutput(outputId = 'tbl_pass_rata')),
                                min_height = '220px'
                            )
                        )
                    ),
                    fluidRow(
                        reactableOutput(outputId = 'table_customer_full') %>% withSpinner()
                        )
                    )
             )
    )
    
)

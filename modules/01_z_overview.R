

# Page Customer details ==============================================================================

page_overview = 
    
    layout_sidebar(
        
        sidebar = sidebar(
            title = NULL,
            open = 'open',
            bg = 'white',
            width = '40vh',
            
            p('Select customers period:', style = 'font-weight:bold'),
            dateRangeInput(
                inputId = 'ov_customer_range',
                label = NULL,
                start = Sys.Date() - 60,
                end = Sys.Date() + 60
            ),
            
            p('Filter table:', style = 'font-weight:bold'),
            selectInput(
                inputId = 'ov_isactive',
                label = 'Active:',
                choices = c("ACTIVE" = TRUE, "NON ACTIVE" = FALSE),
                selected = unique(c("ACTIVE" = TRUE, "NON ACTIVE" = FALSE)),
                multiple = TRUE
            ),
            textInput(
                inputId = 'ov_name', 
                label = 'Name search',
                placeholder = 'Insert name or surname ...'
            ),
            selectInput(
                inputId = 'ov_belt',
                label = 'BJJ Belt:',
                choices = c('White', 'Blue', 'Purple', 'Brown', 'Black'),
                selected = c('White', 'Blue', 'Purple', 'Brown', 'Black'),
                multiple = TRUE
            ),
            sliderInput(
                inputId = 'ov_agerange',
                label = 'Age range:',
                min = 1,
                max = 100,
                step = 1,
                value = c(16, 65),
                width = '95%'
            ),
            sliderInput(
                inputId = 'ov_expirydate',
                label = 'Expiry date:',
                min = as.Date('2023-01-01'),
                max = Sys.Date() + 365,
                value = c(as.Date('2023-01-01'), Sys.Date() + 30),
                width = '95%'
            ),
            
            actionButton(inputId = 'act_tbl_filter_ov', label = 'Filter', class = 'btn-primary', icon = icon('filter'))
    ),

page_fluid(
    fluidRow(
        column(width = 12,
        card(
            card_header('Business'),
            card_body(
                fluidRow(
                column(width = 4, highchartOutput(outputId = 'plot_ov_due_payment') %>% withSpinner()),
                column(width = 8, reactableOutput(outputId = 'tbl_ov_due_payment') %>% withSpinner()))
            )
            )
        )
        ),
    fluidRow(
        column(width = 8, 
               card(
                   card_header('Distribution of Belts'),
                   card_body(
                       highchartOutput(outputId = 'plot_ov_customers_belts') %>% withSpinner()
                   )
               )
        ),
        column(width = 4, 
               card(
                   card_header('Distribution of Athletes'),
                   card_body(
                       highchartOutput(outputId = 'plot_ov_customers_athletes') %>% withSpinner()
                   )
               )
        )
    ),
        fluidRow(
            column(width = 6, 
                   card(
                       card_header('Distribution of AGE'),
                       card_body(
                           highchartOutput(outputId = 'plot_ov_customers_age') %>% withSpinner()
                       )
                   )
                   ),
            column(width = 6, 
                   card(
                       card_header('Distribution of SEX'),
                       card_body(
                           highchartOutput(outputId = 'plot_ov_customers_sex') %>% withSpinner()
                       )
                   )
                )
        )
    )
)

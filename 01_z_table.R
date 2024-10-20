

# Page Customer details ==============================================================================

page_customers = 
    
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

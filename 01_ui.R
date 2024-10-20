

ui_app = 
    
    page_navbar(

    tags$style(HTML("
    body {
        background-color: #f8fafc; 
    }
    p {
        color: #49566c;
    }
    hr {
        color: #c8d3e1;
    }
    .tab-pane.html-fill-item.html-fill-container.bslib-gap-spacing.active.show {
            --bslib-navbar-margin: 0; 
         padding: 0vh;              
    } 
    ::-webkit-scrollbar {
        width: 6px;
    }

    ::-webkit-scrollbar-track {
        box-shadow: 0 0 0 1px #f8fafc;
        border-radius: 6px;
    }

    ::-webkit-scrollbar-thumb {
        background: #c8d3e1;
        border-radius: 6px;
    }
    h1, h2, h3 {
        color: #49566c;
        font-weight: bold;
    }
    .btn {
        font-size: 0.80rem;
        border-radius: 8px;
    }  
    .bslib-sidebar-layout>.collapse-toggle {
        background-color: #e2e8f0; 
    }  
    .bslib-card .card-header {
        color: #1d273b;
        font-size: 1.05rem;
    }
    .selectize-input {
        border: 0.5px solid #c8d3e1;
        border-radius: 8px;
        font-size: 0.90rem;

    }
    .selectize-control.multi .selectize-input > div {
        background-color: #f1f5f9;
    }
    .selectize-dropdown, .selectize-input, .selectize-input input {
     color: #49566c;
     font-size: 0.9rem;
     line-height: 1.5;
     font-size: 0.90rem;
    }    
    .form-control {
        border: 0.5px solid #c8d3e1;
        border-radius: 8px;
        font-size: 0.90rem;
    }
    .irs--shiny .irs-line{
        background-color: #c8d3e1;
    }  
    .irs--shiny .irs-grid-pol {
        background-color: #c8d3e1;
    }
    .irs--shiny .irs-bar {
        background-color: #313c52;
        border-top: 3px solid #313c52;
        border-bottom: 1px solid #313c52;
    }
    .irs--shiny .irs-handle {
        background-color: #313c52;
        width: 16px;
        height: 16px;
        }
    .irs--shiny .irs-from, .irs--shiny .irs-to, .irs--shiny .irs-single  {
       background-color: #9ba9be;
    }       
    .irs--shiny .irs-min, .irs--shiny .irs-max {
       background-color: #e2e8f0; 
    }
    ")
  ),
        title = 
            div(img(src = "milanimal_logo.png", height = "50px", width = "auto", style = 'padding-left: 2vh; padding-right: 3vh; padding-top: 2.5vh;')
        ),
        header = tagList(use_waiter()),
        window_title = 'MILANIMAL - Customer viewer',
        padding = '2vh',
        bg = 'white',
        theme = mlm_theme,
        useShinyjs(),
        nav_panel(title = "Overview",
                  page_overview
                  ),
        nav_panel(title = "Table", 
                  page_customers
                  ),
        nav_panel(title = "Info", 
                  p("Page under construction")
                  ),
        nav_spacer(),
        nav_menu(
            title = "Links",
            align = "right",
            nav_item(link_github),
            nav_item(link_milanimal)
        ),

        sidebar = sidebar(
            title = 'Customer Viewer',
            open = 'open',
            bg = '#f1f5f9',
            width = '40vh',
            gap = '1rem',
            actionButton(inputId = 'act_tbl_addcustomer', label = 'Add customer', icon = icon('person'), class = 'btn-primary'),
            actionButton(inputId = 'act_tbl_modifycustomer', label = 'Modify customer', icon = icon('person'), class = 'btn-secondary'),
            actionButton(inputId = 'act_tbl_deletecustomer', label = 'Delete customer', icon = icon('person'), class = 'btn-error'),
            
            # -------------------------------------
            hr(),
            
            checkboxGroupButtons(
                inputId = "cd_isactive",
                label = NULL,
                choices = c("ACTIVE" = TRUE, "NON ACTIVE" = FALSE),
                selected = unique(c("ACTIVE" = TRUE, "NON ACTIVE" = FALSE)),
                justified = TRUE,
                size = 'sm'
                ),
            sliderInput(
                inputId = 'cd_expirydate',
                label = 'Expiry date:',
                min = as.Date('2023-01-01'),
                max = Sys.Date() + 365,
                value = c(as.Date('2023-01-01'), Sys.Date() + 30),
                width = '95%'
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
            
            actionButton(inputId = 'act_tbl_filter', label = 'Filter', class = 'btn-primary', icon = icon('filter'))

        )
    )
    
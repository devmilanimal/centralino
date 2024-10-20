

ui_app = 
    
    page_navbar(
        title = 
        div(img(src = "milanimal_logo.png", height = "50px", width = "auto", style = 'padding-left: 2vh; padding-right: 3vh; padding-top: 2.5vh;')
        ),
        header = tagList(use_waiter()),
        window_title = 'MILANIMAL - Customer viewer',
        padding = '2vh',
        bg = 'black',
        theme = mlm_theme,
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
        )
    )
    
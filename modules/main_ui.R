

# : ========================================================================================================================================================

  ui_app = tablerDashPage(

    navbar = tablerDashNav(
      id = "mymenu",
      src = "milanimal.jpg",

    # NAV MENU ------------------------------------------------

    tablerNavMenu(
        tablerNavMenuItem(
          tabName = "Home",
          icon = "home",
          "Home"
        ),
        tablerNavMenuItem(
          tabName = "Customers",
          icon = "users",
          "Customers"
      ),
        tablerNavMenuItem(
          tabName = "Subscriptions",
          icon = "list",
          "Subscriptions"
      ),
        tablerNavMenuItem(
          tabName = "Lessons",
          icon = "calendar",
          "Lessons"
      ),
        tablerNavMenuItem(
          tabName = "Automations",
          icon = "box",
          "Automations"
      )
    ),

        # NAV RIGHT ------------------------------------------------

      tablerDropdown(
        tablerDropdownItem(
          title = "Item 1 title",
          href = "https://google.com",
          status = "danger",
          date = "now",
          "This is the first dropdown item"
        ),
        tablerDropdownItem(
          status = "warning",
          "This is the second dropdown item",
          date = "yesterday"
        ),
        tablerDropdownItem(
          title = "Item 3 title",
          "This is the third dropdown item"
        )
      )
    ),

   # TITLE ------------------------------------------------

    title = "Digital Brain",
    enable_preloader = TRUE,
    loading_duration = 2,

    # BODY ------------------------------------------------

    body = tablerDashBody(

     chooseSliderSkin("Round"),
      pushbar_deps(),
      use_waiter(),
      shinyjs::useShinyjs(),     

      tablerTabItems(

        tablerTabItem(
          tabName = "Home",
          fluidRow(
            page_home
          )
        ),
        tablerTabItem(
          tabName = "Customers",
          page_customers
      ),
        tablerTabItem(
          tabName = "Subscriptions",
          page_subs
      ),
        tablerTabItem(
          tabName = "Lessons",
          page_lessons
      ),
        tablerTabItem(
          tabName = "Automations",
          page_automations
      )
    ),

    # CSS CODE ------------------------------------------------

          tags$head(
    tags$style(HTML("
        .ml-auto, .mx-auto {
    margin-left: 0px !important
    }
       .d-flex {
      display: flex !important;
      justify-content: center;
      align-items: center;
    }
    ")))      
    )

   # END ------------------------------------------------

  )
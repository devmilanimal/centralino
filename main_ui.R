

# : ========================================================================================================================================================


# app
  ui_app = tablerDashPage(

    navbar = tablerDashNav(
      id = "mymenu",
      src = "milanimal_logo.png",

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
          tabName = "Lessons",
          icon = "calendar",
          "Lessons"
      ),
        tablerNavMenuItem(
          tabName = "Subscriptions",
          icon = "list",
          "Subscriptions"
      ),
        tablerNavMenuItem(
          tabName = "Automations",
          icon = "box",
          "Subscriptions"
      )
    ),
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

    title = "Digital Brain",
    enable_preloader = TRUE,
    loading_duration = 2,

    body = tablerDashBody(
#      chooseSliderSkin("Modern"),
      tablerTabItems(

        tablerTabItem(
          tabName = "Home",
          fluidRow(
            'PLACEHOLDER 1'
          )
        ),
        tablerTabItem(
          tabName = "Test",
          'PLACEHOLDER 2'
      )

      ),
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
  )
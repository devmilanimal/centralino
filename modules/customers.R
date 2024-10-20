


# : ========================================================================================================================================================



# Customers ------------------------------------------------------------------------------

page_customers = tagList(

    fluidRow(

        actionButton(inputId = 'act_csm_pushbar', label = 'Options', class = 'btn-primary'),

        hr(),

        'Customers'

    ),
    pushbar(
      from = "left",
      id = "customersPushbar",
      style="padding:20px;",
      tagList(
          h2('Trial'),
          numericInput(inputId = 'trial', label = 'trial', value = 50, step = 1, min = 0, max = 100),
          p('text here')
      )
    )
)
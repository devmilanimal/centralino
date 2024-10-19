# cards
flowCard <- tablerCard(
  title = "FlowGl Chart",
  closable = FALSE,
  zoomable = TRUE,
  options = tagList(
    tablerAvatar(status = "lime", url = "https://preview.tabler.io/static/avatars/000m.jpg")
  ),
  width = 12,
  'placeholder',
  footer = tablerTag(name = "build", addon = "passing", addonColor = "success")
)

profileCard <- tablerProfileCard(
  width = 12,
  title = "Dyann Escala",
  subtitle = "Mechanical Systems Engineer",
  src = "https://preview.tabler.io/static/photos/finances-us-dollars-and-bitcoins-currency-money.jpg",
  tablerSocialLinks(
    tablerSocialLink(
      name = "facebook",
      href = "https://www.facebook.com",
      icon = "facebook"
    ),
    tablerSocialLink(
      name = "twitter",
      href = "https://www.twitter.com",
      icon = "twitter"
    )
  )
)
####
# create ui for vacant property sales app

ui <- fluidPage(
  #title 
  titlePanel("Private Vacant Land Sale Prices"),
  sidebarLayout( # create side bar
    sidebarPanel(
      selectizeInput( #neighborhood selector, for parcel plotting
        inputId="neighborhood", 
        label="Neighborhood: ",
        choices=c("Search Neighborhood"= "","-", neighborhood_list),
        selected="-"),
      selectInput( #select prop class- filters neighborhood med and parcels
        inputId="prop_class",
        label = "Property Class: ",
        choices = c("Commerical Vacant"=202,
                    "Residential Vacant"=402,
                    "Industrial Vacant"=302
                    )
      ),
      sliderInput( #filters years for nbrhd median and parcel plotting
        inputId =  "year", 
        label = "Select time period:",
        min=min(prop_sales_prepped$year),
        max=max(prop_sales_prepped$year),
        value=c(2018, 2022),
        sep="",
        step=1,
        round=T,
        ticks=F
      )
    ),
    mainPanel( #plot map
      tabsetPanel(  
        type="tabs",
        tabPanel(
          "Map View",
          leafletOutput(
            "map",
            height=750)
          ), #end tab panel
        # tabPanel(
        #   "Data View",
        #   plotly::plotlyOutput(
        #     "time_series_plot",
        #     height=450
        #     )
        #  ) #end tabpanel
          tabPanel(
            "Read Me",
            includeMarkdown("include.md")
          )
        )
      )
    )
  )

######
#create backend for neighborhood property sales app

server <- function(input, output) {
  
  #create reactive data frame for neiborhood medians (citywide map)
  #filtered by year and property class 
  nbrhd_med <- reactive({#filter for prop_class input
    prop_sales_prepped %>%
    as.data.frame() %>% #not sf
    filter(property_class%in%input$prop_class & 
             (year >= input$year[1] &
             year <= input$year[2]))  %>% #filter year
    group_by(Neighborhood) %>% #group
    mutate(
      price_sq_ft = #calculate square foot price depending on grouped status
        if_else(
          !is.na(grouped),
          (sale_price_per/Parcel_Square_Footage),
          (sale_price/Parcel_Square_Footage)
        )) %>%
    summarize(count=n(), #counts 
              median_sq_ft_price = round(median(price_sq_ft, na.rm=T),2), #calc median sqft/neighborhood
              total_sales=n()) %>%  #calc total sales
    right_join(neighborhoods[,c(1:3, 7)], by=c("Neighborhood"="nhood_name")) %>% #join to neighborhood shapes
    sf::st_as_sf(.) %>% #convert to sf
    filter(!sf::st_is_empty(.)) %>%
    filter(!is.na(count))
  })#end nbrhd_med data frame reactive 
  
  #create palette for mapping choropleth of median sqft price
  binpal <- reactive({
    colorBin("Reds"
                     , nbrhd_med()$median_sq_ft_price
                     , c(0,5,10,20,50,200, max(nbrhd_med()$median_sq_ft_price,
                                           na.rm=T)) #calculate breaks
                     , pretty = FALSE
                     )
  }) #end binpal reactive
  
  #function for fill opacity
  fillOp <- function(x) {
    ifelse(is.na(x), 0, 1)
  } 
  
  #create popup labels 
  popupLabels <- reactive({
    sprintf(
    "<strong>%s</strong><br/>\
    <strong>Median price ft<sup>2</sup></strong>: $%g <br/>\
    <strong>Total Sales:</strong> %s"
    ,nbrhd_med()$Neighborhood
    ,nbrhd_med()$median_sq_ft_price
    ,nbrhd_med()$total_sales) %>% 
      lapply(htmltools::HTML)
  })#end popup label reactive \
  
  #hover labels
  hoverLabel <- reactive({ sprintf(
    "<strong>%s</strong>"
    ,nbrhd_med()$Neighborhood) %>% 
      lapply(htmltools::HTML)
  }) #end hover label reactive 

  m <- reactive({ #create reactive variable to store map 
    #uses reactive dataframe created above via filters
    leaflet(nbrhd_med()) %>%
      #add basemap
    addProviderTiles("Stamen.TonerLite")%>%
    addPolygons( #add neighborhood polygons
      fillColor=~binpal()(median_sq_ft_price) #apply color palette
      ,fillOpacity = ~fillOp(total_sales) #opacity control for hovering
      ,stroke=T   #other styling
      ,weight=2.5
      ,color='gray'
      ,popup = popupLabels() #apply popuplabel html
      ,dashArray = 1
      ,label=hoverLabel() #apply hover label html
      ,highlight = highlightOptions(weight = 5,
                                    color = "black",
                                    dashArray = "",
                                    #fillOpacity = ~fillOp(median_sq_ft_price),
                                    bringToFront = TRUE)
      ,group="neighborhood_medians"
    ) %>%
    #create legend using colorpal breaks
    addLegend(
      pal = binpal() #use binpal for legend
      ,values = ~median_sq_ft_price
      ,opacity = 1
      ,title="Median Price per ft2"
    )
    }) #end nbrdhd choropleth reactive
  
  #create choropleth map for sqft price

  output$map <- renderLeaflet({
  #ouput city neighborhoods default map
    m()
  }) #end map output reactive
  
  
  ####
  # create map for neighborhood select view
  observe({ #create observer for neighborhood select and watch for input changes
    if(input$neighborhood != "-") { 
      #check neighborhood input
      #exceutes when neighborhood input is changed
      neighborhood_sales <-
        prop_sales_prepped %>%
        filter( #filter for neighborhood, year, prop class
          property_class == input$prop_class &
            Neighborhood == input$neighborhood &
            (year >= input$year[1] &
            year <= input$year[2]) &
            (!is.na(sale_price) |
            !is.na(sale_price_per))
        )
      #filter for multiple parcel sales
      neighborhood_sales <- neighborhood_sales %>%
        group_by(parcel_number) %>%
        filter(sale_date == max(sale_date)) %>%
        ungroup()
      #create color bins for coloring parcels
      binpal <- colorBin("Reds" 
                         , neighborhood_sales$price_sq_ft_comb
                         , c(0,5,10,20,50,200
                             , max(neighborhood_sales$price_sq_ft_comb
                                   ,na.rm=T)) #calculate breaks
                         , pretty = FALSE
      )

      #create labels for popup
      nhoodpopupLabels <- sprintf( 
        #html reads data with % operator
        #line by line, html for data
      "<strong>%s</strong><br/>\ 
      <strong>Sale Price ft<sup>2</sup></strong>: $%g <br/>\
      <strong> Total Sale Price:</strong> $%s <br/>\
      <strong>Sale Date:</strong> %s </br>\
      <strong>Property Class:</strong> %s"
        ,neighborhood_sales$address #title
        ,neighborhood_sales$price_sq_ft_comb
        ,format(neighborhood_sales$price_comb,big.mark=",")
        ,neighborhood_sales$sale_date
        ,neighborhood_sales$prop_class_desc) %>%
        lapply(htmltools::HTML)
      
      #create map
    output$map <- renderLeaflet({
      leaflet(neighborhood_sales) %>%
        # add base map tiles
        addProviderTiles("CartoDB.Positron") %>%
        #add neighborhood boundaries
        addPolygons(
          data=neighborhoods[neighborhoods$nhood_name == input$neighborhood,]
          ,fillOpacity = 0
        ) %>%
        #add parcel polys
        addPolygons(
          fillColor=~binpal(price_sq_ft_comb)
          ,color='gray'
          ,weight=2
          ,fillOpacity = .9
          ,popup = nhoodpopupLabels
          )
    }) #end neighborhood map render
    } else {
      #if no neighborhood selected, render citywide map
      output$map <- renderLeaflet({
        #if not neighborhood input, use map created above
        m()
        }) #end citywide map render
      } #end ifelse statement
    }) #end neighborhood observe function
  
  ###
  #Create output for data tab view
  
  observe({ #reactive for neighborhood input
    if(input$neighborhood != "-"){
      #create df 
        plot_df <- prop_sales_prepped %>%
        filter( #filter for neighborhood, year, prop class
          property_class == input$prop_class &
            Neighborhood == input$neighborhood &
            (year >= input$year[1] &
               year <= input$year[2]) &
            (!is.na(sale_price) |
               !is.na(sale_price_per))
          ) 
    } else {#plot citwide data
      plot_df <- prop_sales_prepped %>%
        filter( #filter for neighborhood, year, prop class
          property_class == input$prop_class &
            (year >= input$year[1] &
               year <= input$year[2]) &
            (!is.na(sale_price) |
               !is.na(sale_price_per))
        ) 
    } #end ifelse 
    
    output$time_series_plot <- 
      plotly::renderPlotly({
        plotly::ggplotly(
          ggplot(plot_df
                 ,aes(x=sale_date
                 ,y=price_sq_ft_comb)
        ) +
          geom_jitter(alpha=.3) +
          theme_minimal() +
          ylim(c(0,1000)),
        dynamicTicks=T
        )
    }) #end ggplotly
    
  }) #end render plot
  
  } #end server function


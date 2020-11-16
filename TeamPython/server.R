# load library
library(shiny)
library(shinycustomloader)
library(tidyverse)
library(DT)
library(rtweet)
library(reactable)
library(glue)
library(keras)
library(wordcloud)
library(tensorflow)

#use_condaenv("r-reticulate", required = TRUE)

# load data
countries <- read_csv("data/New_balance_valid_url.csv")



# dataset for account information
account.country <- countries %>% select(favourites_count, followers_count, statuses_count, friends_count, listed_count)
# Define server logic required to show output
function(input, output, session) {
  # 1. data page
  # 1.1 download button
  output$download_TeamPython <- downloadHandler(
    filename = function() {
      paste0(Sys.Date(), "_TeamPython.csv")
    },
    content = function(file) {
      countries %>%
        write_csv(file)
    }
  )
 # 1.2 data table
  output$countries_table <- renderDT({
       countries %>%
            select(screen_name, country_code, country_name, tweet, favourites_count:banner_url, bounding_box, centroid) %>%
            arrange(desc(country_code))
    }, rownames = FALSE,extensions = "Buttons",
    options = list(
      buttons = c("excel", "pdf"),
      dom = "Bftip"))
  
  # 2.Search Tweets
  tweet_df <- eventReactive(input$get_data, {
    search_tweets(input$hashtag_to_search, n = input$num_tweets_to_download, include_rts = FALSE)
  })
  
  tweet_table_data <- reactive({
    req(tweet_df())
    tweet_df() %>%
      select(user_id, status_id, created_at, screen_name, text, favorite_count, 
             source, location, profile_banner_url, profile_image_url) %>%
      filter(between(as.Date(created_at), input$date_picker[1], input$date_picker[2]) ) %>%
      mutate(
        Tweet = glue::glue("{text} <a href='https://twitter.com/{screen_name}/status/{status_id}'>>> </a>")
        #URLs = purrr::map_chr(urls_expanded_url, make_url_html)
      )%>%
      select(DateTime = created_at, User = screen_name, Tweet, Likes = favorite_count,
             Location = location, Source = source, Profile = profile_image_url, Banner = profile_banner_url)
  })
  
  output$tweet_table <- renderReactable({
    reactable::reactable(tweet_table_data(), 
                         filterable = TRUE, searchable = TRUE, bordered = TRUE, striped = TRUE, highlight = TRUE,
                         showSortable = TRUE, defaultSortOrder = "desc", defaultPageSize = 25, showPageSizeOptions = TRUE, pageSizeOptions = c(25, 50, 75, 100, 200), 
                         columns = list(
                           DateTime = colDef(defaultSortOrder = "asc"),
                           User = colDef(defaultSortOrder = "asc"),
                           Tweet = colDef(html = TRUE, minWidth = 190, resizable = TRUE),
                           Likes = colDef(filterable = FALSE, format = colFormat(separators = TRUE)),
                           #RTs = colDef(filterable =  FALSE, format = colFormat(separators = TRUE)),
                           Location = colDef(filterable =  FALSE, format = colFormat(separators = TRUE)),
                           Source = colDef(filterable =  FALSE, format = colFormat(separators = TRUE)),
                           Profile = colDef(html = TRUE),
                           Banner = colDef(html = TRUE)
                           #URLs = colDef(html = TRUE)
                         )
    )
  })
  
  output$download_data <- downloadHandler(
    filename = function() {
      paste(input$hashtag_to_search, "_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(tweet_table_data(), file, row.names = FALSE)
    }
  )
  
  # 3. Visualize Account Information
  # Display box plot
  
  output$account_boxplot <- renderPlot({
    ggplot(account.country, aes(x = get(input$Select_Account))) + 
      geom_boxplot()
  })
  
  # 4. Image Recognition
  
  model <- application_resnet50(weights = 'imagenet')
  TOP_CLASSES            <- 10
  RESNET_50_IMAGE_FORMAT <- c(224, 224)
  
  outputtext <- reactive({
    req(input$file)
    
    img <- image_load(input$file$datapath, target_size = RESNET_50_IMAGE_FORMAT)
    x <- image_to_array(img)
    x <- array_reshape(x, c(1, dim(x)))
    x <- imagenet_preprocess_input(x)
    preds <- model %>% predict(x)
    df <- imagenet_decode_predictions(preds, top = TOP_CLASSES)[[1]][, c(2,3)]
    names(df) <- c("Object","Score")
    df$Object <- as.character(df$Object)
    df$Score <- as.numeric(as.character(df$Score))
    df
  })
  
  output$plot <- renderPlot({
    df <- outputtext()
    # Separate long categories into shorter terms, so that we can avoid "could not be fit on page. It will not be plotted" warning as much as possible
    objects <- strsplit(as.character(df$Object), ',')
    df <- data.frame(Object = unlist(objects), 
                     Score  = rep(df$Score, sapply(objects, FUN = length)))
    wordcloud(df$Object, df$Score, scale = c(4,2),
              colors = brewer.pal(6, "RdBu"), random.order = F)
  })
  
  output$outputImage <- renderImage({
    req(input$file)
    
    outfile <- input$file$datapath
    contentType <- input$file$type
    list(src = outfile,
         contentType=contentType,
         width = 400)
  }, deleteFile = TRUE)
  
  output$table <- renderDataTable({
    DT::datatable(outputtext(), 
                  rownames = FALSE,
                  options = list(pageLength = TOP_CLASSES, dom = 't'))
  })
  
  # Combined Model
  
 

}


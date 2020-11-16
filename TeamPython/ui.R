library(shiny)
library(shinycustomloader)
library(reactable)
library(tidyverse)
library(glue)
library(DT)
library(tensorflow)
# Define UI for application
navbarPage(
    "TeamPython",

    # Introduction
    tabPanel("Introduction",
             titlePanel("Accenture: Social Media Analysis"),
             # abstract
             sidebarLayout(
                 sidebarPanel("Abstract"),
                 mainPanel(
                 p("Twitter is a vast social media platform that contains millions of users of varied locations."),
                 p("Many studies on location prediction from social media content examine the predictive 
                           power of tweets and combinations with metadata."),
                 p("However, few focus on images as a feature in algorithms to predict location."),
                 p("This project aims to examine if users’ profile images, banner images, account information, 
                           and recent tweets have predictive power in predicting location."),
                 p("Data was collected using the Twitter API for users’ account information, geolocation, tweets, profile and banner images."),
                 p("Geolocation was transformed to the top 10 countries of active twitter use and “other” of grouped countries."),
                 p("The dataset was balanced and account information was normalized. Bert-Base-Multilingual and EfficientNet-b6 algorithms 
                  were used to extract embeddings from tweets and images, respectively."),
                 p("Features were fed into five tuned models of fully connected layers with SoftMax: 
                           Combined, Account information, Images, Tweet, and Images and Tweet."),
                 p("Two trials of 4,036 and 12,540 samples were implemented. Model performance 
                           was measured by accuracy. Best performances were seen with the 12,540 sample. 
                           Of note, the Combined model had 65% accuracy while the Images and Tweet 
                           model had the best performance at 66% in classifying location. 
                           The Tweet model has 65%, while the Account information model and the Images model had 28% and 27%, respectively."),
                 p("In conclusion, the Combined model did have predictive power in classifying users’ locations. The Images model had 
                           the lowest accuracy, however future work will focus on examining the predictive power of images within tweets.")
             )),
             br(),br(),
             # diagram
             sidebarLayout(
                 sidebarPanel("Diagram"),
                 mainPanel(
                     img(src = "diagram.png")
                 )
             )),
    
    # Data
    tabPanel("Data",
             fluidPage(
                 # text to introduce the data page
                 wellPanel(
                     "The table below shows the dataset we use for our project, we retrieve these data using ",
                     a(
                         href = "https://www.tweepy.org",
                         "Tweepy."
                     ),
                     p("Click the download button below to download the data to your machine.")
                 ),
                 # download button
                 downloadButton(
                     "download_TeamPython",
                     "Download data"
                 ),
                 hr(),
                 # data table
                 withLoader(DTOutput("countries_table"))
             )
             ),
    
    tabPanel("Tweets",
             fluidPage(
                 wellPanel(
                     "Interactive Shiny web application to search, sort, 
                     and track tweets with a specific hashtag.",
                     p("Click the download button below to download the data to your machine.")
                 ),
                 titlePanel("Search tweets"),
                 sidebarLayout(
                     sidebarPanel(
                         numericInput("num_tweets_to_download",
                                      "Number of tweets to download:",
                                      min = 100,
                                      max = 18000,
                                      value = 200,
                                      step = 100),
                         textInput("hashtag_to_search",
                                   "Hashtag to search:",
                                   value = "#rstudioconf"),
                         dateRangeInput("date_picker", label = "Select dates:", start = "2020-11-05", end = "2020-11-15"),
                         actionButton("get_data", "Get data", class = "btn-primary"),
                         br(),br(),
                         downloadButton("download_data", "Download data")
                     ),
                     
                     mainPanel(
                         withLoader(reactableOutput("tweet_table"))
                     )
                 )
             )
             ),
    tabPanel("Account Inforamtion",
             fluidPage(
                 wellPanel(
                     " All of the five account information are numeric. I create boxplot to present their distribution. If you want to use column names as inputs,
                     you need to use get(input$ColumnName) funciton.
                     "
                 ),
                 selectInput("Select_Account",
                             label = "Select an account information",
                             choices = c("favourites_count", "followers_count", "statuses_count",
                                         "friends_count", "listed_count")
                             )
             ),
             withLoader(plotOutput("account_boxplot"))),
    
    # image recognition
    tabPanel("Images",
             fluidPage(
                 wellPanel("Keras is a popular framework which is build on top of Tensorflow.
                           I build a Shiny application to recognize objects in an image"),
                 fluidRow(
                     column(width=4, fileInput('file', '',accept = c('.jpg','.jpeg'))),
                     column(width=4, tags$label(HTML("&zwnj;")), tags$br(), tags$em(
                         "Please use the browse button to upload an image (JPG/JPEG format)")),
                     column(width = 4, tags$label(HTML("&zwnj;")), tags$br(), tags$em(
                         "Predicted Classes & Scores")))
                 ),
                 tags$hr(),
                 fluidRow(
                     column(width=4, withLoader(imageOutput('outputImage'))),
                     column(width=4, withLoader(plotOutput("plot"))),
                     column(width=4, withLoader(dataTableOutput("table")))
                 )
             ),

    tabPanel("Combined Model",
             fluidPage(
                 wellPanel("This is the final results of our combined model.")
             ),
             titlePanel("Final Results"),
             navlistPanel(
                 "Preliminary Results",
                 tabPanel("Combined Model",
                          fluidPage(
                              wellPanel("Accuray on test data: 57%",
                                        p("Loss: 1.72")),
                              img(src = "preliminary combined.png"),
                              img(src = "pre combine report.png")
                          )),
                 tabPanel("Account Information Model",
                          fluidPage(
                              wellPanel("Accuray on test data: 27%",
                                        p("Loss: 2.2603")),
                              img(src = "pre account.png"),
                              img(src = "pr account report.png")
                          )),
                 tabPanel("Images (Profile and Banner) Model",
                          fluidPage(
                              wellPanel("Accuray on test data: 9%",
                                        p("Loss: 2.4429")),
                              img(src = "pre img.png"),
                              img(src = "pre img report.png")
                          )),
                 tabPanel("Images and Tweets  Model",
                          fluidPage(
                              wellPanel("Accuray on test data: 59%",
                                        p("Loss: 1.95")),
                              img(src = "pre text.png"),
                              img(src = "pre text report.png")
                          )),
                 "Tuned Results",
                 tabPanel("Combined Model",
                          fluidPage(
                              wellPanel("Accuray on test data: 64%",
                                        p("Loss: 1.91")),
                              img(src = "tuned combine.png"),
                              img(src = "tuned combine report.png"),
                              wellPanel(p("Best Parameters for 1st Dense layer is 190"),
                                        p("Best Parameters for 2nd Dense layer is 150"),
                                        p("Best Parameters for 3rd Dense layer is 80"),
                                        p("Best Parameters for Dropout layer is 0.40"),
                                        p("Best learning rate for the ADAM is 0.000246"))
                          )),
                 tabPanel("Account Information Model",
                          fluidPage(
                              wellPanel("Accuray on test data: 29%",
                                        p("Loss: 2.2507")),
                              img(src = "tuned account.png"),
                              img(src = "tuned account report.png"),
                              wellPanel(p("Best Parameters for 1st Dense layer is 70"),
                                        p("Best Parameters for 2nd Dense layer is 200"),
                                        p("Best Parameters for 3rd Dense layer is 100"),
                                        p("Best Parameters for Dropout layer is 0.10"),
                                        p("Best learning rate for the ADAM is 0.000684"))
                          )),
                 tabPanel("Images (Profile and Banner) Model",
                          fluidPage(
                              wellPanel("Accuray on test data: 17%",
                                        p("Loss: 2.37")),
                              img(src = "tuned img.png"),
                              img(src = "tuned img report.png"),
                              wellPanel(p("Best Parameters for 1st Dense layer is 90"),
                                        p("Best Parameters for 2nd Dense layer is 100"),
                                        p("Best Parameters for 3rd Dense layer is 100"),
                                        p("Best Parameters for Dropout layer is 0.20"),
                                        p("Best learning rate for the ADAM is 0.000202"))
                          )),
                 tabPanel("Images and Tweets  Model",
                          fluidPage(
                              wellPanel("Accuray on test data: 65%",
                                        p("Loss: 1.91")),
                              img(src = "tuned text.png"),
                              img(src = "tuned text report.png"),
                              wellPanel(p("Best Parameters for 1st Dense layer is 50") ,
                                        p("Best Parameters for 2nd Dense layer is 150"),
                                        p("Best Parameters for 3rd Dense layer is 100"),
                                        p("Best Parameters for Dropout layer is 0.0"),
                                        p("Best learning rate for the ADAM is 0.0001277"))
                          ))
             ))

    # Sidebar with a slider input for number of bins
    # sidebarLayout(
    #     sidebarPanel(
    #         sliderInput("bins",
    #                     "Number of bins:",
    #                     min = 1,
    #                     max = 50,
    #                     value = 30)
    #     ),
    # 
    #     # Show a plot of the generated distribution
    #     mainPanel(
    #         plotOutput("distPlot")
    #     )
    # )
)

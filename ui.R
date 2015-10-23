##Load necessary packages
library(shiny)
library(markdown)

shinyUI(fluidPage(
  titlePanel("Let's find your new favorite foods!"),
  sidebarLayout(
    sidebarPanel(
      h3("Your preferences:"),
      p("So let's get started! On a scale of 1 to 5, how would you rate the following cuisines that you may 
        be familiar with? Click 'I'm ready!' when you are finished."),
      ##Use selectInput to provide dropdown menus
      selectInput("chinese","Chinese",c(1,2,3,4,5)),
      selectInput("mexican","Mexican",c(1,2,3,4,5)),
      selectInput("italian","Italian",c(1,2,3,4,5)),
      selectInput("japanese","Japanese",c(1,2,3,4,5)),
      selectInput("greek","Greek",c(1,2,3,4,5)),
      selectInput("french","French",c(1,2,3,4,5)),
      selectInput("thai","Thai",c(1,2,3,4,5)),
      selectInput("spanish","Spanish",c(1,2,3,4,5)),
      selectInput("indian","Indian",c(1,2,3,4,5)),
      selectInput("american","American",c(1,2,3,4,5)),
      actionButton("goButton","I'm ready!")
    ),
    mainPanel(
      ##Use tabs to present different plots
      tabsetPanel(
        tabPanel("Description",
                 includeMarkdown("description.md")),
        ##First plot displays the user's input
        tabPanel("Your ratings",
                 p("Here is how you rated various global cuisines."),
                 plotOutput('yourPrefs')),
        ##Second plot displays the average ratings on the same categories from all other survey takers
        tabPanel("All user ratings",
                 p("Here are the average preferences of all other eaters in our dataset."),
                 plotOutput('globalPrefs')),
        ##Third plot shows the ratings on other cuisines from the 25 eaters 'most similar'  
        ##in taste preferences to the user.
        tabPanel("Our suggestions!",
                 p("This plot shows you the average ratings for cuisines that we didn't ask you about,
                   taken from the 25 eaters in our database whose preferences were most similar to yours.
                   If you haven't ever tried a cuisine that these eaters rate highly, give it a shot!"),
                 plotOutput('otherEaters'))
      )
    )
  )
))
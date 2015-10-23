##Load required libraries and food ratings data
library(shiny)
library(plyr)
library(dplyr)
library(reshape2)
library(ggplot2)
food<-read.csv("foodRatingsClean.csv")

shinyServer(
  function(input,output){
    ##Output will consist of three plots in this order: 
    ##user preferences, all user preferences, suggestions from similar eaters
    output$yourPrefs<-renderPlot({
      ##Only process user data when go button is pressed
      input$goButton
      yourRatings<-isolate({
                      ##Convert user inputs to numeric vector
                      as.numeric(c(input$chinese,input$mexican,input$italian,input$japanese,input$greek,
                                   input$french,input$thai,input$spanish,input$indian,input$american))
                   })
      cuisines<-c("Chinese","Mexican","Italian","Japanese","Greek","French","Thai","Spanish",
                  "Indian","American")
      ##Build table of user preferences that is ggplot compatible
      yourRatingsTable<-cbind(as.data.frame(yourRatings),as.data.frame(cuisines))
      colnames(yourRatingsTable)<-c("Rating","Cuisine")
      yourRatingsTable$Cuisine<-factor(as.character(yourRatingsTable$Cuisine))
      ##Create bar plot showing user ratings on various cuisines
      ggplot(yourRatingsTable,aes(x=factor(Cuisine),y=Rating))+
        stat_summary(fun.y=mean,geom="bar")+
        ylab("Rating")+
        ylim(0,5)+
        xlab("Cuisine")+
        ggtitle("Your Ratings")+
        theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.25),
              plot.title=element_text(lineheight=.8,face="bold"))
    })
    output$globalPrefs<-renderPlot({
      ##Select ratings from all other users on the same foods we asked about
      otherRatings<-select(food,c(China,Mexico,Italy,Japan,Greece,France,Thailand,Spain,India,United.States))
      ##Format those ratings in such a way that we can use ggplot to mirror the plot of the current 
      ##user's ratings (see code in previous section)
      otherRatings<-melt(otherRatings)
      colnames(otherRatings)<-c("Cuisine","Rating")
      otherRatings<-na.omit(otherRatings)
      otherRatings$Rating<-as.numeric(otherRatings$Rating)
      otherRatings$Cuisine<-revalue(otherRatings$Cuisine,c("China"="Chinese","Mexico"="Mexican",
                                                           "Italy"="Italian","Japan"="Japanese",
                                                           "Greece"="Greek","France"="French",
                                                           "Thailand"="Thai","Spain"="Spanish",
                                                           "India"="Indian","United.States"="American"))
      otherRatings$Cuisine<-factor(as.character(otherRatings$Cuisine))
      ##Produce bar plot showing the average ratings of all users on the types of cuisine that we asked about
      ggplot(otherRatings,aes(x=factor(Cuisine),y=Rating))+
        stat_summary(fun.y=mean,geom="bar")+
        ylab("Rating")+
        ylim(0,5)+
        xlab("Cuisine")+
        ggtitle("Average Ratings for All People Surveyed")+
        theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.25),
              plot.title=element_text(lineheight=.8,face="bold"))
    })
    output$otherEaters<-renderPlot({
      ##Once again, require go button to generate the user ratings that will drive these suggestions
      input$goButton
      yourRatings<-isolate({ 
                      as.numeric(c(input$chinese,input$mexican,input$italian,input$japanese,input$greek,
                                   input$french,input$thai,input$spanish,input$indian,input$american)) 
                    })
      ##Subset only those users who have rated all of the same foods
      completeOthers<-food[complete.cases(food[,c("China","Mexico","Italy","Japan","Greece","France",
                                                  "Thailand","Spain","India","United.States")]),]
      ##Extract those users' ratings
      completeOthersRatings<-select(completeOthers,c(China,Mexico,Italy,Japan,Greece,France,Thailand,
                                                     Spain,India,United.States))
      ##Calculate the Euclidean distances between the current user and all other users in the database
      distances<-NULL
      for (i in 1:dim(completeOthersRatings)[1]){
        obs<-completeOthersRatings[i,]
        mat<-rbind(obs,yourRatings)
        distance<-dist(mat,method="euclidean")
        distances<-c(distances,distance)
      }
      ##Find and extract the data on the 25 'most similar' users in the database
      indices<-order(distances)[1:25]
      ids<-completeOthers[indices,]$ID
      userSubset<-food[(food$ID %in% ids),]
      ##Pull out those users' ratings on all of the foods that we did NOT ask about
      subsetRatings<-select(userSubset,-c(China,Mexico,Italy,Japan,Greece,France,Thailand,Spain,India,
                                          United.States))
      subsetRatings<-select(subsetRatings,-c(1,2,33:38))
      ##Reformat data to make ggplot happy
      subsetRatings<-melt(subsetRatings)
      colnames(subsetRatings)<-c("Cuisine","Rating")
      subsetRatings$Cuisine<-factor(as.character(subsetRatings$Cuisine))
      subsetRatings$Rating<-as.numeric(subsetRatings$Rating)
      ##Plot those users' average ratings on all of the foods we did not ask about
      ggplot(subsetRatings,aes(x=factor(Cuisine),y=Rating))+
        stat_summary(fun.y=mean,geom="bar")+
        ylab("Rating")+
        ylim(0,5)+
        xlab("Cuisine")+
        ggtitle("25 Most Similar Eaters' Ratings of Other Cuisines")+
        theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.25),
              plot.title=element_text(lineheight=.8,face="bold"))
    })
  }
)
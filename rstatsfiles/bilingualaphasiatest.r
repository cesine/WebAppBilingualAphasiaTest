#create labels for plots
articulationlabel <- "Articulation rate (syl/phonation)"
labparticipantslabel <- "Lab Participants"
nusablep/articipants <- "(n=17)"
nallparticipants <- "(n=17)"

#read in data
bat <- read.table("/Users/gina/Documents/aphasiaacademyannualmeeting/bat_results/gold/batresultsboxplotformat.csv", header=TRUE, sep="," )

# scatterplot for linear regression with fit line





# histogram for all lab participant aritculation rate
pdf("/Users/gina/Documents/aphasiaacademyannualmeeting/bat_results/gold/histogramalllab.pdf",width=6,height=6,paper='special')
x <- bat$articulrate
title <-paste(labparticipantslabel,nallparticipants, sep = " ", collapse = NULL)
h<-hist(x, breaks=10, col="red", xlab=articulationlabel, yaxt="n",
  	 main=title) 
xfit<-seq(min(x),max(x),length=40) 
yfit<-dnorm(xfit,mean=mean(x),sd=sd(x)) 
yfit <- yfit*diff(h$mids[1:2])*length(x) 
lines(xfit, yfit, col="blue", lwd=2)
dev.off()

#Box plot comparing articulation rate in the two blog subexperiments
# http://www.statmethods.net/graphs/boxplot.html
pdf("/Users/gina/Documents/aphasiaacademyannualmeeting/bat_results/gold/boxplotalllab.pdf",width=6,height=6,paper='special')
title <-paste(labparticipantslabel,nusableparticipants,"", sep = " ", collapse = NULL)
boxplot(articulrate~subexperiment,data=bat, notch=TRUE, col=(c("red","darkgreen")), main=title,  xlab="Spontaneous Speech, Description of Cartoon", ylab=articulationlabel)
dev.off()

#boxplot(phonationtime~subexperiment,data=bat, main=title,  xlab="Blog Draft", ylab=articulationlabel)
#boxplot(nsyll~subexperiment,data=bat, main=title,  xlab="Blog Draft", ylab=articulationlabel)
#boxplot(speechrate~subexperiment,data=bat, main=title,  xlab="Blog Draft", ylab=articulationlabel)


#Compaire groups via kernal density
library(sm)
pdf("/Users/gina/Documents/aphasiaacademyannualmeeting/bat_results/gold/densityalllab.pdf",width=6,height=6,paper='special')
title <-paste(labparticipantslabel,"density distribution",nusableparticipants, sep = " ", collapse = NULL)
sm.density.compare(bat$articulrate, bat$subexperiment, xlab=articulationlabel) 
title(main=title)
# add legend via mouse click
subexperiments.f <- factor(bat$subexperiment, levels= c(1,2), labels = c("Sponaneous Speech","Description of Cartoon"))
colfill<-c(2:(2+length(levels(subexperiment.f))))
#legend(locator(1), levels(subexperiments.f), fill=colfill)
legend("topright", levels(subexperiments.f), fill=colfill)

dev.off()



#skeptoid histogram
skeptoid <- read.table("/Users/gina/Documents/bat/results/praatresultsskeptoid.csv", header=TRUE, sep="," )
pdf("/Users/gina/Documents/bat/results/histogrambloggingpodcasters.pdf",width=6,height=6,paper='special')
x <- skeptoid$articulrate
title <-paste(bloggingpodcasterslabel,"(n=47)", sep = " ", collapse = NULL)
h<-hist(x, breaks=10, col="red", xlab=articulationlabel, yaxt="n",
     main=title)
xfit<-seq(min(x),max(x),length=40)
yfit<-dnorm(xfit,mean=mean(x),sd=sd(x))
yfit <- yfit*diff(h$mids[1:2])*length(x)
lines(xfit, yfit, col="blue", lwd=2)
dev.off()


batttest <- read.table("/Users/gina/Documents/aphasiaacademyannualmeeting/bat_results/gold/batresultstestformat.csv", header=TRUE, sep="," )

#scatterplot with fit lines for linear regression
pdf("/Users/gina/Documents/aphasiaacademyannualmeeting/bat_results/gold/scatterplotalllab.pdf",width=6,height=6,paper='special')
title <-paste(labparticipantslabel,nusableparticipants,"", sep = " ", collapse = NULL)
plot( batttest$SpontaneousSpeech,batttest$DescribeCartoon, main=title,  xlab="Spontaneous Speech", ylab="Description of Cartoon")
# Add fit lines
abline(lm(batttest$DescribeCartoon~batttest$SpontaneousSpeech), col="red") # regression line (y~x) 
#lines(lowess(batttest$SpontaneousSpeech,batttest$DescribeCartoon), col="blue") # lowess line (x,y)
dev.off()

plot(batttest$SpontaneousSpeech,batttest$DescribeCartoon, main="Scatterplot")


#Paired t-test insignificant (too small sample size and too much variance): test Hypothesis1 that subexperiment1 has slower articulation rate than subexperiment2


t.test(batttest$subexperiment1,batttest$subexperiment2,paired=TRUE, alt="less")


	Paired t-test

data:  batttest$subexperiment1 and batttest$subexperiment2 
t = -0.6826, df = 4, p-value = 0.2662
alternative hypothesis: true difference in means is less than 0 
95 percent confidence interval:
      -Inf 0.3057439 
sample estimates:
mean of the differences 
                 -0.144 



#Compare all participant data to skeptoid

 t.test(batall$articulrate,skeptoid$articulrate)

	Welch Two Sample t-test

data:  articulationrate and skeptoid$articulrate 
t = -6.0765, df = 21.333, p-value = 4.649e-06
alternative hypothesis: true difference in means is not equal to 0 
95 percent confidence interval:
 -1.2350082 -0.6056605 
sample estimates:
mean of x mean of y 
 4.002857  4.923191 

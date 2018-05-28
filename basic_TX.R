#Read Single TX Tick file

# http://www.taifex.com.tw/chinese/3/3_1_3.asp

# setwd("C:/Users/mnwu/Desktop/taifex")
setwd("D:/")

#install.packages("readr")
#install.packages("quantmod")
library(readr)
library(quantmod)

TX <- read_csv('Daily_2017_08_03.csv', col_names = FALSE, skip = 1)
#View(TX)

# dir()[1:length(dir())] %>% read_csv()

colnames(TX) = c("Date","Symbol","Delivery","Time","Price","Volume","","","")

typeof(TX)

TX = TX[, c(-7,-8,-9)] 
head(TX)

Row = which(TX$Symbol == "TX") 
length(Row)

TXData = TX[Row, ]
#View(TXData)

TXHotData = TXData[TXData$Delivery == "201708", ]
# TXHotData <- TXData %>% filter(Delivery == min(Delivery))
timeCharVector = paste(TXHotData$Date, TXHotData$Time)

timeVector = strptime(timeCharVector, "%Y%m%d %H%M%S", tz = Sys.timezone() ) #%y for 2 digits of year %Y for 4 digits of year!!!
#View(TXHotData)

TSdata <- xts(TXHotData[, c(5:6)], as.POSIXct(timeVector))
#View(TSdata)
chartSeries(TSdata)


duration = "2017-08-03 08:45:10::2017-08-03 08:47:30"
chartSeries(TSdata[duration])

duration = "2017-08-03 08:45:25::2017-08-03 08:45:31"
chartSeries(TSdata[duration])
#View(TSdata[duration])

TX_1s = to.period(TSdata, "seconds", 1)
chartSeries(TX_1s[duration])

TX_10s = to.period(TSdata, "seconds", 10)
chartSeries(TX_10s)
View(TX_10s)

TSdata$Volume = TSdata$Volume / 2
duration = "2017-08-03 08:55:25::2017-08-03 12:15:00"
TX_5min = to.period(TSdata, "minutes", 5)
chartSeries(TX_5min[duration])
colnames(TX_5min) = c("Open", "High", "Low", "Close", "Volume")
View(TX_5min)

#################

duration = "2017-08-03 08:55:25::2017-08-03 13:43:00"
chartSeries(TX_5min[duration], theme = "white", type = "candle", up.col = "red", dn.col = "green")
zoomChart("2017-08-03 10:50:59::")

zoomChart("2017-08-03 09:00:59::")
addSMA(5)
addSMA(20, col = "blue")
addMACD()
addBBands()

head(TX_5min)
head(Op(TX_5min))
head(Hi(TX_5min))
head(Lo(TX_5min))
head(Cl(TX_5min))
head(Vo(STK))

#####

duration = "2017-08-03 08:50:00::2017-08-03 13:43:00"
TXmin = to.period(TSdata, "minutes", 1)[duration]

#View(TXmin)
chartSeries(TXmin)
addSMA(5)
row = Cl(TXmin) > SMA(Cl(TXmin),5)
View(cbind(Cl(TXmin), SMA(Cl(TXmin), 5), row))
PL = setNames(rep(0, length(Cl(TXmin))), time(TXmin))

m = 6
while ( m < nrow(TXmin)) {
  if (row[m - 1] == 0 && row[m] == 1){
    long = as.numeric(Op(TXmin)[m + 1])
    while( row[m] == 1 && m < nrow(TXmin)) {m = m + 1}
    PL[m] = as.numeric(Op(TXmin)[m + 1]) - long
  }
  m = m + 1  
}

plot(cumsum(PL), type = "l", col = "red", lwd = 2)


###############

length(PL[PL > 0]) / length(PL[PL != 0])
mean(PL[PL > 0]) / abs(mean(PL[PL < 0]))
sum(PL[PL >= 0]) / abs(sum(PL[PL < 0]))

############

DD = rep(0, length(PL))
topPL = rep(PL[1], length(PL))

for (m in 2:length(PL)){ 
  if (sum(PL[1:m]) > topPL[m - 1]){
    ##�ثe�֭p��Q > �L�h�̰���Q i.e.�зs��
    topPL[m:length(PL)] = sum(PL[1:m]) 
    ## ��s�зs�����Ȩ� topprofit
  }
}

DD = cumsum(PL) - topPL 

ts.plot(cbind(cumsum(PL), DD), col = c("red", "blue"), type = "h")##�e��

for (m in 2:length(PL)) {
  if (topPL[m] > topPL[m-1]) {
    points(m, topPL[m], pch = 4, col = "purple")
  } ##����Q�зs���A���ӵ���XX
}

abline(h = 0, col = "green")


plot(cumsum(PL), type = "l", col = "red", lwd = 3, ylim = range(cumsum(PL), DD))
par(new = T)
plot(DD, type = "l", lwd = 3, ylim = range(cumsum(PL), DD))

points(which(DD == 0), topPL[which(DD == 0)], pch = 4, col = "purple")
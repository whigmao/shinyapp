library(wordcloud)
library(DT)
library(keras)

model <- application_resnet50(weights = 'imagenet')
TOP_CLASSES            <- 10
RESNET_50_IMAGE_FORMAT <- c(224, 224)
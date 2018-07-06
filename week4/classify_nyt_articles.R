library(tidyverse)
library(tm)
library(Matrix)
library(glmnet)
library(ROCR)
library(caret)
library(broom)

########################################
# LOAD AND PARSE ARTICLES
########################################

# read in the business and world articles from files
# combine them both into one data frame called articles
business <- read_tsv('business.tsv', quote="\'")
world <- read_tsv('world.tsv', quote="\'")
articles <- rbind(business, world)

# create a corpus from the article snippets
# using the Corpus and VectorSource functions
corpus <- Corpus(VectorSource(articles$snippet))

# create a DocumentTermMatrix from the snippet Corpus
# remove stopwords, punctuation, and numbers
dtm <- DocumentTermMatrix(corpus, list(weighting=weightBin,
                                       stopwords=T,
                                       removePunctuation=T,
                                       removeNumbers=T))

# convert the DocumentTermMatrix to a sparseMatrix
X <- sparseMatrix(i=dtm$i, j=dtm$j, x=dtm$v, dims=c(dtm$nrow, dtm$ncol), dimnames=dtm$dimnames)

# set a seed for the random number generator so we all agree
set.seed(42)

########################################
# YOUR SOLUTION BELOW
########################################

# create a train / test split


train_idx <- sample(1:nrow(X), size = nrow(X) * 0.8)
train <- X[train_idx, ]
train_labels <- articles$section_name[train_idx]
test <- X[-train_idx, ]
test_labels <- articles$section_name[-train_idx]

# cross-validate logistic regression with cv.glmnet (family="binomial"), measuring auc
cvmfit = cv.glmnet(x = train, y = train_labels, family = "binomial", type.measure = "class")

# plot the cross-validation curve
plot(cvmfit)

# evaluate performance for the best-fit model
# note: it's useful to explicitly cast glmnet's predictions
# use as.numeric for probabilities and as.character for labels for this 
# test_results <- data.frame(test_labels)
# test_results <- rename(test_results = test_labels)
# test_results <- as.numeric(predict(cvmfit, newx = test, type = "response"))
# test_results$predictions <- as.factor(predict(cvmfit, newx = test, type = "class"))

pred_prob_cvmfit = as.numeric(predict(cvmfit, test, type = "response"))
pred_labels_cvmfit = as.character(predict(cvmfit, test, type = "class"))

# compute accuracy
mean(pred_labels_cvmfit == test_labels)
# mean(test_results$labels == test_results$predictions)

# look at the confusion matrix
confusionMatrix(as.factor(pred_labels_cvmfit), as.factor(test_labels))

# plot an ROC curve and calculate the AUC
# (see last week's notebook for this)
pred <- prediction(pred_prob_cvmfit, test_labels)
perf <- performance(pred, measure = 'tpr', x.measure = 'fpr')
plot(perf)

auc <- performance(pred, measure = "auc")

# show weights on words with top 10 weights for business
# use the coef() function to get the coefficients
# and tidy() to convert them into a tidy data frame
weights <- tidy(coef(cvmfit)) %>% filter(row != "(Intercept)")

# positive - business
top_10_world <- weights %>% arrange(desc(value)) %>% head(10)

# show weights on words with top 10 weights for world
top_10_business <- weights %>% arrange(value) %>% head(10)

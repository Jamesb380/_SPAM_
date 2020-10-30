# _SPAM_
Filter for Spam e-mail

## Problem Description

In the age of digital information, spam email has become an efficient and economically viable tool for commercial advertising. It is said that traditional direct mailers experienced a half to two percent return. For example, In a campaign of a 100 pieces of mail it is said that no more than 2 people will respond and only half of those respondents will purchase a product. Consequently, the need for merchants to reach prospective customer is proportional to the ability to earn revenue. Unlike traditional mailer which can be easily discard with no further consequence to bare, Spam emails may carry malware and other executable files that can be used for identity theft and scams which could lead to long term difficulties for consumers. On the other hand, non-delivery of electronic mail can also carry devastating consequences. The general public has come to rely on electronic communication as the primary method of communication across all facets of their everyday lives. According to a 2012 article in the Huffington Post, Americans spend 20 Billion dollars per year in mitigation, suppression and elimination of spam emails. We observe in a bar plot of our data that a significant amount of e-mail communications (nearly 40%) is Spam. The product of Spam is counter to the benefits of electronic communication. In essence, we can say that 40% of e-mail communication cost 20 Billion dollars.

![](Images/hamvspam.png)
                                
Figure 1 – Nearly 40% of all email communication is spam.

Through careful analysis, We will develop a predictive model to help us understand the data patterns to effeciently dectect Spam emails.
## Goal
   To develop a predictive model that more accurately identify Spam emails.
  
   To reduce the number of false positives (ham emails identified as spam)
## Metrics
  1. The percentage of spam e-mails identified with our model.
  2. The percentage of false positives and True negatives.
## Hypothesis
  1. Each outlying variables (greater than a 20% uniqueness factor) in component one is not a significant factor in identifying and filtering spam.
  2. Each outlying variables (greater than a 20% uniqueness factor) in component two is not a significant factor in identifying and filter spam.
## Data Aproach 

The data was obtain from the Hewlett-Packard Labs. The data is experimental. The data is comprised of a collection of statistical information from a collection of e-mail. The reasoning for the selection of factors (words, characters and frequency partners) for identifying spam emails was not disclosed in the briefing, however, this should not impact the result of our analysis. There was no additional manipulation of the data needed to begin our analysis. Appendix A provides a detailed description of the variables in the data file. The first 54 variables indicate whether a particular word or character was frequently occurring in the e-mail. These are expressed percentages of the total amount of characters or words in the e-mails. The next 3 variables measure the presence of continuous capital letters. Finally, the last variable (V58) is binary and categorical since e-mails can either be HAM or SPAM. All of the variables except for the response (V58) are qualitative.

The principle analysis bi-plot provides a view of all of the emails, with respect to Ham and Spam, across a plane of 57 components. We see that ham emails (represented by the blue dots) spread along component one and the spam emails (represented by the red dots) spread along component two. If we imagine a multiple dimensional plane, the red and blue dots represent the most prevalent points at these components. In other words, the points extend beyond the plane at component two and one respectively, but remain interconnected with other components.

![](Images/biplot_no_log_Trans) ![](Images/biplot_with_log_Trans)

The cumulative variance plot describes the cumulative different in variance between components. For Instance, the graph shows the first two component account for about 20% of the variance. Similarly, the first ten components represent 40% of the variance.
PCA

![](Images/cummulative_sum.png) ![](Images/porpotion_variance.png)

The bar plots shows the outlying variables with a greater than 0.2 uniqueness factor for the first two components.

![](Images/barplotloadings.png) ![](Images.loadings2.png)

In a scatter matrix plots of the variables against the response of data is shown below, we observe that distribution of the data is not Gaussian when measured again the response variable. No significant change is noted when the log transform is applied to the response variable.

![](Images/scatterlog1_8v58.png) ![](Images/scatterlog47_57v58.png)
                             (we see collinearity here)


#if script does not run ensure your working directory is in the
#path where the excel file is stored, check current working directory
#by gewd(), set working directory by 
#setwd("C:/Users/path_of_the_excel_file"Table_for_script�.xlsx")
#

library(readxl)
library(dplyr)
library(dmetar)
#creating a variable that contains all studies
Level_of_evidence_2 <- read_excel("Table_for_script�.xlsx")

View(Level_of_evidence_2)
#creating a variable that only contains studies that are pooled for overall risk_factor comparison (Migration, childhood trauma, discrimination)
Level_of_evidence_2_resul_risk <- dplyr::filter(Level_of_evidence_2, 
                                                overall_risk_factor %in% 
                                                  c("Migration","Vulnerability for ethnic discrimination",
                                                    "Childhood Adversity"))

#loading package meta
library(meta)
#pooling overall risk factors 

resul_risk.m <- metagen(median = valueD, lower= lowerD, upper=upperD, studlab=Study, data=Level_of_evidence_2_resul_risk, byvar=overall_risk_factor, overall = F, sm="SMD")


#sorting overall risk factors by subgroups
#subresul.m <- update.meta(resul_risk.m, 
 #                          byvar=overall_risk_factor, 
  #                         comb.random = TRUE, 
   #                        comb.fixed = FALSE)

#create Forest plot for for overall_risk_factors
# Migration, childhood trauma, discrimination
pdf("Fig_forest_subgroupresul.pdf", width=12, height=12) 

meta::forest(resul_risk.m,  xlab = "Cohen's d", 
             smlab ="", 
             overall = FALSE, print.Q = TRUE,
             comb.random = TRUE,
             comb.fixed = FALSE,
             rightlabs = c("d","95% CI"),
             leftcols=c("studlab"), overall.hetstat = FALSE)

# Close the pdf file
dev.off() 

#pooling all risk factors 
pooled_risk.m<-Level_of_evidence_2 %>% filter(!is.na("pooled")) %>% 
  metagen(median = valueD, lower= lowerD, upper=upperD, studlab=Study, data=., byvar=Factor, overall = F, sm="SMD")


#create Forest plot for all pooled risk factors
pdf("Fig_forest_subgrouppooled.pdf", width=12, height=22) 

meta::forest(pooled_risk.m, xlab = "Cohen's d", 
             smlab ="", 
             overall = FALSE, print.Q = TRUE,
             comb.random = TRUE,
             comb.fixed = FALSE,
             rightlabs = c("d","95% CI"),
             leftcols=c("studlab"), overall.hetstat = FALSE)

# Close the pdf file
dev.off() 


#conducting eggers test for all pooled risk factors
pooled_risk.et<-Level_of_evidence_2 %>% filter(!is.na("pooled")) %>% 
  metagen(median = valueD, lower= lowerD, upper=upperD, studlab=Study, data=., overall = F, sm="SMD")
etpooled=eggers.test(pooled_risk.et)


# create txt.file with results of meta analysis for  all risk_factors (all subgroups)
sink("resultsoverall.txt")
print(resul_risk.m)
sink()

# create txt.file with results of meta analysis for overall_risk_factors
# Migration, childhood trauma, discrimination
sink("resultspooled.txt")
print(pooled_risk.m)
sink()


#create pdf for Funnel Plot of all pooled effect sizes
pdf("Fig1_funnel_pooled.pdf", width=12, height=12) 
funnel(pooled_risk.m,xlab = "Cohen's d", ylab = "Standard error")
  
# Close the pdf file
dev.off()  

#create text file with result of eggers test for all risk factors
sink("eggers test_poooled.txt")
print(etpooled)
sink()



####END

# # The function (eggers.test(x = pooled_variable)) returns 
# #the intercept along with its 
# #confidence interval. We can see that the p-value of 
# #Egger's test is significant  
# # (p<0.05), which means that there is substanital 
# #asymmetry in the Funnel plot. This asymmetry could
# #have been caused by publication bias.
# 

# 

library(pwr)
# aim 1 -------------------------------------------------------------------
#Hypothesis: clinicians with accurate and real-time diagnostic and reporting tools increase reporting compared to control. 

#219 acute febrile patients will be enrolled for a single study visit over an enrollment period of two years from two clinics (total n = 438). This sample size calculation (Cohens D) is based on 6% of dengue cases currently reported under traditional surveillance system,29,30 a 10% expected increase in reporting in FeverDX clinic vs control clinics with 80% power, and 95% confidence. 
pwr.t.test(n = NULL, d = 0.2, sig.level = 0.05, power = .8, type = c("paired"), alternative = c("two.sided"))
pwr.t.test(n = NULL, d = 0.4, sig.level = 0.05, power = .8, type = c("paired"), alternative = c("two.sided"))

# aim 2 -------------------------------------------------------------------
#Neighborhood violence (measured as homicides) decreases proportion of acute febrile and arboviral cases captured in traditional surveillance systems. 

#To estimate minimum expected effect (log odds of 4) of violence on care seeking rates, we will survey 480 
#households (~1440 persons based on three persons per household 76) in each of three neighborhoods per catchment 
#area of two clinics. 
#This sample size is based on a conservative estimate of four times decreased odds of accessing healthcare92 with one level increase in violence, 26% of households reporting febrile illness in the past two weeks77 (between cluster variation = 5%), and 50% of febrile illness seeking care from a health facility or provider for febrile illness77 and 24% incidence of dengue among febrile patients.78 

30*2*4*2

#Vector sampling: Based on data previously collected from Cali, Colombia (Ocampo et al. unpublished), 
#over a three-month sampling period, on average, 70% of ovitraps were positive for at least one Aedes spp. 
#(range = 40-80%) per month. To detect at least a 10% difference in monthly pupal positivity by ANOVA, our 
#sample will contain 43 ovitraps per neighborhood per month assuming 9 neighborhoods with 95% confidence and 
#80% power. 

pwr.anova.test(k=2,f=.3,sig.level=.05,power=.8)
44*2*24
# aim 3 -------------------------------------------------------------------

#arboviral outbreaks two or more standard deviations above average are predictable two weeks pre-outbreak at the neighborhood level with high sensitivity and specificity. 
#Sample size in the two catchment areas: Daily SIVIGLA febrile case data will be adjusted using hybrid surveillance methods49 to generate the case dataset (N = 26,985 suspected arboviral cases and 56.5% of suspected arboviral cases confirmed by laboratory diagnostics based on case data reported to SIVGILA in Cali 2014-20163). Climate and violence data will be collected daily for two years. Vector data will be collected monthly for 24 months. Expected effect size: Climate is expected to be strongly correlated with dengue cases111-cumulative precipitation correlated with dengue cases (correlation coefficient = 0.5, p-value<0.001) and minimum temperature (correlation coefficient = 0.6, p-value<0.001).112 Accuracy and precision Accounting for seasonality, time lags, community violence, and vector campaigns, an increase in accuracy and spatial and temporal precision is expected compared to previous studies using a lag of 1-12 weeks113 (defined during optimization), 80% sensitivity24 and 90% specificity,24 37 days pre-outbreak24 at a spatial scale of 0.4 km2.24 


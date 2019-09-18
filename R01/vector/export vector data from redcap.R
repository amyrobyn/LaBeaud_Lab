rm(list=ls()) #remove previous variable assignments

# devtools::install_github("nutterb/redcapAPI") # install API from here instead of inside R
# install VPN network if not set up: https://uit.stanford.edu/service/vpn
# connect to VPN network before starting this code

# install libraries
library(redcapAPI)
library(REDCapR)
library(RCurl)
library(plyr)

# make connection to REDCap
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/vector") # get redcap token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
clim.vec.token <- readLines("api.key.txt") # Read API token from folder

# import all data frome redcap
vectorData <- redcap_read(redcap_uri  = REDcap.URL, token = clim.vec.token, batch_size = 300)$data
rcon <- redcapConnection(url=REDcap.URL, token=clim.vec.token)


# export reports from REDCap
house <- exportReports(rcon, report_id='23285') # not in db yet!
larva <- exportReports(rcon, report_id='27172', labels = FALSE)
prokopak <- exportReports(rcon, report_id='27060', labels = FALSE)
bgSent <- exportReports(rcon, report_id='27169', labels = FALSE)
ovitrap <- exportReports(rcon, report_id='27170', labels = FALSE, factors = F)
hlc <- exportReports(rcon, report_id='27171', labels = FALSE)

# save data
# write.csv(larva, "VectorData/redcap/larva.csv", row.names=F)
# write.csv(prokopak, "VectorData/redcap/prokopak.csv", row.names=F)
# write.csv(bgSent, "VectorData/redcap/bgSent.csv", row.names=F)
# write.csv(ovitrap, "VectorData/redcap/ovitrap.csv", row.names=F)
# write.csv(hlc, "VectorData/redcap/hlc.csv", row.names=F)

#---- House
hse <- ddply(house, .(compound_house_id),
             summarise,
             study_site = unique(na.omit(study_site)))
hse$redcap_event_name <- paste0(hse$compound_house_id, "_arm_1")
hse$compound_house_id<-NULL

#---- Larvae
lv <- larva[!is.na(larva$redcap_repeat_instrument),]
lv$Date <- as.Date(lv$date_collected, "%Y-%m-%d", tz="Africa/Dar_es_Salaam")
# later may want to summarize aedes aegypti larvae, but data not currently available

lv2 <- ddply(lv, .(redcap_event_name, Date),
             summarise,
             early_instars = sum(na.omit(early_instars_larva_1_in)), #will out be here later?
             late_instars = sum(na.omit(late_instars_larva_1_in)), #will out be here later?
             pupae = sum(na.omit(pupae_larva_1_in) + sum(na.omit(pupae_larva_1_in))))

lv3 <- merge(lv2, hse, by="redcap_event_name") #4087 and 4282 are missing from house  
lv3$mon.yr <- format(lv3$Date, "%Y-%m")
write.csv(lv3, "Concatenated_Data/vector/larvae.csv", row.names=F)

#---- Prokopak
prok <- prokopak[!is.na(prokopak$redcap_repeat_instrument),]
prok$Date <- as.Date(prok$date_collected, "%Y-%m-%d", tz="Africa/Dar_es_Salaam")

prok2 <- ddply(prok, .(redcap_event_name, Date),
               summarise,
               a.aegypti_male = sum(na.omit(aedes_agypti_male_prokopack_indoor))+sum(na.omit(aedes_agypti_male_prokopack_outdoor)),
               a.aegypti_unfed = sum(na.omit(aedes_agypti_unfed_prokopack_indoor))+sum(na.omit(aedes_agypti_unfed_prokopack_outdoor)),
               a.aegypti_bloodfed = sum(na.omit(aedes_agypti_blood_fed_prokopack_indoor))+sum(na.omit(aedes_agypti_bloodfed_prokopack_outdoor)),
               a.aegypti_ratio_fed_unfed = a.aegypti_unfed/a.aegypti_bloodfed,
               a.aegypti_halfgravid = sum(na.omit(aedes_agypti_half_gravid_prokopack_indoor))+sum(na.omit(aedes_agypti_half_gravid_prokopack_outdoor)),
               a.aegypti_gravid = sum(na.omit(aedes_agypti_gravid_prokopack_indoor))+sum(na.omit(aedes_agypti_gravid_prokopack_outdoor)),
               a.aegypti_ratio_halfgravid_gravid = a.aegypti_halfgravid/a.aegypti_gravid,
               a.aegypti_female = (a.aegypti_unfed + a.aegypti_bloodfed + a.aegypti_halfgravid + a.aegypti_gravid),
               a.aegypti_total = (a.aegypti_male + a.aegypti_female),
               a.aegypti_ratio_female_male = a.aegypti_female/a.aegypti_total)

prok3 <- merge(prok2, hse, by="redcap_event_name") # missing houses
prok3$mon.yr <- format(prok3$Date, "%Y-%m")
write.csv(prok3, "Concatenated_Data/vector/prokopak.csv", row.names=F)

#---- BG Sentinel Traps
bg <- bgSent[!is.na(bgSent$survey_bg),]
bg$Date <- as.Date(bg$date_collected, "%Y-%m-%d", tz="Africa/Dar_es_Salaam")

bg2 <- ddply(bg, .(redcap_event_name, survey_bg),
             summarise,
             dropoffDate = min(Date),
             pickupDate = max(Date),
             a.aegypti_male = sum(na.omit(aedes_agypti_male_bg)),
             a.aegypti_unfed = sum(na.omit(aedes_agypti_unfed_bg)),
             a.aegypti_bloodfed = sum(na.omit(aedes_agypti_bloodfed_bg)),
             a.aegypti_ratio_fed_unfed = a.aegypti_unfed/a.aegypti_bloodfed,
             a.aegypti_halfgravid = sum(na.omit(aedes_agypti_half_gravid_bg)),
             a.aegypti_gravid = sum(na.omit(aedes_agypti_gravid_bg)),
             a.aegypti_ratio_halfgravid_gravid = a.aegypti_halfgravid/a.aegypti_gravid,
             a.aegypti_female = (a.aegypti_unfed + a.aegypti_bloodfed + a.aegypti_halfgravid + a.aegypti_gravid),
             a.aegypti_total = (a.aegypti_male + a.aegypti_female),
             a.aegypti_ratio_female_male = a.aegypti_female/a.aegypti_total)

bg2$num.days <- difftime(bg2$pickupDate, bg2$dropoffDate, units="days")
bg3 <- subset(bg2, num.days < 5) #house 0014, 0399, and 0630 have mistakes; some were left out for 1 day in which case num.days = 0
bg4 <- merge(bg3, hse, by="redcap_event_name") # missing houses
bg4$mon.yr <- format(bg4$pickupDate, "%Y-%m")
write.csv(bg4, "Concatenated_Data/vector/bg.csv", row.names=F)

#---- Ovitrap
ovi <- ovitrap[!is.na(ovitrap$redcap_repeat_instrument),]
ovi$date_set <- as.Date(ovi$date_set_day_ovitrap, "%Y-%m-%d", tz="Africa/Dar_es_Salaam")
ovi$date_collected <- as.Date(ovi$date_collected, "%Y-%m-%d", tz="Africa/Dar_es_Salaam")
ovi$eggs<-rowSums(ovi[,c("egg_count_ovitrap_in", "egg_count_ovitrap_out")], na.rm=TRUE)
ovi$num.days <- difftime(ovi$date_collected, ovi$date_set, units="days")
ovi2 <- subset(ovi, abs(num.days)<11)
ovi3 <- ovi2[,c("redcap_event_name", "date_set", "date_collected", "num.days", "eggs")] 
ovi4 <- merge(ovi3, hse, by="redcap_event_name")
ovi4$mon.yr <- format(ovi4$date_collected, "%Y-%m")
write.csv(ovi4, "Concatenated_Data/vector/ovitrap.csv", row.names=F)

#---- Human Landing Catches (HLC)
hlc2 <- hlc[!is.na(hlc$redcap_repeat_instrument),]
hlc2$Date <- as.Date(hlc2$date_collected, "%Y-%m-%d", tz="Africa/Dar_es_Salaam")

hlc3 <- ddply(hlc2, .(redcap_event_name, survey_hlc),
              summarise,
              start_date = min(Date),
              end_date = max(Date),
              num.days = difftime(end_date, start_date, units="days"),
              a.aegypti_male = sum(na.omit(aedes_agypti_male_hlc)),
              a.aegypti_unfed = sum(na.omit(aedes_agypti_unfed_hlc)),
              a.aegypti_bloodfed = sum(na.omit(aedes_agypti_bloodfed_hlc)),
              a.aegypti_ratio_fed_unfed = a.aegypti_unfed/a.aegypti_bloodfed,
              a.aegypti_halfgravid = sum(na.omit(aedes_agypti_half_gravid_hlc)),
              a.aegypti_gravid = sum(na.omit(aedes_agypti_gravid_hlc)),
              a.aegypti_ratio_halfgravid_gravid = a.aegypti_halfgravid/a.aegypti_gravid,
              a.aegypti_female = (a.aegypti_unfed + a.aegypti_bloodfed + a.aegypti_halfgravid + a.aegypti_gravid),
              a.aegypti_total = (a.aegypti_male + a.aegypti_female),
              a.aegypti_ratio_female_male = a.aegypti_female/a.aegypti_total)

hlc4 <- merge(hlc3, hse, by="redcap_event_name") # missing houses
hlc5 <- subset(hlc4, num.days <5) # while there are issues
hlc5$mon.yr <- format(hlc5$end_date, "%Y-%m")
write.csv(hlc5, "Concatenated_Data/vector/hlc.csv", row.names=F)

library(plyr)
library(dplyr)
library(tidyr)
library(zoo)
library(lubridate)
library(stringr)
library(redcapAPI)
library(REDCapR)
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/vector")
# import vector data -------------------------------------------------------------
Redcap.token <- readLines("api.key.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)
#vector <- redcap_read(redcap_uri  = REDcap.URL, token = Redcap.token, batch_size = 2)$data#export data from redcap to R (must be connected via cisco VPN)
#save(vector,file="vector.rda")
# load vector data -------------------------------------------------------------
  load(file="vector.rda")

write.csv(as.data.frame(vector), "vector.csv")

# subest data by form -----------------------------------------------------
vector$redcap_event_name<- str_pad(vector$compound_house_id, 4, pad = "0")
vector$redcap_event_name<- paste(vector$redcap_event_name, "arm_1", sep="_")
vector <-vector[which(vector$redcap_event_name!='test_arm_1')  , ]
vector<-vector[order(-(grepl('redcap', names(vector)))+1L)]
vector<-vector[order(-(grepl('date', names(vector)))+1L)]

#fill in missing values by group
    require(data.table)
    vector <- data.table(vector)
    vector[,study_site:=na.locf(study_site),by=compound_house_id]
    vector<-as.data.frame(vector)

# sum Prokopack vector data by date and variable -----------------------------------------------------
    prokopack<-vector[ , grepl( "redcap_event_name|prokopack|repeat|study_site|house" , names(vector) ) ]
    prokopack<-prokopack[which(prokopack$redcap_repeat_instrument=="prokopack")  , ]
    
  prokopack$date_time_prokopack<-ymd_hm(prokopack$date_time_prokopack)
  class(prokopack$date_time_prokopack)
  prokopack$date_collected<-prokopack$date_time_prokopack
  class(prokopack$date_collected)
  
  prokopack$time_prokopack<-format(prokopack$date_time_prokopack, "%H:%M")

  prokopack$date_collected<-trunc(prokopack$date_collected, units = "days")
  prokopack$month_year_lag<-  prokopack$month_year-30
  prokopack$date_collected<-as.POSIXct(prokopack$date_collected)
  class(prokopack$date_collected)
  prokopack$month_year<-as.yearmon(prokopack$date_collected)
  prokopack$month_year<-as.Date(prokopack$month_year)
  
  prokopack$month_year_lag<-as.yearmon(prokopack$month_year_lag)
  prokopack$month_year_lag<-as.Date(prokopack$month_year_lag)
  
  
    prokpack_indoor<-prokopack[which(prokopack$indoors_prokopack___1=="1")  , ]
      prokpack_indoor<-prokpack_indoor[ , grepl( "redcap_event_name|study_site|_indoor|date_collected|indoors_prokopack___1|team_leader_|survey_|no_sleepers" , names(prokpack_indoor) ) ]
      prokpack_indoor<-prokpack_indoor[ , !grepl( "other" , names(prokpack_indoor) ) ]
      prokpack_indoor$date_collected<-as.factor(as.character(prokpack_indoor$date_collected))
        prokpack_indoor_sum <-aggregate(. ~date_collected + redcap_event_name + survey_prokopack, data=prokpack_indoor, sum, na.rm=TRUE)
        prokpack_indoor_sum <- within(prokpack_indoor_sum, indoors_prokopack___1[prokpack_indoor_sum$indoors_prokopack___1 >1] <- 1)
        prokpack_indoor_sum <- within(prokpack_indoor_sum, team_leader_prokopack___2[prokpack_indoor_sum$team_leader_prokopack___2 >1] <- 1)
        prokpack_indoor_sum <- within(prokpack_indoor_sum, team_leader_prokopack___3[prokpack_indoor_sum$team_leader_prokopack___3 >1] <- 1)
        prokpack_indoor_sum <- within(prokpack_indoor_sum, team_leader_prokopack___4[prokpack_indoor_sum$team_leader_prokopack___4 >1] <- 1)
        prokpack_indoor_sum$date_collected<-as.numeric(as.Date(prokpack_indoor_sum$date_collected))
        

        n_distinct(prokpack_indoor$date_collected,  prokpack_indoor$redcap_event_name)

    prokpack_outdoor<-prokopack[which(prokopack$indoors_prokopack___2=="1")  , ]
    prokpack_outdoor<-prokpack_outdoor[ , grepl( "redcap_event_name|study_site|_outdoor|date_collected|indoors_prokopack___2|bushes|grass|survey_" , names(prokpack_outdoor) ) ]
      prokpack_outdoor$date_collected<-as.factor(as.character(prokpack_outdoor$date_collected))
      prokpack_outdoor_sum <-aggregate(. ~date_collected + redcap_event_name + survey_prokopack, data=prokpack_outdoor, sum, na.rm=TRUE)
      
      prokpack_outdoor_sum <- within(prokpack_outdoor_sum, indoors_prokopack___2[prokpack_outdoor_sum$indoors_prokopack___2 >1] <- 1)
      prokpack_outdoor_sum <- within(prokpack_outdoor_sum, bushes_around_the_house_prokopack[prokpack_outdoor_sum$bushes_around_the_house_prokopack >1] <- 1)
      prokpack_outdoor_sum <- within(prokpack_outdoor_sum, tall_grass_around_the_house_prokopack[prokpack_outdoor_sum$tall_grass_around_the_house_prokopack >1] <- 1)
      prokpack_outdoor_sum$date_collected<-as.numeric(as.Date(prokpack_outdoor_sum$date_collected))

      prokopack$prokpack_sum_indoor<-rowSums(prokopack[,grep("aedes_agypti_unfed_prokopack_indoor| aedes_agypti_blood_fed_prokopack_indoor|aedes_agypti_half_gravid_prokopack_indoor|aedes_agypti_gravid_prokopack_indoor", names(prokopack))], na.rm = TRUE)
      prokopack$prokpack_sum_outdoor<-rowSums(prokopack[,grep("aedes_agypti_unfed_prokopack_outdoor| aedes_agypti_blood_fed_prokopack_outdoor|aedes_agypti_half_gravid_prokopack_outdoor|aedes_agypti_gravid_prokopack_outdoor", names(prokopack))], na.rm = TRUE)
      prokopack$prokpack_sum<-rowSums(prokopack[,grep("prokpack_sum_outdoor|prokpack_sum_indoor", names(prokopack))], na.rm = TRUE)

      # monthly summary by site: prokopack -------------------------------------------------------------
      Monthlyprokopack <- ddply(prokopack, ~month_year + study_site, summarise, 
                                 Ttl_Aedes.spp_in.proko = sum(prokpack_sum_indoor ),
                                 Ttl_Aedes.spp_out.proko = sum(prokpack_sum_outdoor )) 
      house.prokopack <- ddply(prokopack, ~compound_house_id + study_site, summarise, 
                                 Ttl_Aedes.spp_in.proko = sum(prokpack_sum_indoor ),
                                 Ttl_Aedes.spp_out.proko = sum(prokpack_sum_outdoor )) 
      
# sum gps data by house -----------------------------------------------------
      gps<-vector[ , grepl( "redcap_event_name|study_site|latit|long|altit|acuracy|redcap_repeat_instrument|compound_house_id" , names(vector) ) ]
      gps<-gps[which(gps$redcap_repeat_instrument=="")  , ]
      gps<-gps[ , grepl( "redcap_event_name|study_site|latit|long|altit|acuracy|compound_house_id" , names(gps) ) ]
      
      gps$date_collected <-min(prokopack$date_collected)
      gps$date_collected<-as.numeric(as.Date(gps$date_collected))
      gps<-gps[,order(colnames(gps))]
      gps<-gps[order(-(grepl('date|red', names(gps)))+1L)]
      
# sum house data by house -----------------------------------------------------
      house<-vector[1:45]
      house<-house[ , !grepl( "latit|long|altit|acuracy|larva|prokopack|bg|hlc|ovitrap" , names(house) ) ]
      house<-house[which(house$redcap_repeat_instrument=="house_repeatable")  , ]
      house<-house[ , !grepl( "repeat" , names(house) ) ]
      
      house$date_collected<-as.numeric(as.Date(house$date_house))
      house<-house[ , !grepl( "date_house" , names(house) ) ]
      house$date_collected <-min(prokopack$date_collected)
      house$date_collected<-as.numeric(as.Date(house$date_collected))
      
      
      house<-house[,order(colnames(house))]
      house<-house[order(-(grepl('date|red', names(house)))+1L)]

      house_first <- house[order(house$compound_house_id, house$date_collected),]
      house_first <- ordered_data[!duplicated(ordered_data$compound_house_id),]
      
      
# sum larva by house  and make wide -----------------------------------------------------
      larva<-vector[ , grepl( "redcap_event_name|study_site|larva|repeat|compound_house_id" , names(vector) ) ]
      larva<-larva[which(larva$redcap_repeat_instrument=="larva")  , ]
      larva<-larva[order(-(grepl('date|red', names(larva)))+1L)]
      names(larva)[names(larva) == 'date_time_larva'] <- 'date_collected'

      larva$date_collected<-ymd_hm(larva$date_collected)
      larva$time_larva<-format(larva$date_collected, "%H:%M")
      larva$date_collected<-trunc(larva$date_collected, units = "days")
      larva$date_collected<-as.numeric(as.Date(larva$date_collected))

      larva<-larva[,order(colnames(larva))]


      larva<-larva[order((grepl('_1$', names(larva)))+1L)]
      larva<-larva[order((grepl('_2$', names(larva)))+1L)]
      larva<-larva[order((grepl('_3$', names(larva)))+1L)]
      larva<-larva[order((grepl('_4$', names(larva)))+1L)]
      larva<-larva[order((grepl('_5$', names(larva)))+1L)]
      larva<-larva[order((grepl('_6$', names(larva)))+1L)]
      larva<-larva[order((grepl('_7$', names(larva)))+1L)]
      larva<-larva[order((grepl('_8$', names(larva)))+1L)]
      larva<-larva[order((grepl('_9$', names(larva)))+1L)]
      larva<-larva[order((grepl('_10$', names(larva)))+1L)]
      larva<-larva[order((grepl('_11$', names(larva)))+1L)]
      larva<-larva[order((grepl('_12$', names(larva)))+1L)]
      larva<-larva[order((grepl('_13$', names(larva)))+1L)]
      larva<-larva[order((grepl('_14$', names(larva)))+1L)]
      larva<-larva[order((grepl('_15$', names(larva)))+1L)]

  larva<-larva[order(-(grepl('team_leader', names(larva)))+1L)]
      #wide to long for all the containers
  v.names=c("aedes_species_larva","aedes_species_larva_other","anopheles_species_larva","anopheles_species_larva_other","early_instars_larva", "genus_larva","genus_other_larva","habitat_id_larva","habitat_size_larva","habitat_type_larva", "habitat_type_other_larva", "late_instars_larva","pupae_larva")
  
#        v.names=c("habitat_id_larva", "habitat_size_larva", "habitat_type_larva", "habitat_type_other_larva", "genus_larva",  "genus_other_larva",   "aedes_species_larva_other", "anopheles_species_larva", "anopheles_species_larva_other", "early_instars_larva", "late_instars_larva", "pupae_larva")
        #v.names=c("pupae_larva", "late_instars_larva",   "early_instars_larva", "anopheles_species_larva_other", "anopheles_species_larva", "aedes_species_larva_other","aedes_species_larva", "genus_other_larva", "genus_larva","habitat_type_other_larva", "habitat_type_larva","habitat_size_larva","habitat_id_larva")
        times=c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 12, 14, 15)
        #  View(larva)
            larva_long<-reshape(larva, idvar = c("date_collected", "redcap_event_name", "redcap_repeat_instance"), varying = c(22:216),  direction = "long", timevar = "container_number", times = times, v.names = v.names)
            #replace "" with NA
            larva_long[larva_long==""]<-NA
            larva_long$date_collected<-as.Date(larva_long$date_collected)
            larva_long$month_year_lag<-larva_long$date_collected-30
            larva_long$month_year_lag<-as.yearmon(larva_long$month_year_lag)
            larva_long$month_year<-as.yearmon(larva_long$date_collected)
            larva_long$month_year<-as.Date(larva_long$month_year)
            larva_long$month_year_lag<-as.Date(larva_long$month_year_lag)
            
            larva_long<-larva_long[which(!is.na(larva_long$date_collected))  , ]
            larva_long<-larva_long[which(!is.na(larva_long$month_year_lag))  , ]
            
            larva_long<-larva_long[ , !grepl( "repeat_instance" , names(larva_long) ) ]
            larva_long <-larva_long[which(!is.na(larva_long$aedes_species_larva)|!is.na(larva_long$aedes_species_larva_other)|!is.na(larva_long$anopheles_species_larva)|!is.na(larva_long$anopheles_species_larva_other)|!is.na(larva_long$early_instars_larva)|!is.na(larva_long$genus_larva)|!is.na(larva_long$genus_other_larva)|!is.na(larva_long$habitat_id_larva)|!is.na(larva_long$habitat_size_larva)|!is.na(larva_long$habitat_type_larva)|!is.na(larva_long$habitat_type_other_larva))  , ]
            
            larva_long_aedes<-larva_long[which(larva_long$genus_larva=="1"|!is.na(larva_long$aedes_species_larva))  , ]
            larva_long_aedes$larva_sum<-rowSums(larva_long_aedes[,grep("late_instars_larva| pupae_larva|early_instars_larva", names(larva_long_aedes))], na.rm = TRUE)
            hist(larva_long_aedes$larva_sum)
            

      #add in room_place for each container and for in and out.
        larva_out<-larva_long[which(larva_long$inoutdoors_larva =="2")  , ]

        larva_in<-larva_long[which(larva_long$inoutdoors_larva=="1")  , ]

        #remove all missing rows.

        larva_in <-larva_in[which(!is.na(larva_in$aedes_species_larva)|!is.na(larva_in$aedes_species_larva_other)|!is.na(larva_in$anopheles_species_larva)|!is.na(larva_in$anopheles_species_larva_other)|!is.na(larva_in$early_instars_larva)|!is.na(larva_in$genus_larva)|!is.na(larva_in$genus_other_larva)|!is.na(larva_in$habitat_id_larva)|!is.na(larva_in$habitat_size_larva)|!is.na(larva_in$habitat_type_larva)|!is.na(larva_in$habitat_type_other_larva))  , ]
    
            larva_in$date_house_in_out<-paste(larva_in$date_collected, larva_in$redcap_event_name, larva_in$inoutdoors_larva)
            larva_in$count<-with(larva_in, ave(as.character(date_house_in_out), date_house_in_out, FUN = seq_along))
            larva_in$count<-as.numeric(as.character(larva_in$count))
            hist(larva_in$count)

        larva_out <-larva_out[which(!is.na(larva_out$aedes_species_larva)|!is.na(larva_out$aedes_species_larva_other)|!is.na(larva_out$anopheles_species_larva)|!is.na(larva_out$anopheles_species_larva_other)|!is.na(larva_out$early_instars_larva)|!is.na(larva_out$genus_larva)|!is.na(larva_out$genus_other_larva)|!is.na(larva_out$habitat_id_larva)|!is.na(larva_out$habitat_size_larva)|!is.na(larva_out$habitat_type_larva)|!is.na(larva_out$habitat_type_other_larva)) , ]

            larva_out$date_house_in_out<-paste(larva_out$date_collected, larva_out$redcap_event_name, larva_out$inoutdoors_larva)
            larva_out$count<-with(larva_out, ave(as.character(date_house_in_out), date_house_in_out, FUN = seq_along))
            larva_out$count<-as.numeric(as.character(larva_out$count))
            hist(larva_out$count)
            hist(larva_out$early_instars_larva)
            
            # monthly summary by site: larva_long_aedes -------------------------------------------------------------
            Monthlylarva_long_aedes <- ddply(larva_long_aedes, ~month_year +study_site, summarise, 
                                             Ttl_Aedes.spp.larva = sum(larva_sum )) 
            house.larva_long_aedes <- ddply(larva_long_aedes, ~compound_house_id+ study_site, summarise, 
                                            Ttl_Aedes.spp.larva = sum(larva_sum )) 
            


# sum bg by month/house -----------------------------------------------------
      bg<-vector[ , grepl( "redcap_event_name|study_site|bg|repeat|house" , names(vector) ) ]
      bg<-bg[which(bg$redcap_repeat_instrument=="bg")  , ]
      bg<-bg[which(!is.na(bg$datetime_bg)|!is.na(bg$date_bg))  , ]
      
      bg$bg_aedes_sum<-rowSums(bg[,grep("aedes_agypti_gravid_bg|aedes_agypti_half_gravid_bg|aedes_agypti_unfed_bg|aedes_agypti_bloodfed_bg", names(bg))], na.rm = TRUE)
    
      bg[bg==""]<-NA
      bg$datetime_bg[is.na(bg$datetime_bg)] <- bg$date_bg[is.na(bg$datetime_bg)]
      bg$datetime_bg<-as.Date(bg$datetime_bg)
      bg$date_collected<-trunc(bg$datetime_bg, units = "days")
      bg$month_year_lag<-bg$date_collected-30
      bg$month_year_lag<-as.yearmon(bg$month_year_lag)
      bg$month_year<-as.yearmon(bg$datetime_bg)

      bg$month_year<-as.Date(bg$month_year)
      bg$month_year_lag<-as.Date(bg$month_year_lag)
      
      bg$month_year<-as.Date(bg$month_year)
      
      # monthly summary by site: bg -------------------------------------------------------------
      Monthlybg <- ddply(bg, ~month_year +study_site, summarise, 
                         Ttl_Aedes.spp.bg = sum(bg_aedes_sum )) 
      house.bg <- ddply(bg, ~compound_house_id + study_site, summarise, 
                         Ttl_Aedes.spp.bg = sum(bg_aedes_sum )) 
      
# sum ovi  by house  and make wide -----------------------------------------------------
      ovi<-vector[ , grepl( "redcap_event_name|study_site|ovi|repeat|house" , names(vector) ) ]
      ovi<-ovi[which(ovi$redcap_repeat_instrument=="ovitrap")  , ]
      ovi$egg_count<-rowSums(ovi[,grep("egg_count_ovitrap_in|egg_count_ovitrap_out", names(ovi))], na.rm = TRUE)

      ovi$date_set_day_ovitrap<-as.Date(ovi$date_set_day_ovitrap)
      ovi$month_year_lag<-ovi$date_set_day_ovitrap-30
      ovi$month_year_lag<-as.yearmon(ovi$month_year_lag)
      
      ovi$month_year<-as.yearmon(ovi$date_set_day_ovitrap)
      ovi$month_year<-as.Date(ovi$month_year)
      ovi$month_year_lag<-as.Date(ovi$month_year_lag)
      ovi<-ovi[which(!is.na(ovi$month_year))  , ]
      ovi<-ovi[which(!is.na(ovi$month_year_lag))  , ]
      ovi$month_year<-as.Date(ovi$month_year_lag)
      
      # monthly/house summary: ovitrap -------------------------------------------------------------
      ovi$aedes_species_ovitrap_out<-as.numeric(ovi$aedes_species_ovitrap_out)
      ovi$aedes_species_ovitrap_in<-as.numeric(ovi$aedes_species_ovitrap_in)
      MonthlyOvitrap <- ddply(ovi, ~month_year+study_site , summarise, 
                              Ttl_Aedes.spp.Indoor.ovi = sum(egg_count_ovitrap_in ),
                              ttl_Aedes_spp_Outdoor.ovi = sum(egg_count_ovitrap_out)) 
      house.Ovitrap <- ddply(ovi, ~compound_house_id + study_site , summarise, 
                             Ttl_Aedes.spp.Indoor.ovi = sum(egg_count_ovitrap_in ),
                             ttl_Aedes_spp_Outdoor.ovi = sum(egg_count_ovitrap_out)) 
      

                             
# sum hlc by house  and make wide -----------------------------------------------------
      hlc<-vector[ , grepl( "redcap_event_name|study_site|hlc|repeat|house" , names(vector) ) ]
      hlc<-hlc[which(hlc$redcap_repeat_instrument=="hlc")  , ]
      hlc[hlc==""]<-NA
      hlc<-hlc[which(!is.na(hlc$date_hlc))  , ]
      hlc$hlc_aedes_sum<-rowSums(hlc[,grep("aedes_agypti_half_gravid_hlc|aedes_agypti_unfed_hlc|aedes_agypti_bloodfed_hlc|aedes_agypti_gravid_hlc", names(hlc))], na.rm = TRUE)
      
      hlc$date_hlc<-as.Date(hlc$date_hlc)
      hlc$month_year_lag<-hlc$date_hlc-30

      hlc$month_year<-as.yearmon(hlc$date_hlc)
      hlc$month_year_lag<-as.yearmon(hlc$month_year_lag)
      hlc$month_year<-as.Date(hlc$month_year)
      hlc$month_year_lag<-as.Date(hlc$month_year_lag)
      
      # monthly summary by site: hlc -------------------------------------------------------------
      Monthlyhlc <- ddply(hlc, ~month_year +study_site , summarise, 
                           Ttl_Aedes.spp.hlc = sum(hlc_aedes_sum ))  
      house.hlc <- ddply(hlc, ~compound_house_id + study_site, summarise, 
                          Ttl_Aedes.spp.hlc = sum(hlc_aedes_sum ))  
      

# merge the trap types by site/month-------------------------------------------------
      Monthlyvector<-merge(MonthlyOvitrap, Monthlybg, by = c("month_year", "study_site"), all = TRUE)
      Monthlyvector<-merge(Monthlyvector, Monthlyprokopack, by = c("month_year", "study_site"), all = TRUE)
      Monthlyvector<-merge(Monthlyvector, Monthlyhlc, by = c("month_year", "study_site"), all = TRUE)
      Monthlyvector<-merge(Monthlyvector, Monthlylarva_long_aedes, by = c("month_year", "study_site"), all = TRUE)
      
    table(Monthlyvector$study_site, exclude=NULL)      
# save Monthlyvector data -------------------------------------------------------------
      save(Monthlyvector,file="Monthlyvector.rda")
    
# merge the trap types by house-------------------------------------------------
    house.vector<-merge(house.Ovitrap, house.bg, by = c("compound_house_id","study_site"), all = TRUE)
    house.vector<-merge(house.vector, house.prokopack, by = c("compound_house_id","study_site"), all = TRUE)
    house.vector<-merge(house.vector, house.hlc, by = c("compound_house_id","study_site"), all = TRUE)
    house.vector<-merge(house.vector, house.larva_long_aedes, by = c("compound_house_id","study_site"), all = TRUE)
    house.vector<-merge(house.vector, gps, by = c("compound_house_id","study_site"), all = TRUE)
    
    house.vector<-merge(house.vector, house_first, by = c("compound_house_id" ,"study_site"),all.x=TRUE)
  
    house.vector <-house.vector[which(!is.na(house.vector$Ttl_Aedes.spp.Indoor.ovi)|!is.na(house.vector$ttl_Aedes_spp_Outdoor.ovi)|!is.na(house.vector$Ttl_Aedes.spp.bg)|!is.na(house.vector$Ttl_Aedes.spp_in.proko)|!is.na(house.vector$Ttl_Aedes.spp_out.proko)|!is.na(house.vector$Ttl_Aedes.spp.hlc)|!is.na(house.vector$Ttl_Aedes.spp.larva)), ]
    house.vector[, 3:9][is.na(house.vector[, 3:9])] <- 0
    
    table(house.vector$study_site, exclude = NULL)

#gps
    house.vector <-house.vector[which(!is.na(house.vector$latitude)&!is.na(house.vector$longitude)), ]
    house.vector <-house.vector[which(house.vector$compound_house_id!="2002"), ]#exclude for now.
    write.csv(as.data.frame(house.vector), "house.vector.gps.csv")

    coordinates(house.vector) <- ~longitude + latitude
    

    require(raster)
    projection(house.vector) = "+proj=utm +zone=37 +datum=WGS84" # WGS84 coords
    shapefile(house.vector, "house.vector.shp", overwrite=TRUE)
    

    house.vector.u <-house.vector[which(house.vector$study_site==1), ]
    house.vector.m <-house.vector[which(house.vector$study_site==2), ]
    house.vector.c <-house.vector[which(house.vector$study_site==3), ]
    house.vector.k <-house.vector[which(house.vector$study_site==4), ]
    
    library(rgdal)
    library(sp)
    library(classInt)
    text1 = list("sp.text", c(178600,333090), "0")
    text2 = list("sp.text", c(179100,333090), "500 m")
    scale = list("SpatialPolygonsRescale", layout.scale.bar(), offset = c(178600,332990), scale = 500, fill=c("transparent","black"))
    arrow = list("SpatialPolygonsRescale", layout.north.arrow(), offset = c(178750,332500), scale = 400)
    plot.vector.u<-spplot(house.vector.u, c("Ttl_Aedes.spp.larva","Ttl_Aedes.spp_out.proko","Ttl_Aedes.spp_in.proko","Ttl_Aedes.spp.hlc","Ttl_Aedes.spp.Indoor.ovi","ttl_Aedes_spp_Outdoor.ovi","Ttl_Aedes.spp.bg"), do.log=T, main = "Total Aedes Mosquito count 2014-2017", sub = "Source: LaBeaud et.al.", 
           key.space = "right", as.table = TRUE, cuts = c(.2,.5,1,2,5,10,20,50,100,200,500,1000,2000), sp.layout=list(scale,text1,text2,arrow))
    
    plot.vector.m<-spplot(house.vector.m, c("Ttl_Aedes.spp.larva","Ttl_Aedes.spp_out.proko","Ttl_Aedes.spp_in.proko","Ttl_Aedes.spp.hlc","Ttl_Aedes.spp.Indoor.ovi","ttl_Aedes_spp_Outdoor.ovi","Ttl_Aedes.spp.bg"), do.log=T, main = "Total Aedes Mosquito count 2014-2017", sub = "Source: LaBeaud et.al.", 
           key.space = "right", as.table = TRUE, cuts = c(.2,.5,1,2,5,10,20,50,100,200,500,1000,2000), sp.layout=list(scale,text1,text2,arrow))
    
    plot.vector.c<-spplot(house.vector.c, c("Ttl_Aedes.spp.larva","Ttl_Aedes.spp_out.proko","Ttl_Aedes.spp_in.proko","Ttl_Aedes.spp.hlc","Ttl_Aedes.spp.Indoor.ovi","ttl_Aedes_spp_Outdoor.ovi","Ttl_Aedes.spp.bg"), do.log=T, main = "Total Aedes Mosquito count 2014-2017", sub = "Source: LaBeaud et.al.", 
           key.space = "right", as.table = TRUE, cuts = c(.2,.5,1,2,5,10,20,50,100,200,500,1000,2000), sp.layout=list(scale,text1,text2,arrow))
    
    plot.vector.k<-spplot(house.vector.k, c("Ttl_Aedes.spp.larva","Ttl_Aedes.spp_out.proko","Ttl_Aedes.spp_in.proko","Ttl_Aedes.spp.hlc","Ttl_Aedes.spp.Indoor.ovi","ttl_Aedes_spp_Outdoor.ovi","Ttl_Aedes.spp.bg"), do.log=T, main = "Total Aedes Mosquito count 2014-2017", sub = "Source: LaBeaud et.al.", 
           key.space = "right", as.table = TRUE, cuts = c(.2,.5,1,2,5,10,20,50,100,200,500,1000,2000), sp.layout=list(scale,text1,text2,arrow))

    library(gridExtra)
    
    grid.arrange(plot.vector.u,plot.vector.k,plot.vector.m,plot.vector.c)
    

    
    
   
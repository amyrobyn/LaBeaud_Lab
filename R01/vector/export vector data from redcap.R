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

  prokopack$month_year_lag<-trunc(prokopack$date_collected, units = "days")
    prokopack$month_year_lag<-  prokopack$month_year-30
  prokopack$date_collected<-as.POSIXct(prokopack$date_collected)
  prokopack$month_year<-as.yearmon(prokopack$date_collected)
  prokopack$month_year<-as.Date(prokopack$month_year)
  
  prokopack$month_year_lag<-as.yearmon(prokopack$month_year_lag)
  prokopack$month_year_lag<-as.Date(prokopack$month_year_lag)
  
  
    prokpack_indoor<-prokopack[which(prokopack$indoors_prokopack___1=="1")  , ]
      prokpack_indoor<-prokpack_indoor[ , grepl( "redcap_event_name|study_site|_indoor|date_collected|indoors_prokopack___1|team_leader_|survey_|no_sleepers" , names(prokpack_indoor) ) ]
      prokpack_indoor<-prokpack_indoor[ , !grepl( "other" , names(prokpack_indoor) ) ]
      
      prokpack_indoor<-prokpack_indoor[order((-grepl('redcap', names(prokpack_indoor)))+1L)]
      prokpack_indoor<-prokpack_indoor[order((-grepl('date_collected', names(prokpack_indoor)))+1L)]
      
      write.csv(as.data.frame(prokpack_indoor), "prokpack_indoor_redcap.csv", na="", row.names = FALSE)
      
      ## S3 method for class 'redcapApiConnection' THis method will require reformatting all the dates to meet redcap standards.
        Redcap.token <- readLines("api.key.txt") # Read API token from folder
        REDcap.URL  <- 'https://redcap.stanford.edu/api/'
        rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)
        
        
        prokpack_indoor$redcap_repeat_instance<-paste(prokpack_indoor$date_collected, prokpack_indoor$redcap_event_name)
        prokpack_indoor$redcap_repeat_instance<-with(prokpack_indoor, ave(as.character(redcap_repeat_instance), redcap_repeat_instance, FUN = seq_along))
        prokpack_indoor$redcap_repeat_instance<-as.numeric(as.character(prokpack_indoor$redcap_repeat_instance))
        table(prokpack_indoor$redcap_repeat_instance)
        prokpack_indoor$redcap_repeat_instrument<-"prokopack"

        prokpack_indoor_redcap<-prokpack_indoor
        prokpack_indoor_redcap<-prokpack_indoor_redcap[ , !grepl( "study_site" , names(prokpack_indoor_redcap) ) ]
        prokpack_indoor_redcap<-prokpack_indoor_redcap[order(-(grepl('redcap_repeat_instance', names(prokpack_indoor_redcap)))+1L)]
        prokpack_indoor_redcap<-prokpack_indoor_redcap[order(-(grepl('redcap_repeat_instrument', names(prokpack_indoor_redcap)))+1L)]
        prokpack_indoor_redcap<-prokpack_indoor_redcap[order(-(grepl('redcap_event_name', names(prokpack_indoor_redcap)))+1L)]
        prokpack_indoor_redcap<-prokpack_indoor_redcap[order(-(grepl('date_collected', names(prokpack_indoor_redcap)))+1L)]

        #write.csv(as.data.frame(prokpack_indoor_redcap), "prokpack_indoor_redcap.csv", row.names = F, na="")
      
      prokpack_indoor$date_collected<-as.factor(as.character(prokpack_indoor$date_collected))
        prokpack_indoor_sum <-aggregate(. ~date_collected + redcap_event_name + survey_prokopack, data=prokpack_indoor, sum, na.rm=TRUE)
        prokpack_indoor_sum <- within(prokpack_indoor_sum, indoors_prokopack___1[prokpack_indoor_sum$indoors_prokopack___1 >1] <- 1)
        prokpack_indoor_sum <- within(prokpack_indoor_sum, team_leader_prokopack___2[prokpack_indoor_sum$team_leader_prokopack___2 >1] <- 1)
        prokpack_indoor_sum <- within(prokpack_indoor_sum, team_leader_prokopack___3[prokpack_indoor_sum$team_leader_prokopack___3 >1] <- 1)
        prokpack_indoor_sum <- within(prokpack_indoor_sum, team_leader_prokopack___4[prokpack_indoor_sum$team_leader_prokopack___4 >1] <- 1)
        prokpack_indoor_sum$date_collected<-as.numeric(as.Date(prokpack_indoor_sum$date_collected))
        
        n_distinct(prokpack_indoor$date_collected, prokpack_indoor$redcap_event_name)

    prokpack_outdoor<-prokopack[which(prokopack$indoors_prokopack___2=="1")  , ]
    prokpack_outdoor<-prokpack_outdoor[ , grepl( "redcap_event_name|study_site|_outdoor|date_collected|indoors_prokopack___2|bushes|grass|survey_" , names(prokpack_outdoor) ) ]
    prokpack_outdoor<-prokpack_outdoor[ , !grepl( "sum" , names(prokpack_outdoor) ) ]
    prokpack_outdoor<-prokpack_outdoor[order((-grepl('redcap', names(prokpack_outdoor)))+1L)]
    prokpack_outdoor<-prokpack_outdoor[order((-grepl('date_collected', names(prokpack_outdoor)))+1L)]
    prokpack_outdoor_redcap<-prokpack_outdoor

    ## S3 method for class 'redcapApiConnection' THis method will require reformatting all the dates to meet redcap standards.

    prokpack_outdoor_redcap$redcap_repeat_instance<-paste(prokpack_outdoor_redcap$date_collected, prokpack_outdoor_redcap$redcap_event_name)
    prokpack_outdoor_redcap$redcap_repeat_instance<-with(prokpack_outdoor_redcap, ave(as.character(redcap_repeat_instance), redcap_repeat_instance, FUN = seq_along))
    redcap_repeat_instance<-as.numeric(as.character(prokpack_outdoor_redcap$redcap_repeat_instance))
    table(prokpack_outdoor_redcap$redcap_repeat_instance)
    prokpack_outdoor_redcap$redcap_repeat_instrument<-"prokopack"
    prokpack_outdoor_redcap<-prokpack_outdoor_redcap[order(-(grepl('date_collected|redcap', names(prokpack_outdoor_redcap)))+1L)]
    prokpack_outdoor_redcap<-prokpack_outdoor_redcap[ , !grepl( "study_site" , names(prokpack_outdoor_redcap) ) ]
    

      prokpack_outdoor$date_collected<-as.factor(as.character(prokpack_outdoor$date_collected))
      prokpack_outdoor_sum <-aggregate(. ~date_collected + redcap_event_name + survey_prokopack, data=prokpack_outdoor, sum, na.rm=TRUE)
      
      prokpack_outdoor_sum <- within(prokpack_outdoor_sum, indoors_prokopack___2[prokpack_outdoor_sum$indoors_prokopack___2 >1] <- 1)
      prokpack_outdoor_sum <- within(prokpack_outdoor_sum, bushes_around_the_house_prokopack[prokpack_outdoor_sum$bushes_around_the_house_prokopack >1] <- 1)
      prokpack_outdoor_sum <- within(prokpack_outdoor_sum, tall_grass_around_the_house_prokopack[prokpack_outdoor_sum$tall_grass_around_the_house_prokopack >1] <- 1)
      prokpack_outdoor_sum$date_collected<-as.numeric(as.Date(prokpack_outdoor_sum$date_collected))

      prokopack$prokpack_sum_indoor<-rowSums(prokopack[,grep("aedes_agypti_unfed_prokopack_indoor| aedes_agypti_blood_fed_prokopack_indoor|aedes_agypti_half_gravid_prokopack_indoor|aedes_agypti_gravid_prokopack_indoor", names(prokopack))], na.rm = TRUE)
      prokopack$prokpack_sum_outdoor<-rowSums(prokopack[,grep("aedes_agypti_unfed_prokopack_outdoor| aedes_agypti_blood_fed_prokopack_outdoor|aedes_agypti_half_gravid_prokopack_outdoor|aedes_agypti_gravid_prokopack_outdoor", names(prokopack))], na.rm = TRUE)
      prokopack$prokpack_sum<-rowSums(prokopack[,grep("prokpack_sum_outdoor|prokpack_sum_indoor", names(prokopack))], na.rm = TRUE)
      Monthlyprokopack$prokpack_sum<-Monthlyprokopack$prokpack_sum_indoor+Monthlyprokopack$prokpack_sum_outdoor
      # monthly summary by site: prokopack -------------------------------------------------------------
      Monthlyprokopack <- ddply(prokopack, ~month_year + study_site, summarise, 
                                 Ttl_Aedes.spp_in.proko = sum(prokpack_sum_indoor ),
                                 Ttl_Aedes.spp_out.proko = sum(prokpack_sum_outdoor ),
                                Ttl_Aedes.spp.proko = sum(prokpack_sum ),
                                Ttl_Aedes.spp.proko.sd = sd(prokpack_sum ),
                                Ttl_Aedes.spp.proko.mean = mean(prokpack_sum )
      ) 
      house.prokopack <- ddply(prokopack, ~compound_house_id + study_site, summarise, 
                                 Ttl_Aedes.spp_in.proko = sum(prokpack_sum_indoor ),
                                 Ttl_Aedes.spp_out.proko = sum(prokpack_sum_outdoor )) 
      
      Monthlyprokopack$z.Ttl_Aedes.spp.proko<-(Monthlyprokopack$Ttl_Aedes.spp.proko-Monthlyprokopack$Ttl_Aedes.spp.proko.mean)/Monthlyprokopack$Ttl_Aedes.spp.proko.sd
      hist(Monthlyprokopack$z.Ttl_Aedes.spp.proko)
      
      
# sum gps data by house -----------------------------------------------------
      gps<-vector[ , grepl( "redcap_event_name|study_site|latit|long|altit|acuracy|redcap_repeat_instrument|compound_house_id|village" , names(vector) ) ]
      gps<-gps[which(gps$redcap_repeat_instrument=="")  , ]
      gps<-gps[ , grepl( "redcap_event_name|study_site|latit|long|altit|acuracy|compound_house_id|village" , names(gps) ) ]
      
      library(dplyr)    
      mindate<-prokopack %>% group_by(compound_house_id) %>% slice(which.min(date_collected))
      gps<-gps[ , !grepl( "date_collected" , names(gps) ) ]
      mindate<-mindate[ , grepl( "date_collected|compound_house_id" , names(mindate) ) ]
      gps<-merge(gps, mindate, by="compound_house_id")

      gps<-gps[,order(colnames(gps))]
      gps<-gps[order(-(grepl('date|red', names(gps)))+1L)]
      gps_redcap<-gps
  
      importRecords(rcon, gps_redcap, overwriteBehavior = "normal", returnContent = c("count", "ids", "nothing"), returnData = FALSE, logfile = "", proj = NULL,batch.size = -1)
      
# sum house data by house -----------------------------------------------------
      house<-vector[1:45]
      house<-house[ , !grepl( "latit|long|altit|acuracy|larva|prokopack|bg|hlc|ovitrap" , names(house) ) ]
      house<-house[which(house$redcap_repeat_instrument=="house_repeatable")  , ]
      house<-house[ , !grepl( "repeat" , names(house) ) ]
      colnames(house)[colnames(house)=="date_house"] <- "date_collected"

      house<-house[,order(colnames(house))]
      house<-house[order(-(grepl('date|red', names(house)))+1L)]

      house_first <- house[order(house$compound_house_id, house$date_collected),]
      house_first <- house_first[!duplicated(house_first$compound_house_id),]
      
      house_redcap<-house
      house_redcap<-house_redcap[ , !grepl( "date_house" , names(house_redcap) ) ]
      house_redcap<-house_redcap[which(!is.na(house_redcap$date_collected))  , ]
      house_redcap<-house_redcap[which(house_redcap$date_collected!="")  , ]
      house_redcap<-house_redcap[which(house_redcap$date_collected!="  ")  , ]
      house_redcap$date_collected<-as.Date(house_redcap$date_collected)
      importRecords(rcon, house_redcap, overwriteBehavior = "normal", returnContent = c("count", "ids", "nothing"), returnData = FALSE, logfile = "", proj = NULL, batch.size = -1)
      
      
# sum larva by house -----------------------------------------------------
      larva<-vector[ , grepl( "redcap_event_name|study_site|larva|repeat|compound_house_id" , names(vector) ) ]
      larva<-larva[which(larva$redcap_repeat_instrument=="larva")  , ]
      larva<-larva[order(-(grepl('date|red', names(larva)))+1L)]
      names(larva)[names(larva) == 'date_time_larva'] <- 'date_collected'

      larva$date_collected<-ymd_hm(larva$date_collected)
      class(larva$date_collected)
      larva$time_larva<-format(larva$date_collected, "%H:%M")

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
            library(beepr)
            beep(sound = 4)
            #replace "" with NA
            larva_long[larva_long==""]<-NA

            larva_long$month_year<-as.Date(larva_long$date_collected)
            larva_long$month_year<-as.yearmon(larva_long$month_year)
            larva_long$month_year<-as.Date(larva_long$month_year)
            
            larva_long$month_year_lag<-larva_long$month_year-30
            larva_long$month_year_lag<-as.yearmon(larva_long$month_year_lag)
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
        larva_in<-larva_in[order((-grepl('date_collected|redcap_event_name|redcap_repeat', names(larva_in)))+1L)]
        
        larva_in$date_house_in_out<-paste(larva_in$date_collected, larva_in$redcap_event_name, larva_in$inoutdoors_larva)
        larva_in$redcap_repeat_instance<-with(larva_in, ave(as.character(date_house_in_out), date_house_in_out, FUN = seq_along))
        larva_in$redcap_repeat_instance<-as.numeric(as.character(larva_in$redcap_repeat_instance))
        hist(larva_in$redcap_repeat_instance)
        
        
        larva_in_redcap<-larva_in
        colnames(larva_in_redcap)[colnames(larva_in_redcap)=="inoutdoors_larva"] <- "in_out_larva___1"
        larva_in_redcap<-larva_in_redcap[ , !grepl( "inoutdoors_other_larva|month_year|date_house_in_out|container_number|compound_house_id|study_site" , names(larva_in_redcap) ) ]
        
        colnames(larva_in_redcap)[colnames(larva_in_redcap)=="count"] <- "redcap_repeat_instance"
        colnames(larva_in_redcap)[colnames(larva_in_redcap)=="roomplace_larva"] <- "roomplace_larva_1_in"
        colnames(larva_in_redcap)[colnames(larva_in_redcap)=="roomplace_other_larva"] <- "roomplace_other_larva_1_in"
        colnames(larva_in_redcap)[colnames(larva_in_redcap)=="container_number"] <- "container_number_1_in"
        colnames(larva_in_redcap)[colnames(larva_in_redcap)=="aedes_species_larva"] <- "aedes_species_larva_1_in"
        colnames(larva_in_redcap)[colnames(larva_in_redcap)=="aedes_species_larva_other"] <- "aedes_species_larva_other_1_in"
        colnames(larva_in_redcap)[colnames(larva_in_redcap)=="anopheles_species_larva"] <- "anopheles_species_larva_1_in"
        colnames(larva_in_redcap)[colnames(larva_in_redcap)=="anopheles_species_larva_other"] <- "anopheles_species_larva_other_1_in"
        colnames(larva_in_redcap)[colnames(larva_in_redcap)=="early_instars_larva"] <- "early_instars_larva_1_in"
        colnames(larva_in_redcap)[colnames(larva_in_redcap)=="genus_larva"] <- "genus_larva_1_in"
        colnames(larva_in_redcap)[colnames(larva_in_redcap)=="genus_other_larva"] <- "genus_other_larva_1_in"
        colnames(larva_in_redcap)[colnames(larva_in_redcap)=="habitat_id_larva"] <- "habitat_id_larva_1_in"
        colnames(larva_in_redcap)[colnames(larva_in_redcap)=="habitat_type_other_larva"] <- "habitat_type_other_larva_1_in"
        colnames(larva_in_redcap)[colnames(larva_in_redcap)=="habitat_size_larva"] <- "habitat_size_larva_1_in"
        colnames(larva_in_redcap)[colnames(larva_in_redcap)=="habitat_type_larva"] <- "habitat_type_larva_1_in"
        colnames(larva_in_redcap)[colnames(larva_in_redcap)=="late_instars_larva"] <- "late_instars_larva_1_in"
        colnames(larva_in_redcap)[colnames(larva_in_redcap)=="pupae_larva"] <- "pupae_larva_1_in"
        
        write.csv(as.data.frame(larva_in_redcap), "larva_in_redcap.csv", na="", row.names = FALSE)
        importRecords(rcon, larva_in_redcap, overwriteBehavior = "normal", returnContent = c("count", "ids", "nothing"), returnData = FALSE, logfile = "", proj = NULL,                  batch.size = -1)
        

        larva_out <-larva_out[which(!is.na(larva_out$aedes_species_larva)|!is.na(larva_out$aedes_species_larva_other)|!is.na(larva_out$anopheles_species_larva)|!is.na(larva_out$anopheles_species_larva_other)|!is.na(larva_out$early_instars_larva)|!is.na(larva_out$genus_larva)|!is.na(larva_out$genus_other_larva)|!is.na(larva_out$habitat_id_larva)|!is.na(larva_out$habitat_size_larva)|!is.na(larva_out$habitat_type_larva)|!is.na(larva_out$habitat_type_other_larva)) , ]

            larva_out$date_house_in_out<-paste(larva_out$date_collected, larva_out$redcap_event_name, larva_out$inoutdoors_larva)
            larva_out$redcap_repeat_instance<-with(larva_out, ave(as.character(date_house_in_out), date_house_in_out, FUN = seq_along))
            larva_out$redcap_repeat_instance<-as.numeric(as.character(larva_out$redcap_repeat_instance))
            hist(larva_out$redcap_repeat_instance)

            larva_out_redcap<-larva_out
            colnames(larva_out_redcap)[colnames(larva_out_redcap)=="inoutdoors_larva"] <- "in_out_larva___2"
            larva_out_redcap <- within(larva_out_redcap, in_out_larva___2[larva_out_redcap$in_out_larva___2 ==2] <- 1)
            larva_out_redcap<-larva_out_redcap[ , !grepl( "date_house_in_out|inoutdoors_other_larva|month_year|date_house_out_out|container_number|compound_house_id|study_site" , names(larva_out_redcap) ) ]
            
            colnames(larva_out_redcap)[colnames(larva_out_redcap)=="roomplace_larva"] <- "roomplace_larva_1_out"
            colnames(larva_out_redcap)[colnames(larva_out_redcap)=="roomplace_other_larva"] <- "roomplace_other_larva_1_out"
            colnames(larva_out_redcap)[colnames(larva_out_redcap)=="container_number"] <- "container_number_1_out"
            colnames(larva_out_redcap)[colnames(larva_out_redcap)=="aedes_species_larva"] <- "aedes_species_larva_1_out"
            colnames(larva_out_redcap)[colnames(larva_out_redcap)=="aedes_species_larva_other"] <- "aedes_species_larva_other_1_out"
            colnames(larva_out_redcap)[colnames(larva_out_redcap)=="anopheles_species_larva"] <- "anopheles_species_larva_1_out"
            colnames(larva_out_redcap)[colnames(larva_out_redcap)=="anopheles_species_larva_other"] <- "anopheles_species_larva_other_1_out"
            colnames(larva_out_redcap)[colnames(larva_out_redcap)=="early_intstars_larva"] <- "early_intstars_larva_1_out"
            colnames(larva_out_redcap)[colnames(larva_out_redcap)=="genus_larva"] <- "genus_larva_1_out"
            colnames(larva_out_redcap)[colnames(larva_out_redcap)=="genus_other_larva"] <- "genus_other_larva_1_out"
            colnames(larva_out_redcap)[colnames(larva_out_redcap)=="habitat_id_larva"] <- "habitat_id_larva_1_out"
            colnames(larva_out_redcap)[colnames(larva_out_redcap)=="habitat_type_other_larva"] <- "habitat_type_other_larva_1_out"
            colnames(larva_out_redcap)[colnames(larva_out_redcap)=="habitat_size_larva"] <- "habitat_size_larva_1_out"
            colnames(larva_out_redcap)[colnames(larva_out_redcap)=="habitat_type_larva"] <- "habitat_type_larva_1_out"
            colnames(larva_out_redcap)[colnames(larva_out_redcap)=="early_instars_larva"] <- "early_instars_larva_1_out"
            colnames(larva_out_redcap)[colnames(larva_out_redcap)=="late_instars_larva"] <- "late_instars_larva_1_out"
            colnames(larva_out_redcap)[colnames(larva_out_redcap)=="pupae_larva"] <- "pupae_larva_1_out"

            larva_out_redcap<-larva_out_redcap[order((-grepl('date_collected|redcap_event_name|redcap_repeat', names(larva_out_redcap)))+1L)]
            
            write.csv(as.data.frame(larva_out_redcap), "larva_out_redcap.csv", na="", row.names = FALSE)
            
            
            # monthly summary by site: larva_long_aedes -------------------------------------------------------------
            Monthlylarva_long_aedes <- ddply(larva_long_aedes, ~month_year +study_site, summarise, 
                                             Ttl_Aedes.spp.larva = sum(larva_sum ),
                                             Ttl_Aedes.spp.larva.sd = sd(larva_sum ),
                                             Ttl_Aedes.spp.larva.mean = mean(larva_sum )
            ) 
            house.larva_long_aedes <- ddply(larva_long_aedes, ~compound_house_id+ study_site, summarise, 
                                            Ttl_Aedes.spp.larva = sum(larva_sum )) 
            
            
            Monthlylarva_long_aedes$z.Ttl_Aedes.spp.larva<-(Monthlylarva_long_aedes$Ttl_Aedes.spp.larva-Monthlylarva_long_aedes$Ttl_Aedes.spp.larva.mean)/Monthlylarva_long_aedes$Ttl_Aedes.spp.larva.sd
            hist(Monthlylarva_long_aedes$z.Ttl_Aedes.spp.larva)
            

# sum bg by month/house -----------------------------------------------------
      bg<-vector[ , grepl( "redcap_event_name|study_site|bg|repeat|house" , names(vector) ) ]
      bg<-bg[which(bg$redcap_repeat_instrument=="bg")  , ]
      bg<-bg[which(!is.na(bg$datetime_bg)|!is.na(bg$date_bg))  , ]
      
      bg<-bg[order(-(grepl('date_collected|redcap', names(bg)))+1L)]
      bg[bg==""]<-NA
      bg_redcap<-bg
      bg_redcap<-bg_redcap[ , grepl( "redcap_event_name|bg|date" , names(bg_redcap) ) ]
      colnames(bg_redcap)[colnames(bg_redcap)=="datetime_bg"] <- "date_collected"
      
      bg_redcap<-bg_redcap[ , grepl( "redcap_event_name|study_site|bg|date_collected" , names(bg_redcap) ) ]
      bg_redcap<-bg_redcap[ , !grepl( "date_bg" , names(bg_redcap) ) ]
      bg_redcap$date_collected<-as.Date(bg_redcap$date_collected)
      bg_redcap<-bg_redcap[which(!is.na(bg_redcap$date_collected))  , ]
      
      
      bg_redcap$redcap_repeat_instance<-paste(bg_redcap$date_collected, bg_redcap$redcap_event_name)
      bg_redcap$redcap_repeat_instance<-with(bg_redcap, ave(as.character(redcap_repeat_instance), redcap_repeat_instance, FUN = seq_along))
      hlc_redcapbg_redcapredcap_repeat_instance<-as.numeric(as.character(bg_redcap$redcap_repeat_instance))
      table(bg_redcap$redcap_repeat_instance)
      bg_redcap$redcap_repeat_instrument<-"bg"
      bg_redcap<-bg_redcap[order(-(grepl('redcap', names(bg_redcap)))+1L)]
      bg_redcap<-bg_redcap[order(-(grepl('date_collected', names(bg_redcap)))+1L)]
      bg_redcap$time_bg[is.na(bg_redcap$time_bg)]<-"00:00"
      bg_redcap$date_collected<-paste(bg_redcap$date_collected,bg_redcap$time_bg, sep = " ")
      write.csv(as.data.frame(bg_redcap), "bg_redcap.csv", row.names = F, na="")
      
      importRecords(rcon, bg_redcap, overwriteBehavior = "normal", returnContent = c("count", "ids", "nothing"), returnData = FALSE, logfile = "", proj = NULL, batch.size = -1)
      
      
      bg$bg_aedes_sum<-rowSums(bg[,grep("aedes_agypti_gravid_bg|aedes_agypti_half_gravid_bg|aedes_agypti_unfed_bg|aedes_agypti_bloodfed_bg", names(bg))], na.rm = TRUE)
      
    
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
                         Ttl_Aedes.spp.bg = sum(bg_aedes_sum ),
                         Ttl_Aedes.spp.bg.sd = sd(bg_aedes_sum),
                         Ttl_Aedes.spp.bg.mean = mean(bg_aedes_sum )
      ) 
      house.bg <- ddply(bg, ~compound_house_id + study_site, summarise, 
                         Ttl_Aedes.spp.bg = sum(bg_aedes_sum )) 
      
      Monthlybg$z.Ttl_Aedes.spp.bg<-(Monthlybg$Ttl_Aedes.spp.bg-Monthlybg$Ttl_Aedes.spp.bg.mean)/Monthlybg$Ttl_Aedes.spp.bg.sd
      hist(Monthlybg$z.Ttl_Aedes.spp.bg)
      
      
# sum ovi  by house  and make wide -----------------------------------------------------
      ovi<-vector[ , grepl( "redcap_event_name|study_site|ovi|repeat|house" , names(vector) ) ]
      ovi<-ovi[which(ovi$redcap_repeat_instrument=="ovitrap")  , ]
      ovi_redcap<-ovi
      ovi_redcap<-ovi_redcap[ , grepl( "redcap_event_name|ovi" , names(ovi_redcap) ) ]

      colnames(ovi_redcap)[colnames(ovi_redcap)=="date_collected_day_ovitrap"] <- "date_collected"
      ovi_redcap$date_collected<-ymd(ovi_redcap$date_collected)
      ovi_redcap$date_collected<-as.Date(ovi_redcap$date_collected)

      ovi_redcap<-ovi_redcap[which(!is.na(ovi_redcap$date_collected))  , ]
      
      
      ovi_redcap$redcap_repeat_instance<-paste(ovi_redcap$date_collected, ovi_redcap$redcap_event_name, ovi_redcap$indoors_ovitrap___1)
      ovi_redcap$redcap_repeat_instance<-with(ovi_redcap, ave(as.character(redcap_repeat_instance), redcap_repeat_instance, FUN = seq_along))
      ovi_redcap$redcap_repeat_instance<-as.numeric(as.character(ovi_redcap$redcap_repeat_instance))
      table(ovi_redcap$redcap_repeat_instance)
      ovi_redcap$redcap_repeat_instrument<-"ovitrap"
      ovi_redcap<-ovi_redcap[order(-(grepl('date_collected|redcap', names(ovi_redcap)))+1L)]
      
      importRecords(rcon, ovi_redcap, overwriteBehavior = "normal", returnContent = c("count", "ids", "nothing"), returnData = FALSE, logfile = "", proj = NULL, batch.size = -1)
      write.csv(as.data.frame(ovi_redcap), "ovi_redcap.csv", row.names = F, na="")
      
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
      ovi$egg_count_ovitrap<-ovi$egg_count_ovitrap_in+ovi$egg_count_ovitrap_out
      # monthly/house summary: ovitrap -------------------------------------------------------------
      ovi$aedes_species_ovitrap_out<-as.numeric(ovi$aedes_species_ovitrap_out)
      ovi$aedes_species_ovitrap_in<-as.numeric(ovi$aedes_species_ovitrap_in)
      MonthlyOvitrap <- ddply(ovi, ~month_year+study_site , summarise, 
                              Ttl_Aedes.spp.ovi.mean = mean(egg_count_ovitrap ),
                              Ttl_Aedes.spp.ovi.sd = sd(egg_count_ovitrap ),
                              Ttl_Aedes.spp.ovi = sum(egg_count_ovitrap),
                              Ttl_Aedes.spp.Indoor.ovi = sum(egg_count_ovitrap_in ),
                              ttl_Aedes_spp_Outdoor.ovi = sum(egg_count_ovitrap_out)
      ) 
MonthlyOvitrap$z.egg_count_ovitrap<-(MonthlyOvitrap$Ttl_Aedes.spp.ovi-MonthlyOvitrap$Ttl_Aedes.spp.ovi.mean)/MonthlyOvitrap$Ttl_Aedes.spp.ovi.sd
hist(MonthlyOvitrap$z.egg_count_ovitrap)

      house.Ovitrap <- ddply(ovi, ~compound_house_id + study_site , summarise, 
                             Ttl_Aedes.spp.Indoor.ovi = sum(egg_count_ovitrap_in ),
                             ttl_Aedes_spp_Outdoor.ovi = sum(egg_count_ovitrap_out)) 
      

                             
# sum hlc by house  and make wide -----------------------------------------------------
      hlc<-vector[ , grepl( "redcap_event_name|study_site|hlc|repeat|house" , names(vector) ) ]
      hlc<-hlc[which(hlc$redcap_repeat_instrument=="hlc")  , ]
      hlc[hlc==""]<-NA
      hlc<-hlc[which(!is.na(hlc$date_hlc))  , ]
      
      hlc_redcap<-hlc
      hlc_redcap<-hlc_redcap[ , grepl( "redcap_event_name|hlc" , names(hlc_redcap) ) ]
      
      colnames(hlc_redcap)[colnames(hlc_redcap)=="date_hlc"] <- "date_collected"
      
      hlc_redcap$date_collected<-ymd(hlc_redcap$date_collected)
      hlc_redcap$date_collected<-as.Date(hlc_redcap$date_collected)
      
      hlc_redcap<-hlc_redcap[which(!is.na(hlc_redcap$date_collected))  , ]
      
      

      hlc_redcap$redcap_repeat_instance<-paste(hlc_redcap$date_collected, hlc_redcap$redcap_event_name)
      hlc_redcap$redcap_repeat_instance<-with(hlc_redcap, ave(as.character(redcap_repeat_instance), redcap_repeat_instance, FUN = seq_along))
      hlc_redcap$redcap_repeat_instance<-as.numeric(as.character(hlc_redcap$redcap_repeat_instance))
      table(hlc_redcap$redcap_repeat_instance)
      hlc_redcap$redcap_repeat_instrument<-"hlc"

      hlc_redcap<-hlc_redcap[order(-(grepl('date_collected|redcap', names(hlc_redcap)))+1L)]
      
      write.csv(as.data.frame(hlc_redcap), "hlc_redcap.csv", row.names = F, na="")
      
      importRecords(rcon, hlc_redcap, overwriteBehavior = "normal", returnContent = c("count", "ids", "nothing"), returnData = FALSE, logfile = "", proj = NULL, batch.size = -1)
      
      hlc$hlc_aedes_sum<-rowSums(hlc[,grep("aedes_agypti_half_gravid_hlc|aedes_agypti_unfed_hlc|aedes_agypti_bloodfed_hlc|aedes_agypti_gravid_hlc", names(hlc))], na.rm = TRUE)
      
      hlc$date_hlc<-as.Date(hlc$date_hlc)
      hlc$month_year_lag<-hlc$date_hlc-30

      hlc$month_year<-as.yearmon(hlc$date_hlc)
      hlc$month_year_lag<-as.yearmon(hlc$month_year_lag)
      hlc$month_year<-as.Date(hlc$month_year)
      hlc$month_year_lag<-as.Date(hlc$month_year_lag)
      
      # monthly summary by site: hlc -------------------------------------------------------------
      Monthlyhlc <- ddply(hlc, ~month_year +study_site , summarise, 
                           Ttl_Aedes.spp.hlc = sum(hlc_aedes_sum ),
                          Ttl_Aedes.spp.hlc.mean = mean(hlc_aedes_sum ),
                          Ttl_Aedes.spp.hlc.sd = sd(hlc_aedes_sum )
      )  
      house.hlc <- ddply(hlc, ~compound_house_id + study_site, summarise, 
                          Ttl_Aedes.spp.hlc = sum(hlc_aedes_sum ))  
      
      Monthlyhlc$z.Ttl_Aedes.spp.hlc<-(Monthlyhlc$Ttl_Aedes.spp.hlc-Monthlyhlc$Ttl_Aedes.spp.hlc.mean)/Monthlyhlc$Ttl_Aedes.spp.hlc.sd
      hist(Monthlyhlc$z.Ttl_Aedes.spp.hlc)
      
# merge the trap types by site/month-------------------------------------------------
      Monthlyvector<-merge(MonthlyOvitrap, Monthlybg, by = c("month_year", "study_site"), all = TRUE)
      Monthlyvector<-merge(Monthlyvector, Monthlyprokopack, by = c("month_year", "study_site"), all = TRUE)
      Monthlyvector<-merge(Monthlyvector, Monthlyhlc, by = c("month_year", "study_site"), all = TRUE)
      Monthlyvector<-merge(Monthlyvector, Monthlylarva_long_aedes, by = c("month_year", "study_site"), all = TRUE)
      
    table(Monthlyvector$study_site, exclude=NULL)      
# save Monthlyvector data -------------------------------------------------------------
      save(Monthlyvector,file="Monthlyvector.rda")
    load("Monthlyvector.rda")
    
    # merge the trap types by house-------------------------------------------------
    house.vector<-house.Ovitrap
    house.vector<-merge(house.vector, house.bg, by = c("compound_house_id","study_site"), all = TRUE)
    house.vector<-merge(house.vector, house.prokopack, by = c("compound_house_id","study_site"), all = TRUE)
    house.vector<-merge(house.vector, house.hlc, by = c("compound_house_id","study_site"), all = TRUE)
    house.vector<-merge(house.vector, house.larva_long_aedes, by = c("compound_house_id","study_site"), all = TRUE)
    house.vector<-merge(house.vector, gps, by = c("compound_house_id","study_site"), all = TRUE)
    
    house.vector<-merge(house.vector, house_first, by = c("compound_house_id" ,"study_site"),all.x=TRUE)
    View(house.vector)
    
    house.vector <-house.vector[which(!is.na(house.vector$Ttl_Aedes.spp.Indoor.ovi)|!is.na(house.vector$ttl_Aedes_spp_Outdoor.ovi)|!is.na(house.vector$Ttl_Aedes.spp.bg)|!is.na(house.vector$Ttl_Aedes.spp_in.proko)|!is.na(house.vector$Ttl_Aedes.spp_out.proko)|!is.na(house.vector$Ttl_Aedes.spp.hlc)|!is.na(house.vector$Ttl_Aedes.spp.larva)), ]
    house.vector[, 3:9][is.na(house.vector[, 3:9])] <- 0
    
    table(house.vector$study_site, exclude = NULL)
    
# gps ---------------------------------------------------------------------
    house.vector <-house.vector[which(!is.na(house.vector$latitude)&!is.na(house.vector$longitude)), ]
    house.vector <-house.vector[which(house.vector$compound_house_id!="2002"), ]#exclude for now.
    write.csv(as.data.frame(house.vector), "house.vector.gps.csv")
    
    library(sp)
    coordinates(house.vector) <- ~longitude + latitude
    
    
    require(raster)
    projection(house.vector) = "+proj=utm +zone=37 +datum=WGS84" # WGS84 coords

    names(house.vector) <- gsub("Indoor", "in", names(house.vector))
    names(house.vector) <- gsub("indoor", "in", names(house.vector))
    names(house.vector) <- gsub("Ttl_Aedes.spp", "a", names(house.vector))
    names(house.vector) <- gsub("ttl_Aedes_spp", "a", names(house.vector))
    names(house.vector) <- gsub("Outdoor", "out", names(house.vector))
# add buffer --------------------------------------------------------------
#install.packages("rgeos")
library("rgeos")
    distInMeters <- 100#add buffer.
    house.vector1km <- gBuffer( house.vector, width=1*distInMeters, byid=TRUE )#add buffer.
    
    house.vector1km.u <-house.vector1km[which(house.vector1km$study_site==1), ]
    house.vector1km.m <-house.vector1km[which(house.vector1km$study_site==2), ]
    house.vector1km.c <-house.vector1km[which(house.vector1km$study_site==3), ]
    house.vector1km.k <-house.vector1km[which(house.vector1km$study_site==4), ]
    
    table(house.vector1km.c$a.in.ovi)
    
    shapefile(house.vector1km.k, "house.vector1km.k.shp", overwrite=TRUE)#with buffer.
    shapefile(house.vector1km.u, "house.vector1km.u.shp", overwrite=TRUE)#with buffer.
    shapefile(house.vector1km.c, "house.vector1km.c.shp", overwrite=TRUE)#with buffer.
    shapefile(house.vector1km.m, "house.vector1km.m.shp", overwrite=TRUE)#with buffer.
    table(house.vector1km.m$compound_house_id)
    
# plot by house -----------------------------------------------------------


    shapefile(house.vector, "house.vector.shp", overwrite=TRUE)#without buffer.


    
    house.vector.u <-house.vector[which(house.vector$study_site==1), ]
    house.vector.m <-house.vector[which(house.vector$study_site==2), ]
    house.vector.c <-house.vector[which(house.vector$study_site==3), ]
    house.vector.k <-house.vector[which(house.vector$study_site==4), ]
    
    #house.vector.k <-house.vector.k[which(house.vector.k$compound_house_id!=1146), ]
    #house.vector.k <-house.vector.k[which(house.vector.k$village_estate.x==13), ]
    #house.vector.k <-house.vector.k[which(house.vector.k$village_estate.x<13), ]
    #spplot(house.vector.knot13, "village_estate.x", do.log=T, main = "Kisumu",key.space = "right", cuts = 7)
    #spplot(house.vector.not13, "compound_house_id", do.log=T, main = "Kisumu",key.space = "right")
    
    library(rgdal)
    library(sp)
    library(classInt)
    text1 = list("sp.text", c(178600,333090), "0")
    text2 = list("sp.text", c(179100,333090), "500 m")
    scale = list("SpatialPolygonsRescale", layout.scale.bar(), offset = c(178600,332990), scale = 500, fill=c("transparent","black"))
    arrow = list("SpatialPolygonsRescale", layout.north.arrow(), offset = c(178750,332500), scale = 400)
    plot.vector.u<-spplot(house.vector.u, c("ad.in.ovi","ad_out.ovi","ad.bg","ad_in.proko","ad_out.proko","ad.hlc","ad.larva"), do.log=T, main = "Ukunda", sub = "", 
                          key.space = "right", as.table = TRUE, cuts = c(1,10,100,1000,10000), sp.layout=list(scale,text1,text2,arrow))
    plot.vector.m<-spplot(house.vector.m, c("ad.in.ovi","ad_out.ovi","ad.bg","ad_in.proko","ad_out.proko","ad.hlc","ad.larva"), do.log=T, main = "Msambweni", sub = "", 
                          key.space = "right", as.table = TRUE, cuts = c(1,10,100,1000,10000), sp.layout=list(scale,text1,text2,arrow))
    
    plot.vector.c<-spplot(house.vector.c, c("ad.in.ovi","ad_out.ovi","ad.bg","ad_in.proko","ad_out.proko","ad.hlc","ad.larva"), do.log=T, main = "Chulaimbo", sub = "", 
                          key.space = "right", as.table = TRUE, cuts = c(1,10,100,1000,10000), sp.layout=list(scale,text1,text2,arrow))
    
    plot.vector.k<-spplot(house.vector.k, c("ad.in.ovi","ad_out.ovi","ad.bg","ad_in.proko","ad_out.proko","ad.hlc","ad.larva"), do.log=T, main = "Kisumu", sub = "", 
                          key.space = "right", as.table = TRUE, cuts = c(1,10,100,1000,10000), sp.layout=list(scale,text1,text2,arrow))
    
    
    library(gridExtra)
    grid.arrange(plot.vector.u,plot.vector.m,plot.vector.c,plot.vector.k, top = "Total Aedes Mosquito count 2014-2017", bottom = "Source: LaBeaud et.al.")
    
    
    
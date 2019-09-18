ds2$zikv_exposed_mom<-NA
ds2 <- within(ds2, zikv_exposed_mom[ds2$result_zikv_igg_pgold.mom=="Negative"|ds2$result_zikv_igg_pgold_fu.mom=="Negative"] <- "mom_zikv_Unexposed_during_pregnancy")
ds2 <- within(ds2, zikv_exposed_mom[ds2$pcr_positive_zikv_mom=="Positive"|ds2$result_zikv_igg_pgold.mom=="Positive"|ds2$result_zikv_igg_pgold_fu.mom=="Positive"] <- "mom_ZIKV_Exposed_during_pregnancy")

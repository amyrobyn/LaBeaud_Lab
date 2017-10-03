library("DiagrammeR")#install.packages("DiagrammeR")
aic_n
afi
denv_acute

denv_tested_malaria_tested
denv_not_tested_malaria_not_tested
denv_not_tested_malaria_tested
denv_tested_malaria_not_tested

n_events_tested
n_subjects_tested

denv_pos_malaria_neg 
denv_pos_malaria_pos 
denv_neg_malaria_neg 
denv_neg_malaria_pos 


denv_pos_pf_neg
denv_pos_pf_pos
denv_neg_pf_neg
denv_neg_pf_pos

grViz("
      digraph boxes_and_circles{
      graph[nodesep=2]
      node[shape = oval; color = black; fontsize = 100; fontname=arial; fontcolor=black; penwidth = 6; arrowshape=normal]
      edge[penwidth = 6; arrowhead=normal; arrowsize =4; minlen=4]

      #N
      Unique_subjects ->1992
      #total events (afi)
        1992->Acute_febrile_visits->2713

      #tested events
        2713->tested_DENV_no_malaria; 2713->tested_malaria_no_DENV; 2713->tested_malaria_AND_DENV; 2713->tested_neither
        tested_DENV_no_malaria->52;tested_malaria_AND_DENV->1772; tested_malaria_no_DENV->351; tested_neither->538
        1772->tested_malaria_species_DENV
        tested_malaria_species_DENV->1213
  
    #results malaria
        1772->neither; 1772->malaria_no_DENV; 1772->DENV_no_malaria; 1772->malaria_DENV_coinfection
        neither->662;malaria_no_DENV->877; DENV_no_malaria->40 ; malaria_DENV_coinfection->46
      
      #results pf
        1213->pf_DENV;1213->pf_no_DENV; 1213->DENV_no_pf; 1213->neither_DENV_Pf
        pf_DENV->25;pf_no_DENV->683; DENV_no_pf->21; neither_DENV_Pf->484
      }")
        

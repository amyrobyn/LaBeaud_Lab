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


denv_pf_tested_events
denv_pos_pf_neg
denv_pos_pf_pos
denv_neg_pf_neg
denv_neg_pf_pos

grViz("
      digraph boxes_and_circles{
      graph[nodesep=2]
      node[shape = oval; color = black; fontsize = 100; fontname=arial; fontcolor=black; penwidth = 6; arrowshape=normal]
      edge[penwidth = 6; arrowhead=normal; arrowsize =4; minlen=4]


      #tested events
        2713->tested_DENV_no_malaria; 2713->tested_malaria_no_DENV;  2713->tested_neither
        tested_DENV_no_malaria->52; tested_malaria_no_DENV->351; tested_neither->538


    #results malaria
        1772->denv_neg_malaria_neg; 1772->denv_pos_malaria_neg; 1772->denv_neg_malaria_pos; 
        denv_neg_malaria_neg->691;denv_pos_malaria_neg->56; denv_neg_malaria_pos->962 ; 


      #results pf
        1291->denv_pos_pf_neg; 1291->denv_neg_pf_neg; 1291->denv_neg_pf_pos
        denv_pos_pf_neg->35; denv_neg_pf_neg->497; denv_neg_pf_pos->719

        graph[nodesep=2]
        node[shape = oval; color = red; fontsize = 100; fontname=arial; fontcolor=red; penwidth = 6; arrowshape=normal]
        edge[penwidth = 6; arrowhead=normal; arrowsize =4; minlen=4, color = red]
          #N
          Unique_subjects ->1992
          #total events
          1992->Acute_febrile_visits->2713
          2713->tested_malaria_AND_DENV->1772

          denv_pos_malaria_pos->63
          1772->denv_pos_malaria_pos
        1772->tested_malaria_species_DENV

          tested_malaria_species_DENV->1291
          1291->denv_pos_pf_pos
          
          denv_pos_pf_pos->40
      }")
        

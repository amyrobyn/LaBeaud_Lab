library("DiagrammeR")#install.packages("DiagrammeR")
afi

grViz("
      digraph boxes_and_circles{
      graph[nodesep=2]
      node[shape = oval; color = black; fontsize = 100; fontname=arial; fontcolor=black; penwidth = 6; arrowshape=normal]
      edge[penwidth = 6; arrowhead=normal; arrowsize =4; minlen=4]

      #total events (afi)
        Acute_febrile_visits->2713

      #tested events
        2713->tested_DENV_no_malaria; 2713->tested_malaria_no_DENV; 2713->tested_malaria_AND_DENV; 2713->tested_neither
        tested_DENV_no_malaria->166;tested_malaria_AND_DENV->1625; tested_malaria_no_DENV->321; tested_neither->582
        1625->tested_malaria_species_DENV
        tested_malaria_species_DENV->1213
  
    #results malaria
        1625->neither; 1625->malaria_no_DENV; 1625->DENV_no_malaria; 1625->malaria_DENV_coinfection
        neither->662;malaria_no_DENV->877; DENV_no_malaria->40 ; malaria_DENV_coinfection->46
      
      #results pf
        1213->pf_DENV;1213->pf_no_DENV; 1213->DENV_no_pf; 1213->neither_DENV_Pf
        pf_DENV->25;pf_no_DENV->683; DENV_no_pf->21; neither_DENV_Pf->484
      }")
        

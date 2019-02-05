library("DiagrammeR")#install.packages("DiagrammeR")
# flow chart of subjects --------------------------------------------------
flow_chart<-mermaid("
                      graph TB;
A(718 Mother-child dyads)-->B(CHIKV ELISA results from 485 dyads)
A(718 Mother-child dyads)-->C(233 NA)
B(CHIKV ELISA results from 485 dyads)-->H(19 infants CHIKV+ <br> 3.9%)
B(CHIKV ELISA results from 485 dyads)-->J(469 infants CHIKV- <br> 96.1%)
B(CHIKV ELISA results from 485 dyads)-->D(394 mothers CHIKV+ <br>80.6%)
B(CHIKV ELISA results from 485 dyads)-->E(95 mothers CHIKV- <br>19.4%)
D(394 mothers CHIKV+ <br>80.6%)-->F(181 women <br> reported illness during pregnancy)
F(181 women <br> reported illness during pregnancy)-->G(9 of 181 infants tested positive for CHIKV<br>5%)
H(19 of 488 infants CHIKV+ <br> 3.9%)-->G(9 of 181 infants tested positive for CHIKV<br>5%)
E(95 mothers CHIKV- <br>19.4%)-->I(7 infants CHIKV+ with mother CHIKV- <br>1.4%<br> Likely mosquito infection)
H(19 infants CHIKV+ <br> 3.9%)-->I(7 infants CHIKV+ with mother CHIKV- <br>1.4%<br> Likely mosquito infection)
F(181 women <br> reported illness during pregnancy)-->K(1 mother ill during delivery)
J(469 infants CHIKV- <br> 96.1%)-->K(1 mother ill during delivery)        
style A font-family: Arial, fontsize: 140px, fill:white;
style B font-family: Arial, fontsize: 140px, fill:white
style C font-family: Arial, fontsize: 140px, fill:white;
style D font-family: Arial, fontsize: 140px, fill:white
style D font-family: Arial, fontsize: 140px, fill:white;
style E font-family: Arial, fontsize: 140px, fill:white
style F font-family: Arial, fontsize: 140px, fill:white;
style G font-family: Arial, fontsize: 140px, fill:white;
style H font-family: Arial, fontsize: 140px, fill:white; 
style I font-family: Arial, fontsize: 140px, fill:white; 
style J font-family: Arial, fontsize: 140px, fill:white; 
style K font-family: Arial, fontsize: 140px, fill:white; 
                      ")
flow_chart
library(htmlwidgets)
saveWidget(flow_chart, 'diagram.html')
cat('<iframe src="diagram.html" width=100% height=100% allowtransparency="true" style="background: #FFCCFF;"> </iframe>')

class(flow_chart)
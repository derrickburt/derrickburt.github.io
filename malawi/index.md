# Exploring Reproducibility and Replicability: Attempting to Reproduce Methodology of Vulnerability Analysis

### Background

Reproducibility and replicability of scientific research is becoming more widely recognized as an essential component of a robust scientific method in academic research. The National Academies of Sciences, Engineering, and Medicine defines and differenaties the two as such: *reproducibility* aims to obtain the same results by using the same input data and methodology while *replicability* aims to answer the same question using different different data and similar methodologies (2019). Adopting these processes in scientific research not only allows for a greater scrutiny of one's methodology but opens up new avenues of communication and transparency between researchers. Reproduciblity and replicabiltiy are instric to an open-science that not only allows for self-correction but sees it as beneficial to the scentific community as a whole (Sui 2014).

Applying these practices to climate change vulnerability research can be complicated by the confusion that surrounds vulnerability as a theoretical concept. Climate vulnerability is highly complex, contextual, and place-specific which makes it difficult to scale or replicate (Hinkel 2010). As a result of this, it is difficult for researchers and policy makers to agree upon a central, uniform approach to studying climmate vulnerability. Defining vulnerability not as an observable event but instead as a theoretical framework, Hinkel identifies the importance of developing an 'operational definition,' or a framing methodology, of any given vulernability analysis (2010). Using this framework, Hinkel encourages a critical engagement and interrogation of the methodological approaches used in vulnerability analyses.

### Purpose

The goal of this exercise is to reproduce and evaluate the methodologies Malcomb et al. has used to define and visualize climate vulnerability in Malawi. First, we will examine the methodology of Malcomb et al.'s analysis and use it to reproduce [Figure 4](photos/MalcombFig4/png) and [Figure 5](photos/MalcombFig5.png) from the research paper. Then, we will reflect upon the authors' methodological approach, bringing in literature on vulnerability analysis.

### Software

The following softwares were used to complete this exercise:

* [QGIS 3.10](https://qgis.org/en/site/forusers/download.html)
* [PostgreSQL with PGAdmin 4 v4.26](https://www.pgadmin.org/download/pgadmin-4-macos/)
* [RStudio](https://rstudio.com/products/rstudio/download/)

### Malcomb et al. Methodology for Household Resilience in Malawi

#### Goal

In their paper, Malcomb, Weaver, and Krakowka outline a new approach to modelling climate vulnerability in sub-Saharan Africa. Their vulnerability model employs a 'multi-scale, multi-indicator' approach to household-level climate vulnerability with the goal of providing both local actors and policy makers the ability to identify high risk areas and possibly solutions. They claim that their approach is both scalable and flexible so that it can be employed by other countries within sub-Saharan Africa. 

#### Methodology

Malcomb et al. use a multi-criteria weighted analysis to analyze and visualize social, economic, cultural, and environmental [vulnerability indicators](photos/indicators.png). These vulnerability indicators were divided into three sub-categories: adaptive capacity (composed of both assets and access), livelihood sensitivity, and physical exposure. Each of these vulnerability indicators were rescaled into quintiles: a 0 (worst) to 5 (best) scoring system. The author's used the following weighting scheme to produce a household resilience score for each Traditional Authority (TA: the scale of analysis, an administrative boundary just below districts): *Household Resilence = Adaptive Capacity(.4) + Livelihood Sensitivity(.2) + Physical Exposure (.2)*. 

<p align="center">
  <img height="600" src="photos/malcombMethodology.png">
  </p>

### Reproducing Malcomb's Methodology and Figures

#### Data

### Results

### Discussion

### Resources

Hinkel, J. (2011). “Indicators of vulnerability and adaptive capacity”: towards a clarification of the science–policy interface. Global Environmental Change, 21(1), 198-208. https://doi.org/10.1016/j.gloenvcha.2010.08.002

Malcomb, D. W., Weaver, E. A., & Krakowka, A. R. (2014). Vulnerability modeling for sub-Saharan Africa: An operationalized approach in Malawi. Applied geography, 48, 17-30. https://doi.org/10.1016/j.apgeog.2014.01.004

National Academies of Sciences, Engineering, and Medicine. 2019. Reproducibility and Replicability in Science. Washington, DC: The National Academies Press. doi: https://doi.org/10.17226/25303.

Sui, D. 2014. Opportunities and impediments for Open GIS. *Transactions in GIS,* 18(1); 1-24. doi: 10.1111/tgis.12075

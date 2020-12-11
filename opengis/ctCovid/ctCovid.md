# Reproducing CyberGISX Analysis: Rapidly Measuring Spatial Accesibility of COVID-19 Healthcare in Connecticut

### About 

In their paper, "Rapidly Measuring Spatial Accessibility of COVID-19 Healthcare Resources: A Case Study of Illinois, USA", Kang et al. implement a methodology that measures and visualizes the access that two different populations, COVID-19 patients and the population risk (defined as those over 50), have to two important resources, ICU beds and Ventilators. 

To rapidly measure accessibiity to Covid-19 healthcare, Kang et al. developed a methodology for [parallel implementation](https://www.omnisci.com/technical-glossary/parallel-computing#:~:text=Parallel%20computing%20refers%20to%20the,part%20of%20an%20overall%20algorithm.) of an Enhanced Two-Step Floating Catchment Area (E2FSCA) methodology. This method calculates the ratio between a service (in this scenario, hospital ICU beds or ventilators) and a population with a surrounding area, accounting for distance decay. Because this is a computationally intensive analysis hat uses large street networks, the authors developed a parallel-E2FSCA (P-E2FSCA), which enables the use of up to 4 processors while implementing the analysis.

The following resources document their methodology, data, and results:
* [Paper](Paper/Kang_spatialAccessibilityCovid.pdf): an overview of the problem, description of and conceptual methodology, results, and conclusion
* [Jupyter Notebook](https://cybergisxhub.cigi.illinois.edu/notebook/rapidly-measuring-spatial-accessibility-of-covid-19-healthcare-resources-a-case-study-of-illinois-usa/): a reproducible implementation of the paper's methodology (requires a [CyberGISX](https://cybergisxhub.cigi.illinois.edu/registration/) account)
* [Github Repository](https://github.com/cybergis/COVID-19AccessibilityNotebook): has the notebook and all the necessary data
* [Where COVID-19 Spatial Access Dashboard](https://wherecovid19.cigi.illinois.edu/spatialAccess.html): A live dashboard that displays the daily accessibility calculated from this methodology

### Purpose


A quick note on the accessibility of reproducing 

### Software

### Kang et al. Methodology

### Replicating the Notebook for Connecticut

#### Data

#### Preparing the Data

#### Altering the Notebook

### Results

### Conclusion

### Resources

# Cell-to-cell-Heterogeneity

 *Translate raw imaging data into statistical analysis of cell-to-cell heterogeneity of a cellular population*

## Biological background

Cells are located in a dynamically changing environment characterized by spatio-temporel gradients of signaling molecules and physico-chemical constraints. Therefore, cells exhibit dramatically different shapes and metabolic activities. A striking example of the shape diversity of cells is for instance the dendritic arborization of neurons. Like trees, no one is the same as the others.
In this work, we have investigated if non-neuronal cells called astrocytes produce cellular energy (ATP or Adenosine TriPhosphate) using the same metabolic pathway. For simplification, we considered only two of the most important metabolic pathways producing energy in cells: glycolysis and mitochondrial oxydative metabolism. Therefore, we addressed if in a population of astrocytes, they all produce energy using the same metabolic pathway:

![Fig. 1](Figure_1.jpeg)
**Figure 1**: Rationale of the cell-to-cell heterogeneity study.

## Methods

For this purpose, we monitored using fluorescence microspy several metabolic parameters in intact living astrocytes in several fields of view (**Fig. 2A**) challenged by the transient stimulation by a molecule released by excitatory neurons (**Fig.2B**). An automated image analysis pipeline enabled for the time-resolved quantification of energy metabolism parameters at the single-cell level (**Fig.2C**). 

![Fig. 2](Figure_2.jpeg)
**Figure 2**: (A) Up to six fields of view are monitored per field of view, corresponding 250 to 1000 astrocytes per experiment. (B) Summary of experimental settings to evaluate the effect of glutamate on energy metabolism in cultured astrocytes. The same protocol was used for all experiments: after a baseline recording, astrocytes were stimulated 2min with Glutamate 200µM and recovering was monitored. The parameter-specific normalisation condition was then applied. (C) Analysis pipeline to infer sorted calibrated intensity plots from raw image data. For data visualisation, cells are sorted according to basal value (y axis) and the normalised intensity is color-coded and displayed along the time (x axis).

![Fig. 3](Figure_3.jpeg)
**Figure 3**: (A) Representation of relative ATP level measured using the Magnesium Green method and using metabolic inhibitor as a normalizing condition. (B) Color-coded representation of single cell dynamics. (C) Representative experiment and (D) whole dataset representation of variability index (interquartile range).


## Results

We found that, at resting state, astrocytes are heterogeneous in cellular ATP level, mitochondrial electrical potential and mitochondrial reactive oxygen species (ROS) concentration. A transient stimulation of astrocytes with the neurotransmitter glutamate induced a change in the variability in energy metabolism, characterized by a persistent, calcium-independent, decrease in the variability of cellular ATP level (**Fig. 3**), mitochondrial electrical potential and mitochondrial ROS concentration.

## Outlook

Glutamate was found to statistically decrease the variability in energy metabolism in astrocytes in vitro.
Together, our results suggest that astrocytes organize in clusters of metabolically heterogeneous cells, thereby generating an apparent stochasticity in the energy metabolism that can be regulated by the neurotransmitter glutamate. We speculate that the change in metabolic heterogeneity aims to prime the surrounding astrocytes to support more rapidly a next neuronal activity.

## Code


## Acknowledgments

Haissa de Castro Abrantes (University of Lausanne) has prepared and maintained the culture of mouse cortical astrocytes. Critical inputs on the experimental design of the study were provided by Bruno Weber (University of Zurich) and Jean-Yves Chatton (University of Lausanne). This work was supported by SystemsX.ch.

For more information on the project, please contact Guillaume Azarias (guillaume.azarias@hotmail.com)
# Cell-to-cell-Heterogeneity

 *Translate raw imaging data into statistical analysis of cell-to-cell heterogeneity of a cellular population*
 
## Biological background

Cells are located in a dynamically changing environment characterized by spatio-temporel gradients of signaling molecules and physico-chemical constraints. Therefore, cells exhibit dramatically different shapes and metabolic activities. A striking example of the shape diversity of cells is for instance the dendritic arborization of neurons. Like trees, no one is the same as the others.

In this work, we have investigated if non-neuronal cells called astrocytes produce cellular energy ([ATP](https://en.wikipedia.org/wiki/Adenosine_triphosphate) or Adenosine TriPhosphate) using the same metabolic pathways. For simplification, we considered only two of the most important metabolic pathways producing energy in cells: [glycolysis](https://en.wikipedia.org/wiki/Glycolysis) and [mitochondrial oxydative phosphorylation](https://en.wikipedia.org/wiki/Oxidative_phosphorylation). Therefore, we addressed if in a population of astrocytes, they all produce energy using the same metabolic pathways:

![Fig. 1](Figure_1.jpeg)
**Figure 1**: Rationale of the cell-to-cell heterogeneity study.

## Methods

*Foreword: The goal of this repository is to illustrate how to convert raw imaging data, containing hundreds of cells, into calibrated data that can be statistically studied. The biological relevance is only briefly discussed.*

We monitored, using widefield fluorescence microscopy, several metabolic parameters in intact living astrocytes in several fields of view (**Fig. 2A**) and challenged by a transient stimulation using Glutamate, a molecule released by most of the excitatory neurons (**Fig.2B**). To identify and normalize or calibrate individual individual, you need to acquire at least two channels: 1) The fluorescence biosensor channel(s) and 2) A spectrally separable probe for the nuclei (in this study, we used a far-red dye for living cells). In addition, we used a parameter specific normalisation condition to be able to compare cells between each other.

![Fig. 2](Figure_2.jpeg)
**Figure 2**: (**A**) Up to six fields of view are monitored per field of view, corresponding 250 to 1000 astrocytes per experiment. (**B**) Summary of experimental settings to evaluate the effect of glutamate on energy metabolism in cultured astrocytes. The same protocol was used for all experiments: after a baseline recording, astrocytes were stimulated 2min with Glutamate (200µM) and recovering was monitored. The parameter-specific normalisation condition was then applied.

## Results
### Summary

We found that, at resting state, astrocytes are heterogeneous in cellular ATP level, mitochondrial electrical potential and mitochondrial reactive oxygen species (ROS) concentration. A transient stimulation of astrocytes with the neurotransmitter glutamate induced a change in the variability in energy metabolism, characterized by a persistent, calcium-independent, decrease in the variability of cellular ATP level (**Fig. 3** and **4**), mitochondrial electrical potential (**Fig. 5**) and mitochondrial ROS concentration (**Fig. 6**).

### Glutamate decreases the variability in cellular ATP content

![Fig. 3](Figure_3.jpeg)
**Figure 3**: (**A**) Representation of relative ATP level measured using the Magnesium Green method and using metabolic inhibitor as a normalizing condition. (**B**) Color-coded representation of single cell dynamics. (**C**) Representative experiment and (**D**) whole dataset representation of variability index (interquartile range).

### Glutamate does not decrease the variability in cytosolic calcium concentration

![Fig. 4](Figure_4.jpeg)
**Figure 4**: (**A**) Representation of the normalized ATP level and cytosolic calcium concentration measured using the Magnesium Green method imaged in cells simultaneously labeled with Fura-2. (**B**) Color-coded representation and (**B’**) cross correlation coefficients of single cell dynamics. (**C**) Representative experiment and (D) whole dataset representation of variability index.

### Glutamate decreases the variability in mitochondrial electrical potential

![Fig. 5](Figure_5.jpeg)
**Figure 5**: (**5**) Representation of mitochondrial electrical potential measured using the Rhodamine 123 chemical dye and using the mitochondrial uncoupler as a normalizing condition. (**B**) Color-coded representation of single cell dynamic. (**C**) Representative experiment and (**D**) whole dataset representation of variability index. In our dataset, glutamate did not systematically lead to a significant decrease in cell-to-cell variability.

### Glutamate decreases the variability in mitochondrial Reactive Oxygen Species concentration

![Fig. 6](Figure_6.jpeg)
**Figure 6**: (**A**) Representation of mitochondrial ROS concentration level measured using mito-roGFP2-Orp1 and using metabolic inhibitor as a normalizing condition. (**B**) Color-coded representation of single cell dynamics. (**C**) Representative experiment and (**D**) whole dataset representation of variability index.

## Outlook

Glutamate was found to statistically decrease the variability in energy metabolism in astrocytes *in vitro*.
Together, our results suggest that astrocytes organize in clusters of metabolically heterogeneous cells, thereby generating an apparent stochasticity in the energy metabolism that can be regulated by the neurotransmitter glutamate. An attracting hypothesis from this work would be that the change in metabolic heterogeneity aims to prime the surrounding astrocytes to support more rapidly a next neuronal activity.

## Code

### Workflow

The Figure 7 illustrates the analysis pipeline to infer sorted calibrated intensity plots from raw image data. For data visualisation, cells are sorted according to basal value (y axis) and the normalised intensity is color-coded and displayed along the time (x axis).

![Fig. 7](Figure_7.jpeg)
**Figure 7**: Analysis pipeline to convert raw imaging data into single-cell calibrated time-series data.

### Prerequisites

Data format: The imaging data were stored as tif files
Data names: Make sure that your data names contain *two-digits numbers* to allow for time series analysis.
Software: The macros were developed on [Fiji](https://fiji.sc/) (version 2.0.0-rc69/1.52p), [CellProfiler](https://cellprofiler.org/) (version 2.2.0) and [MATLAB](https://www.mathworks.com/products/matlab.html) (version 2017a).

### Processing Macros

You find them in Cell-to-cell-Heterogeneity/Macros/

#### 1 - High quality images for segmentation (Fiji / ImageJ)
![a_High_Quality_Image](a_High_Quality_Image.jpeg)

- Input: Image series of baseline recording (normalized names) and fluorescence background images

- Processing steps:
	- Background subtraction
	- Motion correction
	- z-stack of fluorescent dye

- Output: Single high quality image for cell segmentation

- Example:
![a_High_Quality_Image_example](a_High_Quality_Image_example.jpeg)
*Example of segmentation result: Single image (left) and  high quality image (right)*

#### 2 - Cell segmentation (CellProfiler)
![b_Cell Segmentation](b_Cell_Segmentation.jpeg)

- Input: Single high quality image + nuclear staining image

- Processing steps: Segmentation of high quality image based on nuclear staining. Note that you have to adapt the detection parameter to your own data.

- Output: Segmented cells coordinates

- Example:
![Cell Segmentation Result](b_Cell_Segmentation_example.jpeg)
*Example of segmentation result: Original high quality image (left) and cell segmentation results in arbitrary colors (right)*

#### 3 - Generation of composite stacks (Fiji / ImageJ)
![gui Calibration](c_Calibration_and_Composite.jpeg)

- Input: Image series of raw data (time point of normalization step)

- Processing steps:
	- Motion correction (*optional*)
	- Generation of a mask from the cell segmentation result
	- Calculation of pixel values according to the image processing mode:
        * Calibration according to known pixel values (0 and 20µM of H2O2)
        * Normalization to a specific condition (examples: no ATP level, no mitochondrial electrical potential)
        * Ratio between two images
	- Filtering of pixels of aberrant value (user-defined using a live graphical user interface)
	- Generation of a stack containing the normalized data and cell coordinates

- Two outputs:
	- Composite stack containing the raw image in the red channel and cell segmentation results and in the green channel. The pixel values are the same as the raw images, since the single-cell calibration will be processed later in Matlab.
	- Stack of calibrated cells for data exploration. The pixel value is calibrated according to the lower and higher calibration points. In the example below, a region of interest was drawn around a cell and the calibrated values could be shown over time using the Plot Z-axis profile in Fiji. The live function allowed to move the region of interest to rapidly analyse the specific time course of different cells.

- Example:
![Composite Example](c_Calibration_and_Composite_example.jpeg)
*Example of composite stack to be further processed by CellProfiler.*

![calibrate](c_Calibration_and_Composite_example_calibrated.jpeg)
*Example of calibrated stack. The experimental protocol was the following: baseline (images 1-8), glutamate stimulation (images 9-16), recovery (images 17-50), H2O2 depletion (images 50-70), H2O2 20µM (images 71-90).*

### Data Visualization Macros

#### 1 - Movie of color-coded single cells
##### a - Generation of color-coded images  (CellProfiler)
![d_Color_coded_cells](d_Color_coded_cells.jpeg)

- Input: Composite stack

- Processing steps: Measurement of single cell and single time point data

- Output: Images of color-coded cells in a target folder. Note that the images from different experiments will be pooled in the same folder with an increasing numeric ID added at the end of the folder name. For instance, 90-images experiments will end with the numbers 001 to 090 for the first movie, 091 to 180 for the second movie, 181 to 270 for the third movie etc.

- Example
![d_Color_coded_cells example](d_Color_coded_cells_example.jpeg)
*Example of color-coded calibrated image. Cold and warm color indicate low and high H2O2 concentrations, respectively.*

##### b - Generation of movies (Fiji / ImageJ)
![Movie maker](e_Movie_maker.jpeg)

- Input: Folder of color-coded images

- Processing steps:
	- Analysis of the number of field of view
	- Crop image (optional)
	- Stamp time, stimulation and calibration condition (optional)
	- Select specific begin and end of the movie (optional)
	- Make an avi file for each experiment.

- Output: Avi file of color-coded images where you can set the display speed and annotation features.

- Example

![Movie example](e_Movie_maker_example.gif)

*Example of annotated color-coded movie indicating the conditions.*

#### 2 - Graphics of single cell values
##### a - Generation of single-cell time course file  (CellProfiler)
![CellProfiler gui](f_Time_course_Measurement.jpeg)

- Input: Composite stack

- Processing steps: Measurement of single cell and single time point data

- Output: csv file of time courses and image stack of normalized cell values

##### b - Data plotting (Matlab)

*Note that this step may be considerably more efficient in Python using Pandas dataframe. Nevertheless, I enclose the code in case it could be useful for anybody. Therefore, I just outline the relevant information to run the script.*

- csv_to_struct_converter.mlx (*pre-processing macro*)
    - Input: CSV file generated by CellProfiler
    - Processing steps: Select and transform the data
    - Output: Matlab compatible file to generate a Megatable file pooling the time series data of all cells from a single experiment
    
- MegaTable generation.mlx (*pre-processing macro*)
    - Input: Struct file from the processed csv file
    - Processing steps: Pooling the time series data of all cells from a single experiment
    - Output: Matlab file to be processed for data visualization
    
- Plotting_script.mlx
![Plotting gui](f_Plotting.jpeg)
    - Input: Megatable file
    - Processing steps:
        - Baseline correction
        - Remove the cells that have values outside of the calibration range
        - Sort the data by increasing average value during basal condition
    - Output: 2D and 3D representation of individual cell time courses

Example:
![Example graphs](f_Example_Graphs.jpeg)
*Possibilities to illustrate the time course of a population of cells.*


***
## Acknowledgment
Haissa de Castro Abrantes (University of Lausanne) has prepared and maintained the culture of mouse cortical astrocytes. Critical inputs on the experimental design of the study were provided by [Bruno Weber](https://www.pharma.uzh.ch/en/research/functionalimaging.html) (University of Zurich) and [Jean-Yves Chatton](https://wwwfbm.unil.ch/dnf/group/imaging-the-neuroglia-metabolic-interplay) (University of Lausanne). This work was supported by SystemsX.ch.

## Citation
If you want to cite this work, you can refer to:
- project link: https://github.com/guillaume-azarias/Cell-to-cell-Heterogeneity
- abstract: Glutamate reduces the cell-to-cell variability in energy metabolism in astrocytes, G Azarias, H Abrantes, JY Chatton, B Weber - Glia, 2017

For more information, please contact Guillaume Azarias (guillaume.azarias@hotmail.com)

Thank you for reading !

![test](giphy.gif)
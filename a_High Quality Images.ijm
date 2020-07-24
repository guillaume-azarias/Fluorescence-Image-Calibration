/*
 * General workflow:
 * 
 * Step 1: 	The macro "a_High Quality Images" makes a Z-stack average of images 
 *          	to improve the images used by CellProfiler.
 * Step 2: 	The CellProfiler pipeline "b_Cell Segment" segments
 *          	the cells and identify the cell-specific mitochondrial regions.
 * Step 4: 	The Fiji macro "c_Composite Images" creates a composite of
 *          	a stack of probe images merged with the result of CP mitochondria regions.
 * Step 5 	The CellProfiler pipeline "d_Intensity Measurement" loops the intensity measurement
 *          	of cell-specific mitochondria regions and exports it in a Excel file.
 *          	Note that the CP stack is set to 61 images. Modify the code or make it
 *          	adaptive if relevant
 *
 * Technical notes:
 * Step 1: 	Make sure that your images are in a two-digit format.
 * Step 2:	The CellProfiler segmentation works better works better if you substract 
 * 			the background, even if, optically, the cells appear easier to segment
 * 			without background substraction.
 * Step 4: 	The structure of the folder is important: it must be in the 
 * 			following order: first the mito-outlines.tiff file, then the Big King
 * 			result and finally the series of experimental images.
 * 			
 * version 2017 04 13. guillaume.azarias@hotmail.com
 */

run("Close All");

// Dialog box for the input parameters
Dialog.create("Cell-to-cell heterogeneity quantification: High Quality Images");
Dialog.addMessage("Step 2/6: Generation of average Z-stacks of experimental images to optimize region detections in CellProfiler\n")
Dialog.addMessage("\n Parameters for nuclei images:")
Dialog.addString("Label for nuclei picture: ", "RedDot", 10);
Dialog.addString("Picture for background: ", "/Users/guillaume/Documents/Results/Resources/Background pictures/20x/RedDot 20x 1s no ND.TIF", 50);
Dialog.addMessage("\n Parameters for Marker images:")
Dialog.addNumber("First image to use: ", 1);
Dialog.addNumber("Last image to use: ", 75);
Dialog.addString("Label for Marker picture: ", "PercevalHR455", 12);
Dialog.addString("Picture for Marker background: ", "/Users/guillaume/Documents/Results/Resources/Background pictures/20x/FITC 150ms ND 025.TIF", 50);
first_discarded_array = newArray("Keep the first images", "Discard the first image");
Dialog.addRadioButtonGroup("Discard the very first image ?", first_discarded_array, 1, 2, "Keep the first images");
Dialog.show();

// Attribution of variables
channelnuc = Dialog.getString();
backgroundN = Dialog.getString();

first_image = Dialog.getNumber();
last_image = Dialog.getNumber();
//last_image = Dialog.getNumber();
channelMarker = Dialog.getString();
backgroundMarker = Dialog.getString();
// Conditional assignment to discard or not the very first image
first_discarded = Dialog.getRadioButton;

// If first_image > last_image
if (first_image>last_image) {
	exit("No !!!!!!!!! The first image must be BEFORE the last image.");
}

// Dialog box for the input/ouput folders
setOption("JFileChooser", true);
input = getDirectory("Input directory");
output = getDirectory("Output directory");
setOption("JFileChooser", false);

//------------------------------ Average of the Nuclei images ------------------------------

// Enters the BatchMode
t=getTime();
setBatchMode(true);

// Extracting and saving the name of images into the variable title[i] where i is the fov minus 1
// Extract the RedDot images
run("Image Sequence...", "open=["+ input +"] file=["+ channelnuc +"]");
fov=nSlices;
run("Stack to Images");

// Extract the names of the images and store them in a matrix title[i]
title=newArray(nImages);
for (i=0;i<nImages;i++) { 
        selectImage(i+1); 
        title[i] = getTitle;
						}

// Subtract the background to each image and store it with a "-Bckg" extension
open(backgroundN);
backgroundNID=getImageID();
i=-1;
for (j=1;j<(fov+1);j++) { 
			i++;
			selectImage(j);
			raw=getImageID();
	        imageCalculator("Subtract create", raw, backgroundNID);
	        saveAs("tiff", output+title[i] + "-Bckg");
	        beep();
							}

run("Close All");

//------------------------------ Average of the Marker images ------------------------------

// Extracting and saving the name of images

run("Image Sequence...", "open=["+ input +"] file=["+ channelMarker +"]");
nslices = nSlices/fov;

run("Image Sequence...", "open=["+ input +"] increment=["+ nslices +"] file=["+ channelMarker +"]");

run("Stack to Images");

title=newArray(nImages);
for (i=1;i<nImages;i++) { 
        selectImage(i+1); 
        title[i] = getTitle;
}

run("Close All");

//------------------------------ Exit the BatchMode ------------------------------
setBatchMode(false);

// Extract the images

run("Image Sequence...", "open=["+ input +"] file=["+ channelMarker +"]");

// If the number of images is not accurate, abort
		
checkslicenb = floor(nSlices/fov);

		if (checkslicenb != nSlices/fov) {
 		   exit("Correction needed: irregular number of experimental images per of field of view");
		}

// Make substacks, make a Z project, substract the backgroundN image and save it 
run("Stack Splitter", "number=["+ fov +"]");

nombreimages=nImages;

open(backgroundMarker);
backgroundMarkerID=getImageID();

for (i=1;i<nombreimages;i++) { 
			selectImage(i+1);
			if (first_image == 1) {
				// If I want the very first image discarded
					if (first_discarded=="Discard the first image") 	{
						// The first image of the first stack is discarded
						if (i==1)	{
									run("Slice Keeper", "first=2 last=["+ last_image +"] increment=1");
									}
						// For all other stacks, the first image is kept
						else 	{
							run("Slice Keeper", "first=1 last=["+ last_image +"] increment=1");
								}
																	}
				}
				// If I don't want to discard the very first image, all first images of all stacks are kept 
			else 	{
				run("Slice Keeper", "first=["+ first_image +"] last=["+ last_image +"] increment=1");
				}
			
			run("Image Stabilizer", "transformation=Translation maximum_pyramid_levels=1 template_update_coefficient=0.90 maximum_iterations=200 error_tolerance=0.0000001");
			run("Z Project...", "projection=[Average Intensity]");
			raw=getImageID();
	        imageCalculator("Subtract create", raw, backgroundMarkerID);
	        saveAs("tiff", output+title[i] + "_BK");
	        beep();
}

run("Close All");

// ------------------------------ Greeting message ------------------------------
delta_t = floor((getTime-t)/1000);

Dialog.create("The Burger King macro suite: Big King");
Dialog.addMessage("\nIt took " + delta_t + "sec.");
Dialog.addMessage("\n            All good :-)                ");
Dialog.show();
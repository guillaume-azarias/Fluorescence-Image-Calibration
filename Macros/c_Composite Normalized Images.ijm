/*
 * The Burger King macro suite: version 2016 12 16
 * 
 * Step 1: 	Use the Automator macro "The sequentielor" to rename the first 10 images
 *          	1, 2, 3, etc into 01, 02, 03, etc.
 * Step 2: 	The macro "Burger King_Big King" makes a Z-stack average of images 
 *          	to improve the images used by CellProfiler.
 * Step 3: 	The CellProfiler pipeline "Burger King - Cheeseburger" segments
 *          	the cells and identify the cell-specific mitochondrial regions.
 * Step 4: 	The Fiji macro "Burger King_Hamburger" creates a composite of
 *          	a stack of Marker images merged with the result of CP mitochondria regions.
 * Step 5 	The CellProfiler pipeline "Burger King-Whooper" loops the intensity measurement
 *          	of cell-specific mitochondria regions and exports it in a Excel file.
 *          	Note that the CP stack is set to 61 images. Modify the code or make it
 *          	adaptive if relevant
 * Step 6: 	The R macro "Convert_to_wide.R" transposes the Excel table.
 *
 * Technical notes:
 * -----------------------------------------------------------------------------------------
 * This script is designed for folders of the following structure: A single input folder
 * contains for each field of view:
 * 		- 1 image ending by _mito_outlines.tiff (this is the Cheeseburger file)
 * 		- all experimental images 
 * Note that no Big King file should be present.
 * 
 * -----------------------------------------------------------------------------------------
 * 
 * Step 1: 	You may use option + command + C to copy the file path and file name as a
 * 			text (an Automator Service Workflow created on 2015 12 13 valid in the Finder
 * 			and to which I added a shortcut in the keyboard System Preference.
 * Step 2:	The CellProfiler segmentation works better works better if you substract 
 * 			the background, even if, optically, the cells appear easier to segment
 * 			without background substraction.
 * Step 4: 	The structure of the folder is important: it must be in the 
 * 			following order: first the mito-outlines.tiff file, then the Big King
 * 			result and finally the series of experimental images.
 */

run("Close All");

// Dialog box for the input parameters
Dialog.create("              The Burger King macro suite: Hamburger (normalized) ");
Dialog.addMessage("Step 4/6: Do a composite stack of normalized and CP images to loop the object measurements\n                                   in CellProfiler.\n")
Dialog.addString("Label for the marker: ", "Rhod123", 10);
Dialog.addString("Marker background picture: ", "/Users/guillaume/Documents/Results/Resources/Background pictures/20x/FITC 150ms ND 025.TIF", 50);
first_discarded_array = newArray("Keep the first images", "Discard the first image");
Dialog.addRadioButtonGroup("Discard the very first image ?", first_discarded_array, 1, 2, "Keep the first images");
Dialog.addMessage("\n              Using one pharmacological condition to normalize experimental images              ");
Fmax_images = newArray("Z projection in stack", "Average from frames:");
Dialog.addRadioButtonGroup("\nMethod to calculate the maximal fluorescence intensity:", Fmax_images, 1, 2, "Z projection in stack");
Dialog.addNumber("                            Begin: ", 53);
Dialog.addNumber("                              End: ", 61);
Dialog.show();

// Attribution of variables
channelMarker = Dialog.getString();
backgroundMarker = Dialog.getString();
//Conditional assignment to discard or not the very first image
first_discarded = Dialog.getRadioButton;
//Conditional assignment to calculate Fmax
Fmax_set = Dialog.getRadioButton;
Fmax_images_start = Dialog.getNumber();
Fmax_images_end = Dialog.getNumber();

// Dialog box for the input/ouput folders
setOption("JFileChooser", true);
input = getDirectory("Input directory");
output = getDirectory("Output directory");
setOption("JFileChooser", false);

setBatchMode(true);
t=getTime();

//------------------------------ Create a temporary directory ------------------------------
	myDir = output+"ImageJ"+File.separator;
	File.makeDirectory(myDir);
	if (!File.exists(myDir))
	    exit("Directory exists");

//------------------------------ Determine the numbers of images and fields of view ------------------------------
// Measure the number of fields of view (fov)
run("Image Sequence...", "open=["+ input +"] file=[_mito_outlines.tif]");
fov=nSlices;
close();

// Extract the images
run("Image Sequence...", "open=["+ input +"] file=["+ channelMarker +"]");

// Measure the number of images per fields of view (ipfov)
ipfov=nSlices/fov;

// If the number of images is not accurate, 
check_ipfov = floor(ipfov);

		if (check_ipfov != ipfov) {
 		   exit("Correct the indicated numbers of images per field of view to match with the extracted stack\nThis script is designed for folders of the following structure: A single input folder\ncontains for each field of view:\n 		- 1 image ending by _mito_outlines.tiff (this is the Cheeseburger file)\n 		- all experimental images\nNote that no Big King file should be present.");
		}

//------------------------------ Making the Marker stacks ------------------------------

// Extracting the name of the experiment
raw_name=getTitle();

// Substract background and make substacks
open(backgroundMarker);
backgroundMarker_name=getTitle();

run("Calculator Plus", "i1=["+ raw_name +"] i2=["+ backgroundMarker_name +"] operation=[Subtract: i2 = (i1-i2) x k1 + k2] k1=1 k2=0 create");
close(raw_name);
close(backgroundMarker_name);

run("Stack Splitter", "number=["+ fov +"]");

i=newArray(nImages);
id=newArray(nImages);

for (i=1;i<(fov+1);i++) { 
	selectImage(i+1);

	// Creating the stack of normalized images

		// If I want the very first image discarded
		if (first_discarded=="Discard the first image") 	{
			// The first image of the first stack is discarded
			if (i==1)	{
						run("Slice Keeper", "first=3 last=["+ ipfov +"] increment=1");
						}
			// For all other stacks, the first image is kept
			else 	{
				run("Slice Keeper", "first=2 last=["+ ipfov +"] increment=1");
					}
															}
		// If I don't want to discard the very first image, all first images of all stacks are kept 
		else 	{
		run("Slice Keeper", "first=2 last=["+ ipfov +"] increment=1");
				}

	setBatchMode("show");
	setLocation(1, 94);
	run("Enhance Contrast", "saturated=0.35");
	run("Image Stabilizer", "transformation=Translation maximum_pyramid_levels=1 template_update_coefficient=0.90 maximum_iterations=200 error_tolerance=0.0000001");
	title_O = getTitle; 
		
	//------------------------------ Calculating Fmax ------------------------------
	if (Fmax_set=="Z projection in stack") {
		run("Z Project...", "projection=[Max Intensity]");
		saveAs("tiff", myDir+title_O + "_MAX");
											}
		else {
			run("Z Project...", "start=["+Fmax_images_start+"] stop=["+Fmax_images_end+"] projection=[Average Intensity]");
			saveAs("tiff", myDir+title_O + "_MAX");
			}

	//------------------------------ Calculating (F(t))/Fmax ------------------------------
	imageCalculator("Divide create 32-bit stack", title_O , title_O + "_MAX.tif");

	close("*max*");

	//------------------------------ Remove outliers and convert to 16-bit ------------------------------
	//run("Remove Outliers...", "radius=2 threshold=["+ three_fold_per_conc +"] which=Bright stack");
	//To rescale the 32bit image to 16bit, I multiply the pixel intensity by 65535 to get integer
	//Note that I decide to multiply by 60000 instead of 65535 to avoid any saturating pixel
	run("Multiply...", "value=60000 stack");
	run("Conversions...", " ");
	run("16-bit");
		

	saveAs("tiff", myDir + raw_name + "s" + i + "_Normalized_stack");
	close();
						}

run("Close All");

//------------------------------ Making the stack of CP images ------------------------------

// Running a loop that will make a stack of [ipfov] images for each single CP file
// To do a stack of [ipfov-1] images, I duplicate the image in a stack of 10 images
// then, I duplicate the stack that I concatenate and then remove the images in excess.

//------------------------------ Making the stack of CP images ------------------------------
// The ipfov corresponds so far to the number of experimental images + 1 (CP image)
// I remove 1 to ipfov to adjust the number of images to what I want

ipfov = ipfov-1;
n_10_stacks = floor(ipfov/10)+1;
n_removed_stacks = n_10_stacks*10-ipfov;
n_removed_stacks_plus_1 = n_removed_stacks+1;

// Extracting and saving the name of images into the variable title[i] where i is the fov minus 1
// Extract the _mito_outlines images
run("Image Sequence...", "open=["+ input +"] file=[_mito_outlines.tif]");
run("Stack to Images");

// Extract the names of the CP images and store them in a matrix title[i]
titleCP=newArray(nImages);
for (i=0;i<nImages;i++) { 
        selectImage(i+1); 
        titleCP[i] = getTitle;
						}
run("Close All");

for (i=0;i<(fov);i++) {

// Making the CP_stack
	open(input+titleCP[i]);
		// Convert the CP file "_mito_outlines" from 8 to 16bits if necessary
		if (bitDepth() !=16) 	{
		run("16-bit");
								}
								
		// Doing a stack of 10 images
			for (j=1;j<(10);j++) {  
				run("Duplicate...", " ");
								 }
			run("Images to Stack", "name=Stack title=[] use");
		//Doing a megastack (n_10_stacks duplicates of the 10 image-stack of 10)
			for (j=1;j<(n_10_stacks);j++) {  
				run("Duplicate...", "duplicate");
											}
		//Concatenating a superstack
			run("Concatenate...", "all_open title=[Concatenated Stacks]");

		//Adjusting the number of pictures:
		// If I want the very first image discarded
		if (first_discarded=="Discard the first image") 	{
			// The first image of the first stack is discarded
			if (i==0)	{
						run("Slice Remover", "first=1 last=n_removed_stacks_plus_1 increment=1");
						}
			// For all other stacks, the first image is kept
			else 	{
				run("Slice Remover", "first=1 last=n_removed_stacks increment=1");
					}
															}
		// If I don't want to discard the very first image, all first images of all stacks are kept 
		else 	{
		run("Slice Remover", "first=1 last=n_removed_stacks increment=1");
				}
        	
//Saving the stack
    saveAs("tiff", myDir+titleCP[i] + "_CPstack");
	close();
							}

//------------------------------ Now making the composite of Marker and CP stacks ------------------------------

for (i=0;i<(fov);i++) { 

	i_raw_title = i + 1;
	IDMarker = raw_name + "s" + i_raw_title + "_Normalized_stack.tif";
	IDCP = titleCP[i] + "_CPstack.tif";

	open(myDir+IDMarker);
	open(myDir+IDCP);

	run("Merge Channels...", "c1=["+IDMarker+"] c2=["+IDCP+"] create");
		saveAs("tiff", output + raw_name + "s" + i_raw_title + "_Normalized");
		close();
					}
		
//------------------------------ Cleaning up the temporary file ------------------------------

  list = getFileList(myDir);
  for (i=0; i<list.length; i++)
      ok = File.delete(myDir+list[i]);
  ok = File.delete(myDir);
  if (File.exists(myDir))
      exit("Unable to delete directory");

//------------------------------ Exit the BatchMode if active ------------------------------
setBatchMode(false);

//------------------------------ Greeting message ------------------------------
delta_t = floor((getTime-t)/1000);
beep();
Dialog.create("The Burger King macro suite: Hamburger");
Dialog.addMessage("\n            All good :-)                ");
if (delta_t<60) 
	Dialog.addMessage("\nComputing time: " + delta_t + "sec");
	else {min = floor(delta_t/60);
	sec = delta_t-(min*60);
	Dialog.addMessage("\nComputing time: " + min + "min" + sec + "sec");
	//Dialog.addMessage("\nBatchMode is currently off");
	}
Dialog.show();
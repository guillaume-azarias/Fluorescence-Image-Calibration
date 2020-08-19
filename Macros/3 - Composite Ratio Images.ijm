/*
 * General workflow:
 * 
 * Step 1: 	The macro "a_High Quality Images" makes a Z-stack average of images 
 *          	to improve the images used by CellProfiler.
 * Step 2: 	The CellProfiler pipeline "2 - Cell_Segmentation_Example" segments
 *          	the cells and identify the cell-specific mitochondrial regions.
 * Step 4: 	The Fiji macro "c_Composite Ratio Images" creates a composite of
 *          	a ratio images merged with the result of CP mitochondria regions.
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
 * Version 2016 05 01
 * 
 */

run("Close All");

// Dialog box for the input parameters
Dialog.create("              Calculation of ratio images and Generation of composite images ");
Dialog.addMessage("Step 4/6: Do a composite stack of normalized and CP images to loop the object measurements\n                                   in CellProfiler.\n")
Dialog.addString("Label for the numerator: ", "340nm", 10);
Dialog.addString("Background picture for the numerator: ", "/Users/guillaume/Documents/Results/Resources/Background pictures/20x/Fura-2 340nm 500ms ND 025.TIF", 50);
Dialog.addString("Label for the denominator: ", "380nm", 10);
Dialog.addString("Background picture for the numerator: ", "/Users/guillaume/Documents/Results/Resources/Background pictures/20x/Fura-2 380nm 300ms ND 025.TIF", 50);
first_discarded_array = newArray("Keep the first images", "Discard the first image");
Dialog.addRadioButtonGroup("Discard the very first image ?", first_discarded_array, 1, 2, "Keep the first images");
Dialog.show();

// Attribution of variables
Num_Marker = Dialog.getString();
Bakground_Num_Marker = Dialog.getString();
Denom_Marker = Dialog.getString();
Bakground_Denom_Marker = Dialog.getString();
//Conditional assignment to discard or not the very first image
first_discarded = Dialog.getRadioButton;

// Dialog box for the input/ouput folders
setOption("JFileChooser", true);
input = getDirectory("Input directory");
output = getDirectory("Output directory");
setOption("JFileChooser", false);

t=getTime();

//------------------------------ Determine the numbers of images and fields of view ------------------------------
// Measure the number of fields of view (fov)
run("Image Sequence...", "open=["+ output +"] file=[_mito_outlines.tif]");
fov=nSlices;
close();
// Measure the number of images per fields of view (ipfov)
run("Image Sequence...", "open=["+ input +"] file=["+ Num_Marker +"]");
ipfov=nSlices/fov;
close();

// If the number of images is not accurate, 
check_ipfov = floor(ipfov);

		if (check_ipfov != ipfov) {
 		   exit("Correct the indicated numbers of images per field of view to match with the extracted stack");
		}

//------------------------------ Create a temporary directory ------------------------------
	myDir = output+"ImageJ"+File.separator;
	File.makeDirectory(myDir);
	if (!File.exists(myDir))
	    exit("Directory exists");

//------------------------------ Making the Numerator stacks ------------------------------

// Extracting and saving the name of images into the variable title[i] where i is the fov minus 1

run("Image Sequence...", "open=["+ input +"] increment=["+ ipfov +"] file=["+ Num_Marker +"]");
run("Stack to Images");

title_Num=newArray(nImages+1);
for (i=1;i<=nImages;i++) { 
        selectImage(i);
        title_Num[i] = getTitle;
						}
						
run("Close All");

// Extract the images, substract background and make substacks
run("Image Sequence...", "open=["+ input +"] file=["+ Num_Marker +"]");
raw_name=getTitle();
open(Bakground_Num_Marker);
Bakground_Num_Marker_name=getTitle();

run("Calculator Plus", "i1=["+ raw_name +"] i2=["+ Bakground_Num_Marker_name +"] operation=[Subtract: i2 = (i1-i2) x k1 + k2] k1=1 k2=0 create");
close(raw_name);
close(Bakground_Num_Marker_name);

run("Stack Splitter", "number=["+ fov +"]");

i=newArray(nImages);
id=newArray(nImages);

for (i=1;i<(fov+1);i++) { 
	selectImage(i+1);

	// Creating the stacks of Numerator images

		// If I want the very first image discarded
		if (first_discarded=="Discard the first image") 	{
			// The first image of the first stack is discarded
			if (i==1)	{
						run("Slice Keeper", "first=2 last=["+ ipfov +"] increment=1");
						}
			// For all other stacks, the first image is kept
			else 	{
				run("Slice Keeper", "first=1 last=["+ ipfov +"] increment=1");
					}
															}
		// If I don't want to discard the very first image, all first images of all stacks are kept 
		else 	{
		run("Slice Keeper", "first=1 last=["+ ipfov +"] increment=1");
				}

		run("Image Stabilizer", "transformation=Translation maximum_pyramid_levels=1 template_update_coefficient=0.90 maximum_iterations=200 error_tolerance=0.0000001");

		saveAs("tiff", myDir+title_Num[i] + "_Num_Marker_stack");
		beep();
		close();
						}
						
run("Close All");

//------------------------------ Making the Denominator stacks ------------------------------

// Extracting and saving the name of images into the variable title[i] where i is the fov minus 1

run("Image Sequence...", "open=["+ input +"] increment=["+ ipfov +"] file=["+ Denom_Marker +"]");
run("Stack to Images");

title_Denom=newArray(nImages+1);
for (i=1;i<=nImages;i++) { 
        selectImage(i);
        title_Denom[i] = getTitle;
						}
						
run("Close All");

// Extract the images, substract background and make substacks
run("Image Sequence...", "open=["+ input +"] file=["+ Denom_Marker +"]");
raw_name=getTitle();
open(Bakground_Denom_Marker);
Bakground_Denom_Marker_name=getTitle();

run("Calculator Plus", "i1=["+ raw_name +"] i2=["+ Bakground_Denom_Marker_name +"] operation=[Subtract: i2 = (i1-i2) x k1 + k2] k1=1 k2=0 create");
close(raw_name);
close(Bakground_Denom_Marker_name);

run("Stack Splitter", "number=["+ fov +"]");

i=newArray(nImages);
id=newArray(nImages);

for (i=1;i<(fov+1);i++) { 
	selectImage(i+1);

	// Creating the stacks of Denomerator images

		// If I want the very first image discarded
		if (first_discarded=="Discard the first image") 	{
			// The first image of the first stack is discarded
			if (i==1)	{
						run("Slice Keeper", "first=2 last=["+ ipfov +"] increment=1");
						}
			// For all other stacks, the first image is kept
			else 	{
				run("Slice Keeper", "first=1 last=["+ ipfov +"] increment=1");
					}
															}
		// If I don't want to discard the very first image, all first images of all stacks are kept 
		else 	{
		run("Slice Keeper", "first=1 last=["+ ipfov +"] increment=1");
				}

		run("Image Stabilizer", "transformation=Translation maximum_pyramid_levels=1 template_update_coefficient=0.90 maximum_iterations=200 error_tolerance=0.0000001");

		saveAs("tiff", myDir+title_Denom[i] + "_Denom_Marker_stack");
		beep();
		close();
						}

run("Close All");

// Making the ratio Numerator / Denominator

setBatchMode(true);

for (i=1;i<(fov+1);i++) { 

	name_Num = title_Num[i] + "_Num_Marker_stack.tif";
	name_Denom = title_Denom[i] + "_Denom_Marker_stack.tif";

	open(myDir+name_Num);
	open(myDir+name_Denom);

	imageCalculator("Divide create 32-bit stack", name_Num , name_Denom);

		// Convert the stack to a 16-bit image
		run("Multiply...", "value=60000 stack");
		run("Conversions...", " ");
		run("16-bit");
	
	saveAs("tiff", myDir+title_Num[i] + "_" + Num_Marker + "_on" + Denom_Marker);
	beep();
	close();
					}

run("Close All");

//------------------------------ Making the stack of CP images ------------------------------

// Running a loop that will make a stack of [ipfov] images for each single CP file
// To do a stack of [ipfov] images, I duplicate the image in a stack of 10 images
// then, I duplicate the stack that I concatenate and then remove the images in excess.

//------------------------------ Making the stack of CP images ------------------------------

n_10_stacks = floor(ipfov/10)+1;
n_removed_stacks = n_10_stacks*10-ipfov;
n_removed_stacks_plus_1 = n_removed_stacks+1;

// Extracting and saving the name of images into the variable title[i] where i is the fov minus 1
// Extract the _mito_outlines images
run("Image Sequence...", "open=["+ output +"] file=[_mito_outlines.tif]");
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
	open(output+titleCP[i]);
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
	beep();
	close();
	
						}

//------------------------------ Now making the composite of Marker and CP stacks ------------------------------

for (i=1;i<(fov+1);i++) { 

	name_Ratio = title_Num[i] + "_" + Num_Marker + "_on" + Denom_Marker + ".tif";
	IDCP = titleCP[i-1] + "_CPstack.tif";

	open(myDir+name_Ratio);
	open(myDir+IDCP);

	run("Merge Channels...", "c1=["+name_Ratio+"] c2=["+IDCP+"] create");
		saveAs("tiff", output+title_Num[i] + "_Ratio_Merge");
		beep();
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

// ----------------------------- Greeting message ------------------------------
delta_t = floor((getTime-t)/1000);
Dialog.create("Processing completed");
Dialog.addMessage("\n            All good :-)                ");
if (delta_t<60) 
	Dialog.addMessage("\nComputing time: " + delta_t + "sec");
	else {min = floor(delta_t/60);
	sec = delta_t-(min*60);
	Dialog.addMessage("\nComputing time: " + min + "min" + sec + "sec");
	//Dialog.addMessage("\nBatchMode is currently off");
	}
Dialog.show();
/*
 * General workflow:
 * 
 * Step 1: 	The macro "a_High Quality Images" makes a Z-stack average of images 
 *          	to improve the images used by CellProfiler.
 * Step 2: 	The CellProfiler pipeline "b_Cell Segment" segments
 *          	the cells and identify the cell-specific mitochondrial regions.
 * Step 4: 	The Fiji macro "c_Composite Calibrated Images" creates a composite of
 *          	a calibrated probe images merged with the result of CP mitochondria regions.
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
 * version 2016 11 11. guillaume.azarias@hotmail.com
 */

run("Close All");

// Parameters

Dialog.create("              The Burger King macro suite: Hamburger (calibrated) ");
Dialog.addMessage("Step 4/6: Do a composite stack of calibrated and CP images to loop\n                      the object measurements in CellProfiler.\n");
fov_number_array = newArray("Automatic detection", "User defined:");
Dialog.addRadioButtonGroup("\nMethod to determine the number of fields of view:", fov_number_array, 1, 2, "Automatic detection");
Dialog.addNumber("                       Number of fields of view: ", 6);
Dialog.addNumber("Number of experimental images per field of view: ", 90);
Dialog.addString("Label for the marker: ", "FITC", 10);

Dialog.addMessage("\n            Using two calibration steps to calibrate experimental images              ");
correlation = newArray( "Correlation                ", "Anticorrelation\n");
Dialog.addRadioButtonGroup("\nEvolution of the fluorescence intensity according to peroxide concentration:", correlation, 1, 2, "Anticorrelation");
Dialog.addMessage("\n");

Fmax_images = newArray( "Z projection in stack", "Average from frames:");
Dialog.addRadioButtonGroup("\nMethod to calculate the fluorescence when [H2O2] is minimal:", Fmax_images, 1, 2, "Average from frames:");
Dialog.addNumber("                            Begin: ", 60);
Dialog.addNumber("                              End: ", 70);

Fmin_images = newArray( "Z projection in stack", "Average from frames:");
Dialog.addRadioButtonGroup("Method to calculate the fluorescence when [H2O2] is maximal:", Fmin_images, 1, 2, "Average from frames:");
Dialog.addNumber("                            Begin: ", 85);
Dialog.addNumber("                              End: ", 90);

Dialog.addNumber("  Concentration of peroxide in the calibration solution: ", 20);

Dialog.addCheckbox("Use Image Stabilizer to stabilize the stack", false);
Dialog.addCheckbox("Store 32-bit files", true);

Dialog.show();
// Parameters for the number of fields of view (fov)
fov_parameter = Dialog.getRadioButton;
fov = Dialog.getNumber();
ipfov = Dialog.getNumber();
channelMarker = Dialog.getString();

// Make a conditional assignment Fmax and Fmin according to the correlation
Parameter_correlation = Dialog.getRadioButton;
Fmax_set = Dialog.getRadioButton;
Fmax_images_start = Dialog.getNumber();
Fmax_images_end = Dialog.getNumber();
Fmin_set = Dialog.getRadioButton;
Fmin_images_start = Dialog.getNumber();
Fmin_images_end = Dialog.getNumber();
per_conc = Dialog.getNumber();
stabilizer_asked = Dialog.getCheckbox();
store_32_bits = Dialog.getCheckbox();

// Choosing the input and output folder


setOption("JFileChooser", true);
input = getDirectory("Folder containing the average images, cell regions and experimental images");
output = getDirectory("Target folder where you want to store the merged stack");
setOption("JFileChooser", false);


//input = "/Users/guillaume/Documents/Results/Mitochondrial ROS in vitro/Glutamate effect/Cheeseburger files and data/20160216z2/";
//output = "/Users/guillaume/Documents/Results/Mitochondrial ROS in vitro/Glutamate effect/Hamburger files/20160216z2/";

//------------------------------ Enters the BatchMode ------------------------------
t=getTime();
setBatchMode(true);
ipfov2= ipfov + 2

//------------------------------ Create a temporary directory ------------------------------
	myDir = output+"ImageJ"+File.separator;
	File.makeDirectory(myDir);
	if (!File.exists(myDir))
	    exit("Directory exists");

// If the method to determine the number of fields of view is set to "Automatic detection",
// it measures the number of fields of view

if (fov_parameter=="Automatic detection") {
		run("Image Sequence...", "open=["+ input +"] file=01.");
		fov=nSlices;
		close();							}

// Extracting and saving the name of images into the variable title[i] where i is the fov minus 1
showStatus("Extracting the names");
run("Image Sequence...", "open=["+ input +"] increment=["+ ipfov2 +"] file=["+ channelMarker +"]");
run("Stack to Images");

title=newArray(nImages);
for (i=0;i<nImages;i++) { 
        selectImage(i+1);
        title[i] = getTitle;
        //print("for i=" + i + ", the title is " + title[i]);
						}

run("Close All");

// Extract the CP file "_mito_outlines" and convert from 8 to 16bits if necessary
showStatus("Extracting the images of ROIs");
	run("Image Sequence...", "open=["+ input +"] file=_mito_outlines");
	if (bitDepth() !=16) {
		run("16-bit");
		}
		
	run("Stack to Images");
	for (i=0;i<fov;i++) { 
	    selectImage(i+1);
	    saveAs("tiff", input+getTitle);
	    //saveAs("tiff", myDir+title[i] + "_CPfile");
	    beep();
							}
								
	run("Close All");

//------------------------------ Extracting the images and convert to 32 bit ------------------------------
showStatus("Extracting the files");
run("Image Sequence...", "open=["+ input +"] file=["+ channelMarker +"]");

	// If the number of images is not accurate, abort
				
	checkslicenb = nSlices/ipfov2;
		if (checkslicenb != fov) {
 		   exit("Correct the indicated numbers of images per field of view to match with the extracted stack.\nCheck that, for each field of view, your input folder contains:\n - one file ending with _mito_outlines\n - the Big King file");
		}

	// Extract the CP images and make substacks discarding the 2 first images (CP file and z-stack)

showStatus("Creating stack");
run("Stack Splitter", "number=["+ fov +"]");

i=newArray(nImages);
id=newArray(nImages);
fov_plus_1=fov+1;

for (i=1;i<(fov_plus_1);i++)	{ 
	selectImage(i+1);
		id[i]=getImageID();

	// Duplicate, convert to a mask & save the _CPfile
	selectImage(id[i]);
		
		run("Duplicate...", "duplicate range=2-2");
		setThreshold(0, 1);
		run("Convert to Mask");
		run("32-bit");
		run("Multiply...", "value=255");
		saveAs("tiff", myDir+title[i-1] + "_CPfile");
	
	// Creating the stack of experimental images and stabilize it if asked
	selectImage(id[i]);
	
		run("Slice Keeper", "first=3 last=["+ ipfov2 +"] increment=1");
		
	// Run the image stabilizer if asked
	if (stabilizer_asked == true) {
		setBatchMode("show");
		setLocation(1, 94);
		run("Enhance Contrast", "saturated=0.35");
		run("Image Stabilizer", "transformation=Translation maximum_pyramid_levels=1 template_update_coefficient=0.90 maximum_iterations=200 error_tolerance=0.0000001");
		setBatchMode("hide");
									}
	
	// Convert to 32 bits and save the stack
	run("32-bit");
	saveAs("tiff", myDir+title[i-1] + "_stack");

	// End of the loop
	}

run("Close All");

// Processing the image calculations:

for (i=1;i<(fov_plus_1);i++)	{ 	
		// 1 ------------------------------ Opening the stack of experimental images ------------------------------
		open(myDir+title[i-1] + "_stack.tif");
		//run("32-bit");
		stack_file = getTitle;
		
setBatchMode(false);

		// 2 ------------------------------ Calculating Fmax and Fmin ------------------------------
		// Calculating Fmax
		if (Fmax_set=="Z projection in stack") {
			run("Z Project...", "projection=[Max Intensity]");
			saveAs("tiff", myDir+stack_file + "_MAX");
												}
			else {
				run("Z Project...", "start=["+Fmax_images_start+"] stop=["+Fmax_images_end+"] projection=[Average Intensity]");
				saveAs("tiff", myDir+stack_file + "_MAX");
				}
		Fmax_ID = getImageID();

		// Calculating Fmin
		selectWindow(stack_file);
		
		if (Fmin_set=="Z projection in stack") {
			run("Z Project...", "projection=[Min Intensity]");
			saveAs("tiff", myDir+stack_file + "_MIN");
												}
			else {
				run("Z Project...", "start=["+Fmin_images_start+"] stop=["+Fmin_images_end+"] projection=[Average Intensity]");
				saveAs("tiff", myDir+stack_file + "_MIN");
				}
		Fmin_ID = getImageID();
		
		// 3 ------------------------------ Calculating (Fmax-Fmin) ------------------------------
		/* Fmax-Fmin is a critical image for the calibration of the stack. You must evaluate the 
		values of the pixels in the background (regions where there are no mitochondria), otherwise
		it will biais the final value
		*/
		// 3a Calculate Fmax-Fmin
		imageCalculator("Subtract create 32-bit", Fmax_ID, Fmin_ID);
		Fmax_minus_Fmin = getImageID();
		close("\\Others");
		run("Set... ", "zoom=50 x=348 y=260");
		setLocation(1, 94);
		
		// 3b Exclude the value lower than 1
		//selectImage(Fmax_minus_Fmin);
		getStatistics(area, mean, min, max);
			max_intensity = max;
			// Note that the max_intensity will be modified after thresholding
			// max_intensity = max;
		run("Threshold...");
			setThreshold(1, max_intensity);
			// Note that the value of 1 is subjective. It means that 1 fluorescence unit corresponds to the change between Fmin and Fmax
			run("NaN Background");
			getStatistics(area, mean, min, max);
			mean_intensity = mean;
			max_intensity = 10*mean_intensity;
			run("Enhance Contrast", "saturated=0.35");

		// Use of the CPfile to generate images keeping or excluding the ROIs
			open(myDir+title[i-1] + "_CPfile.tif");
				run("Set... ", "zoom=50 x=348 y=260");
				setLocation(717, 94);
			MaskFileID = getImageID();

		// 3c Apply the CPfile as a mask to keep the cells
			imageCalculator("Subtract create", Fmax_minus_Fmin, MaskFileID);
			
			// Remove pixels outside of the mask
					setThreshold(1, max_intensity);
					run("NaN Background");
					run("Enhance Contrast", "saturated=0.35");
	
				run("Set... ", "zoom=50 x=348 y=260");
				saveAs("tiff", myDir + "Including Only Cell regions");
				cell_Fmax_minus_Fmin = getImageID();
				setLocation(717, 94);
				getStatistics(area, mean, min, max);
				mean_cell_Fmax_minus_Fmin = mean;
				setMinAndMax(1.0000, mean_cell_Fmax_minus_Fmin);
			run("Histogram", "bins=20 x_min=["+ 1 +"] x_max=["+ max_intensity +"] y_max=Auto");
			setLocation(717, 396);
			
		// 3d Apply the CPfile as a mask to keep the background
			selectImage(MaskFileID);
			run("Invert");
			run("Convert to Mask");
			run("32-bit");
			run("Multiply...", "value=255");
			MaskFileID=getImageID();
			imageCalculator("Substract create", Fmax_minus_Fmin, MaskFileID);
			background_Fmax_minus_Fmin = getImageID();

			// Remove pixels outside of the mask
					setThreshold(1, max_intensity);
					run("NaN Background");
					run("Enhance Contrast", "saturated=0.35");
					
			setLocation(359, 94);
			getStatistics(area, mean, min, max);
			mean_background_Fmax_minus_Fmin = mean;
			setMinAndMax(1.0000, mean_background_Fmax_minus_Fmin);
			saveAs("tiff", myDir + "Excluding Cell regions");
			
			run("Set... ", "zoom=50 x=348 y=260");
			run("Histogram", "bins=20 x_min=["+ 1 +"] x_max=["+ max_intensity +"] y_max=Auto");
				setLocation(359, 396);
			
			// 3e Ask for the cut-off threshold value
			cut_off = mean_background_Fmax_minus_Fmin + (mean_cell_Fmax_minus_Fmin - mean_background_Fmax_minus_Fmin)/2;
			selectImage(cell_Fmax_minus_Fmin);
			run("Threshold...");
			call("ij.plugin.frame.ThresholdAdjuster.setMode", "Over/Under");
			selectWindow("Threshold");
			setLocation(30, 396);
			
			setThreshold(cut_off, max_intensity);
			
						// Dialog box to let the user choose the Threshold values
							showStatus("Setting the threshold of the calibration image: image series " + i + " out of " + fov);
							box_title = "          Threshold";
							msg_start = "Adjust the threshold to exclude background";
							waitForUser(box_title, msg_start);
						
						// Apply the threshold and save
					setBatchMode("hide");
					selectImage(cell_Fmax_minus_Fmin);
					close("\\Others");
					run("NaN Background");
					saveAs("tiff", myDir + title[i-1] + "_Fmax-Fmin");

					run("Close All");
					setBatchMode(true);
					}

selectWindow("Threshold");
run("Close");

setBatchMode(true);

//------------------------------ Calculating the calibrated stacks  ------------------------------
for (i=1;i<(fov_plus_1);i++)	{
		//------------------------------ Calculating Fmax-F(t) ------------------------------
		open(myDir+title[i-1] + "_stack.tif_MAX.tif");
		MAX_file = getTitle;
		open(myDir+title[i-1] + "_stack.tif");
		stack = getTitle;
		run("Calculator Plus", "i1=["+ MAX_file +"] i2=["+ stack +"] operation=[Subtract: i2 = (i1-i2) x k1 + k2] k1=1 k2=0 create");

		saveAs("tiff", myDir + title[i-1] + "_Stack_Fmax-F(t)");
		Fmax_minus_Ft = getTitle;
		
		//------------------------------ Calculating (Fmax-F(t))/(Fmax-Fmin)*per_conc ------------------------------
		open(myDir + title[i-1] + "_Fmax-Fmin.tif");
		Fmax_minus_Fmin = getTitle;
		run("Calculator Plus", "i1=["+ Fmax_minus_Ft +"] i2=["+ Fmax_minus_Fmin +"] operation=[Divide: i2 = (i1/i2) x k1 + k2] k1=[" + per_conc +"] k2=0 create");

		//------------------------------ Remove outliers [(zero - 2xper_conc) ; (per_conc + 2xper_conc)] and convert to 16-bit ------------------------------
		/*
		 * Old method using the Remove Outlier plugin. Gave however strange line strips after a Fiji update in Nov 2016
		 *tolerance = 1;
		 *tolerated_concentration = per_conc*tolerance;
		 *run("Remove Outliers...", "radius=2 threshold=["+ tolerated_concentration +"] which=Bright stack");
		*/

		
		// Excluding outliers defined as 0 minus 2xper_conc and the per_conc plus 2xperconc
		// This method was empirically determined by applying thresholds increasingly narrowing
		// the calibration values. These limits enable to keep the calibration points exact.
		min_threshold = 0 - 2*per_conc;
		max_threshold = per_conc + 2*per_conc;
		run("Threshold...");
		setThreshold(min_threshold, max_threshold);
		run("NaN Background", "stack");
		
		if (store_32_bits == true) {
			saveAs("tiff", output+title[i-1] + "_Calibrated_stack_32bits");
		}
		
		setBatchMode("show");
		run("Add...", "value=40 stack");
		run("Multiply...", "value=100.000 stack");
		run("Conversions...", " ");
		run("16-bit");
		saveAs("tiff", myDir + title[i-1] + "_Calibrated_stack");
		run("Close All");
		
		// End of the image processing
						}

// see this function: showProgress(progress)

setBatchMode(true);

//------------------------------ Making the stack of CP images ------------------------------

// Running a loop that will make a stack of [ipfov] images for each single CP file
// To do a stack of [ipfov] images, I duplicate the image in a stack of 10 images
// then, I duplicate the stack that I concatenate and then remove the images in excess.


// Restore the 16 bit image in the ImageJ folder 
showStatus("Extracting the images of ROIs");
	run("Image Sequence...", "open=["+ input +"] file=_mito_outlines");
	run("Stack to Images");
	for (i=0;i<fov;i++) { 
	    selectImage(i+1);
	    saveAs("tiff", myDir+title[i] + "_CPfile");
							}
								
	run("Close All");

// Creating the stack of cell region images
showStatus("Creating the stack of cell region images");
n_10_stacks = floor(ipfov/10)+1;
n_removed_stacks = n_10_stacks*10-ipfov;

for (i=0;i<(fov);i++) {

	open(myDir+title[i] + "_CPfile.tif");

		//Doing a stack of 10 images
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
		//Adjusting the number of pictures
        	run("Slice Remover", "first=1 last=n_removed_stacks increment=1");
		//Saving the stack
        	saveAs("tiff", myDir+title[i] + "_CPstack");
	close();
	
						}

//------------------------------ Now making the composite of Marker and CP stacks ------------------------------

showStatus("Merging the experimental and cell region stacks");
for (i=0;i<(fov);i++) { 

	IDMarker = title[i] + "_Calibrated_stack.tif";
	IDCP = title[i] + "_CPstack.tif";

	open(myDir+IDMarker);
	open(myDir+IDCP);

	run("Merge Channels...", "c1=["+IDMarker+"] c2=["+IDCP+"] create");
		saveAs("tiff", output+title[i] + "_Merge");
		//beep();
		close();
					}

//------------------------------ Cleaning up the temporary files ------------------------------

showStatus("Cleaning up the temporary files");
	list = getFileList(myDir);
	for (i=0; i<list.length; i++)
		ok = File.delete(myDir+list[i]);
		ok = File.delete(myDir);
	if (File.exists(myDir))
      print("Unable to delete directory");

//------------------------------ Exit the BatchMode if active ------------------------------
setBatchMode(false);

// ----------------------------- Greeting message ------------------------------
delta_t = floor((getTime-t)/1000);
Dialog.create("The Burger King macro suite: Hamburger");
Dialog.addMessage("\n                                     All good :-)                \n");
if (delta_t<60) 
	Dialog.addMessage("Computing time: " + delta_t + "sec");
	else {min = floor(delta_t/60);
	sec = delta_t-(min*60);
	Dialog.addMessage("Computing time: " + min + "min" + sec + "sec");
	}
Dialog.addMessage("Merged stacks of experimental images and cell regions have been saved in: ");
Dialog.addMessage(output + "\n");
Dialog.addMessage("Note that uncalibrated pixels will exhibit an intensity value of 0.\nFor cellular intensity measurements, apply a mask to exclude 0-intensity pixels.");
Dialog.show();
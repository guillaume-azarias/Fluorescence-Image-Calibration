/*
 * 
 * General workflow:
 * 
 * Step 1: 	The macro "a_High Quality Images" makes a Z-stack average of images 
 *          	to improve the images used by CellProfiler.
 * Step 2: 	The CellProfiler pipeline "2 - Cell_Segmentation_Example" segments
 *          	the cells and identify the cell-specific mitochondrial regions.
 * Step 4: 	The Fiji macro "c_Composite Raw Images" creates a composite of
 *          	a raw images merged with the result of CP mitochondria regions.
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
 * Version 2017 04 18
 * 
 */
 
run("Close All");
if (isOpen("Log")) { 
         selectWindow("Log"); 
         run("Close"); 
     }

// Select the input and output folders

setOption("JFileChooser", true);
input = getDirectory("Choose your input directory");
output = getDirectory("Choose your output directory");
setOption("JFileChooser", false);
setBatchMode(true);

// Measure the number of fields of view and store the names of the stacks in the array title[i]
run("Image Sequence...", "open=["+ input +"] file=01.");
fov = nSlices;
if (fov > 1) {
	run("Stack to Images");
	}

title=newArray(fov);
for (i=0;i<nImages;i++) { 
        selectImage(i+1);
			if (fov == 1) {
				full_name = getInfo("slice.label");
				}
			else {
				full_name = getTitle;
	        	}
	        	
	    dotIndex = indexOf(full_name, "_");
		title[i] = substring(full_name, 0, dotIndex)+ "s" + i+1;
        //print("for i=" + i + ", the detected title is " + title[i]);
						}
						
run("Close All");

// Create a temporary directory
	myDir = output+"ImageJ"+File.separator;
	File.makeDirectory(myDir);

// Convert the Mito_Outlines images from 8 to 16bits if necessary

run("Image Sequence...", "open=["+ input +"] file=_mito_outlines");

// Save the Mito_Outlines images
run("Stack to Images");
for (i=0;i<fov;i++) {
	selectImage(i+1);
	if (bitDepth() !=16) {
		run("16-bit");
		saveAs("tiff", input + getTitle());
						}
	saveAs("tiff", myDir + title[i] + "_Mito_Outlines");
				}

run("Close All");

// Extract the images to process
run("Image Sequence...", "open=["+ input +"] file=20");

number_of_images = nSlices;
images_per_experiment = number_of_images/fov;

// Select the parameters
Dialog.create("              Generation of composite images using raw images");
Dialog.addMessage("Step 4/6: Do a composite stack of experimental and segmentation images to loop the object measurements in CellProfiler.")

if (fov == 1) {
	Dialog.addMessage("One single experiment of " + images_per_experiment + " images was detected:");
}
else {
	Dialog.addMessage("" + fov + " groups of " + images_per_experiment + " images were detected:");
}

// List the detected experiment names
for (i=0;i<fov;i++) {
	Dialog.addString("Experiment " + i+1 + ":", title[i], 25);
}

Dialog.addNumber("Number of CellProfiler file(s) inserted in the input folder: ", 1);
Dialog.addCheckbox("Keep working files", false);
Dialog.show();

// Processing

t=getTime();

// Get the name of the experiments
for (i=0;i<fov;i++) {
	title[i] = Dialog.getString();
	//print("for i=" + i + ", the saved title is " + title[i]);
}
// Other parameters 
cp_file_number = Dialog.getNumber();
store_file = Dialog.getCheckbox();

// Internal parameter`
ipfov = images_per_experiment - cp_file_number;

// Safety check 1: Number of CP images
if (cp_file_number != 1) {
	exit("This macro is done for 1 single CellProfiler file.");
}

// Safety check 2: If the number of images is not accurate, abort
		
checkslicenb = nSlices/images_per_experiment;

		if (checkslicenb != fov) {
 		   exit("Correct the indicated numbers of images per field of view to match with the extracted stack");
		}

//------------------------------ Extracting the CP file and making the Marker stacks ------------------------------
// Make substacks discarding the second images (CP file)

showStatus("Creating stack");
run("Stack Splitter", "number=["+ fov +"]");

function shows(windows_name) {
		setBatchMode("show");
		run("Out [-]");
		run("Out [-]");
		setLocation(1, 96);
		run("Enhance Contrast", "saturated=0.35");
}

for (i=0;i<fov;i++) {
	run("Slice Remover", "first=1 last=1 increment=1");
	shows(getTitle());
	run("Image Stabilizer", "transformation=Translation maximum_pyramid_levels=1 template_update_coefficient=0.90 maximum_iterations=200 error_tolerance=0.0000001");
	setBatchMode("hide");
	saveAs("tiff", myDir + title[fov-1-i] + "_Markerstack");
	close();
					}

// Close the mother stack
close();

//------------------------------ Making the stack of CP images ------------------------------

// Running a loop that will make a stack of [ipfov] images for each single CP file
// To do a stack of [ipfov] images, I duplicate the image in a stack of 10 images
// then, I duplicate the stack that I concatenate and then remove the images in excess.

setBatchMode(true);

// Do the stacks 

n_10_stacks = floor(ipfov/10)+1;
n_removed_stacks = n_10_stacks*10-ipfov;

for (i=0;i<(fov);i++) {

	open(myDir + title[i] + "_Mito_Outlines.tif");

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
        	saveAs("tiff", myDir + title[i] + "_CPstack");
	close();
	
						}

//------------------------------ Now making the composite of Marker and CP stacks ------------------------------

for (i=0;i<(fov);i++) { 

	IDMarker = title[i] + "_Markerstack.tif";
	IDCP = title[i] + "_CPstack.tif";

	open(myDir + IDMarker);
	open(myDir + IDCP);

	run("Merge Channels...", "c1=["+IDMarker+"] c2=["+IDCP+"] create");
		saveAs("tiff", output+title[i] + "_Merge");
		close();
					}

//------------------------------ Cleaning up the temporary files ------------------------------
if (store_file==false) {
	showStatus("Cleaning up the temporary files");
		list = getFileList(myDir);
		for (i=0; i<list.length; i++)
			ok = File.delete(myDir+list[i]);
			ok = File.delete(myDir);
		if (File.exists(myDir))
	      print("Unable to delete directory");
}
setBatchMode(false);

// ------------------------------ Greeting message ------------------------------
delta_t = floor((getTime-t)/1000);
Dialog.create("Procesing completed");
Dialog.addMessage("\n            All good :-)                ");
if (delta_t<60) 
	Dialog.addMessage("\nComputing time: " + delta_t + "sec");
	else {min = floor(delta_t/60);
	sec = delta_t-(min*60);
	Dialog.addMessage("\nComputing time: " + min + "min" + sec + "sec");
	}
Dialog.show();
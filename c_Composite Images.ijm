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
if (isOpen("Log")) { 
         selectWindow("Log"); 
         run("Close"); 
     }
     
showStatus("Cell-to-cell heterogeneity quantification")


// Select the input and output folders
setOption("JFileChooser", true);
input = getDirectory("Movie maker: choose your input directory");
output = getDirectory("Movie maker: choose your output directory");
setOption("JFileChooser", false);

setBatchMode(true);
// Measure the number of fields of view and store the name of the stacks in the array title[i]
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
		title[i] = substring(full_name, 0, dotIndex);
        //print("for i=" + i + ", the detected title is " + title[i]);
						}
						
run("Close All");

// Create a temporary directory
	myDir = output+"ImageJ"+File.separator;
	File.makeDirectory(myDir);
	if (!File.exists(myDir))
	    exit("Directory exists");

// Extract the images to process
run("Image Sequence...", "open=["+ input +"] file=20");
number_of_images = nSlices;
images_per_experiment = number_of_images/fov;
if (images_per_experiment>100) {
	images_per_experiment = 100;
}

// Select the parameters
Dialog.create("              Burger ");

if (fov == 1) {
	Dialog.addMessage("One single experiment of " + images_per_experiment + " images was detected:");
}
else {
	Dialog.addMessage("" + fov + " experiments of " + images_per_experiment + " images were detected:");
}
// List the detected experiment names
for (i=0;i<fov;i++) {
	Dialog.addString("Experiment " + i+1 + ":", title[i], 25);
}
// Propose to subdivide the movie if the number of fields of view is 1
if (fov == 1) {
	manual_fov_array = newArray("Single movie", "User defined:");
	Dialog.addRadioButtonGroup("Keep or divide the movie:", manual_fov_array, 1, 2, "Single movie");
	Dialog.addNumber("Number of submovies: ", 3);
	}

// Stamping parameters
if (fov == 1) {
	Dialog.addMessage("                                Parameters of the experiment");
}
else {
	Dialog.addMessage("                                Parameters of the experiments");
}                     
Dialog.addNumber("Interval between acquisitions (sec): ", 15);
// Parameters
Dialog.create("       Cell-to-cell heterogeneity quantification: Create composite images");
Dialog.addMessage("Step 4/6: Do a composite stack of experimental and CP images\n              to loop the object measurements in CellProfiler.\n \nParameters:\n")
Dialog.addNumber("                       Number of fields of view: ", 6);
Dialog.addNumber("Number of experimental images per field of view: ", 99);
Dialog.addString("Label for the marker: ", "FITC", 10);
Dialog.addNumber("Number of CellProfiler file(s) inserted in the input folder: ", 1);
Dialog.addCheckbox("Keep working files", false);
Dialog.show();

fov = Dialog.getNumber();
ipfov = Dialog.getNumber();
channelMarker = Dialog.getString();
cp_file_number = Dialog.getNumber();
store_file = Dialog.getCheckbox();

// Choosing the input and output folder

setOption("JFileChooser", true);
input = getDirectory("Input directory");
output = getDirectory("Output directory");
setOption("JFileChooser", false);

// Initialization
if (cp_file_number != 1) {
	exit("This macro is done for 1 single CellProfiler file.");
}

t=getTime();
ipfov2= ipfov + cp_file_number;


//------------------------------ Create a temporary directory ------------------------------
	myDir = output+"ImageJ"+File.separator;
	File.makeDirectory(myDir);
	if (!File.exists(myDir))
	    exit("Directory exists");

// Convert the CP file "_mito_outlines" from 8 to 16bits if necessary

run("Image Sequence...", "open=["+ input +"] file=_mito_outlines");
if (bitDepth() !=16) {
	run("16-bit");
	run("Stack to Images");
	for (i=0;i<fov;i++) { 
        selectImage(i+1);
        saveAs("tiff", input + getTitle);
						}
					}

run("Close All");

//------------------------------ Extracting the CP file and making the Marker stacks ------------------------------
// Extracting and saving the name of images into the variable title[i] where i is the fov minus 1

run("Image Sequence...", "open=["+ input +"] increment=["+ ipfov2 +"] file=["+ channelMarker +"]");

run("Stack to Images");

title=newArray(nImages);
for (i=0;i<nImages;i++) { 
        selectImage(i+1);
        title[i] = getTitle;
        print("for i=" + i + ", the title is " + title[i]);
						}

run("Close All");

run("Image Sequence...", "open=["+ input +"] file=["+ channelMarker +"]");

		// If the number of images is not accurate, abort
		
checkslicenb = nSlices/ipfov2;

		if (checkslicenb != fov) {
 		   exit("Correct the indicated numbers of images per field of view to match with the extracted stack");
		}

// Extract the images, make substacks discarding the first images (CP file)

run("Stack Splitter", "number=["+ fov +"]");

i=newArray(nImages);

for (i=1;i<(nImages);i++) {
	print("Select Image" + i);
	selectImage(i+1);
		id=getImageID();
	selectImage(id);
		run("Duplicate...", "duplicate range=1-1");
			saveAs("tiff", myDir + title[i-1] + "_CPfile");
			close();
	selectImage(id);
			run("Slice Remover", "first=2 last=2 increment=1");
			//run("Image Stabilizer", "transformation=Translation maximum_pyramid_levels=1 template_update_coefficient=0.90 maximum_iterations=200 error_tolerance=0.0000001");
			saveAs("tiff", myDir + title[i-1] + "_Markerstack");
			close();
						}

run("Close All");

//------------------------------ Making the stack of CP images ------------------------------

// Running a loop that will make a stack of [ipfov] images for each single CP file
// To do a stack of [ipfov] images, I duplicate the image in a stack of 10 images
// then, I duplicate the stack that I concatenate and then remove the images in excess.

setBatchMode(true);

n_10_stacks = floor(ipfov/10)+1;
n_removed_stacks = n_10_stacks*10-ipfov;

for (i=0;i<(fov);i++) {

	open(output+title[i] + "_CPfile.tif");

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
		beep();
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
Dialog.create("The Burger King macro suite: Hamburger");
Dialog.addMessage("\n            All good :-)                ");
if (delta_t<60) 
	Dialog.addMessage("\nComputing time: " + delta_t + "sec");
	else {min = floor(delta_t/60);
	sec = delta_t-(min*60);
	Dialog.addMessage("\nComputing time: " + min + "min" + sec + "sec");
	}
Dialog.show();
// Last update on 2016 11 17
// This is a macro to annotate image series at specific times, add the time and make an avi movie.

run("Close All");
showStatus("Welcome to Movie Maker")

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
Dialog.create("              Movie maker ");

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
Dialog.addSlider("Size of the text", 1, 72, 28);
Dialog.addString("First text to insert: ", " + Glutamate", 12);
Dialog.addSlider("Start:", 1, images_per_experiment, 10);
Dialog.addSlider("End  :", 1, images_per_experiment, 18);
Dialog.addString("Second text to insert: ", " Calibration", 12);
Dialog.addSlider("Start:", 1, images_per_experiment, images_per_experiment-43);
Dialog.addSlider("End  :", 1, images_per_experiment, images_per_experiment);
Dialog.addSlider("Number of frames per second:", 1, 24, 3);
Dialog.addCheckbox("Select manually the starting and ending images", false);
Dialog.addCheckbox("Crop the images", true);
Dialog.addCheckbox("Stamp the time", true);
Dialog.show();

t=getTime();

for (i=0;i<fov;i++) {
	title[i] = Dialog.getString();
	//print("for i=" + i + ", the saved title is " + title[i]);
}
if (fov == 1) {
	subdivision_decision = Dialog.getRadioButton;
	if (subdivision_decision == "Single movie") {
		trash = Dialog.getNumber();
		}
	else {
		fov = Dialog.getNumber();
		}
	}
text_1 = Dialog.getString();
interval = Dialog.getNumber();
size = Dialog.getNumber();
start_text_1 = Dialog.getNumber();
end_text_1 = Dialog.getNumber();
text_2 = Dialog.getString();
start_text_2 = Dialog.getNumber();
end_text_2 = Dialog.getNumber();
fps = Dialog.getNumber();
slice_select_decision = Dialog.getCheckbox();
crop_decison = Dialog.getCheckbox();
time_stamp_decision = Dialog.getCheckbox();

// Processing

showStatus("Creating stack");
run("Stack Splitter", "number=["+ fov +"]");

// Create titles if the movie is subdivided
if (fov == 1) {
	if (subdivision_decision == "User defined:") {
		name = title[0];
		title=newArray(fov);
		for (i=0;i<fov;i++) {
			title[i] = name + "s" + i+1;
			//print("for i=" + i + ", the detected title is " + title[i]);
		}
	}
}
// Save the stacks
for (i=1;i<(fov+1);i++)	{
	selectImage(i+1);
	saveAs("tiff", myDir + title[i-1]);
	}

run("Close All");

// Stamping the stacks
for (i=1;i<(fov+1);i++) 	{
		open(myDir + title[i-1] + ".tif");
		width = getWidth;
		height = getHeight;

		// Crop the image if desired
		if (crop_decison == true) {
			// Calculating the size (80% of the original size) and position of the region of interest

			rectangle_side_lenght = floor(0.8*height);
			x_corner = floor((width-rectangle_side_lenght)/2);
			y_corner = floor((height-rectangle_side_lenght)/2);

			setBatchMode("show");
			setLocation(1, 94);
			makeRectangle(x_corner, y_corner, rectangle_side_lenght, rectangle_side_lenght);
			setBatchMode("show");
			windows_title =     "            Crip crap crop";
			msg_start = "Select your the region that you want to display";
			waitForUser(windows_title, msg_start);
			run("Crop");
			width = getWidth;
								}
				
		// Text annotation
			//		Text_1
			setSlice(start_text_1-1);
			
			setFont("SansSerif", size, " antialiased");
			setJustification("right");
			setColor("white");
			
			for (j=start_text_1;j<=(end_text_1+1);j++) 	{
				run("Next Slice [>]");
				drawString(text_1, width, size, "black");
														}
			
			//		Text_2
			setSlice(start_text_2-1);
			
			for (j=start_text_2;j<=(end_text_2);j++) 	{
				setSlice(j);
				drawString(text_2, width, size, "black");
														}
							
		// Set the slices that you want to include in the movie
		  /*
		  if (crop_decison == false) {
		  	setBatchMode("show");
		  	setLocation(1, 94);
		  		}
		  */
		  
		  if (slice_select_decision == true) {
			  ID = getImageID();
			  Stack.setSlice(1);
			  windows_title = "              Movie maker ";
			  msg_start = "Select the slice from which you want to start the movie";
			  waitForUser(windows_title, msg_start);
			  start = getSliceNumber();
			  Stack.setSlice(nSlices);
			  msg_cut = "Select the slice that you want at the end of the movie";
			  waitForUser(windows_title, msg_cut);
			  cut = getSliceNumber();
			  setBatchMode("hide");
			  run("Slice Keeper", "first=["+ start +"] last=["+ cut +"] increment=1");
			  }

		// Time stamper
		if (time_stamp_decision == true) {
				run("Time Stamper", "starting=0 interval=["+ interval +"] x=5 y=["+ size +"] font=["+ size +"] '00 decimal=0 anti-aliased or=sec");
										}
		// Saving as an AVI movie
		title[i-1] = title[i-1] + ".avi";
		run("AVI... ", "compression=JPEG frame=["+ fps +"] save=["+ output + title[i-1] + "]");
		close();

		// End of the stack stamping
							}

//------------------------------ Cleaning up the temporary directory ------------------------------

  list = getFileList(myDir);
  for (i=0; i<list.length; i++)
      ok = File.delete(myDir+list[i]);
  ok = File.delete(myDir);
  if (File.exists(myDir))
      exit("Unable to delete directory");

//------------------------------ Greeting message ------------------------------
delta_t = floor((getTime-t)/1000);

Dialog.create("              Movie maker ");
if (fov == 1)
	Dialog.addMessage("\nThe movie is saved.");
	else {
		Dialog.addMessage("\nThe movies are saved.");
	}

if (delta_t<60) 
	time_text = "" + delta_t + "sec to make ";
	else {min = floor(delta_t/60);
	sec = delta_t-(min*60);
	time_text =  "" + min + "min" + sec + "sec to make ";
	}

if (fov == 1)
	movie_text = "this movie.";
	else {
		movie_text = "" + fov + " movies.";
	}

Dialog.addMessage("\nIt took " + time_text + movie_text);
Dialog.show();
#@ File (label = "Input directory", style = "directory") input_dir

processFolder(input_dir);

function processFolder(input_dir) {
	suffix = ".h5";
	list = getFileList(input_dir);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(endsWith(list[i], suffix))
			processFile(input_dir, list[i]);
	}
}

function processFile(input, file) {
	inputFilePath = input + File.separator + file;
	print("Processing: " + inputFilePath);
	run("Import HDF5", "select=" + inputFilePath + " datasetname=/exported_data axisorder=yxc");
	run("Stack to Images");
	selectImage("2");
	close();
	selectImage("1");
	run("Mean...", "radius=2");
	run("Smooth");	
	run("Invert LUT");
	//setTool("freehand");
	setAutoThreshold("Default dark no-reset");
	//run("Threshold...");
	run("Analyze Particles...", "size=0.0005-Infinity display summarize");
	close();
}
#@ File (label = "Input directory", style = "directory") input_dir

processFolder(input_dir);

function processFolder(input_dir) {
	suffix = ".tif";
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
	open(inputFilePath);
	run("Mean...", "radius=2");
	run("Smooth");
	setAutoThreshold("Default dark");
	//run("Threshold...");
	//setThreshold(1, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Analyze Particles...", "size=0.0005-Infinity display summarize");
	close();
}
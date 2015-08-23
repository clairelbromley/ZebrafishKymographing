from ij.io import DirectoryChooser
import ij.ImageStack
from ij import IJ, ImagePlus
import os
import time

# Choose a directory containing the data
dc = DirectoryChooser("Choose directory containing embryo folders...")
srcDir = dc.getDirectory()
print(srcDir)
IJ.log('Root directory: ' + srcDir)

# Loop through embryo sample directories, taking note of date and embryo number
folders=[f for f in os.listdir(srcDir)
	if os.path.isdir(os.path.join(srcDir,f)) and not (f.endswith('results'))]

for folder in folders:
	print(folder)
	IJ.log('Working on data in sample folder: ' + folder)
	(date, embryoNumber) = folder.split('_E')
	
	# Identify the indices of the files where cuts occur
	textFiles=[f for f in os.listdir(os.path.join(srcDir, folder))
	    if (f.endswith('.txt')) and not (f.endswith('para.txt'))]

	cutIndices = []
	for textFile in textFiles:
		cutIndices.append(int(textFile.split('_')[0]))

	print(cutIndices)

	# Prepare output directories...
	nowStr = time.strftime('%Y-%m-%d %H%M%S')
	outputDir = os.path.join(srcDir, nowStr+ " results")
	if not os.path.exists(outputDir):
		os.makedirs(outputDir)

	# Load frames from cutIndex - 1 to cutIndex + 20, and save as stacks
	for cutIndex in cutIndices:
		IJ.log('Working on short time course around cut at frame ' + str(cutIndex))
		imStack = ij.ImageStack(512,512)
		for fileIndex in range(-1,21):
			filename = "%06d_mix.tif" % (cutIndex+fileIndex)
			#print filename
			imp = IJ.openImage(os.path.join(srcDir, folder, filename))
			ip = imp.getProcessor()
			#print(ip)
			imStack.addSlice(filename, ip)

		newFileName = "Embryo %s, cut at %1.2f s.tif" % (embryoNumber, (float(cutIndex) * 0.2))
		newImp = ImagePlus(newFileName, imStack)
		newImp.show()
		IJ.log('Saving data to ' + os.path.join(outputDir, newFileName))
		IJ.save(newImp,  os.path.join(outputDir, newFileName))
		newImp.close()

	# Also save whole lot as an image stack...
	IJ.log('Working on complete time course - this might take a while...')
	images = [f for f in os.listdir(os.path.join(srcDir, folder))
	    if f.endswith('mix.tif')]

	imStack = ij.ImageStack(512,512)
	for image in images:
		imp = IJ.openImage(os.path.join(srcDir, folder, image))
		ip = imp.getProcessor()
		imStack.addSlice(image, ip)

	newFileName = "Embryo %s complete data.tif" %embryoNumber
	newImp = ImagePlus(newFileName, imStack)
	newImp.show()
	IJ.log('Saving data to ' + os.path.join(outputDir, newFileName))
	IJ.save(newImp, os.path.join(outputDir, newFileName))
	newImp.close()

IJ.log('Done!')

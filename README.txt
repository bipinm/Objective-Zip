This is a modified objective-zip(http://code.google.com/p/objective-zip/) developed by Flying Dolphin Studio

Flying Dolphin Studio is a privately held software development company based in Bologna, Italy. More informations can be found at www.flyingdolphinstudio.com 




The following changes were made to version 0.7.3:

1. iOS 5 & ARC (Automatic Reference Count) compliant
2. Add ObjectiveZip folder to your project and use it instantly
3. Add libz.dylib library to your project - removed the libz code.
4. Added a class method unzipFileContents:(NSString*)zipFilePath in Objective_ZipViewController.m. You may copy this directly to extract contents of a zip file to specific folder
5. Warnings are fixed
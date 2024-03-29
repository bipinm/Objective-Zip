//
//  Objective_ZipViewController.m
//  Objective-Zip
//
//  Created by Gianluca Bertani on 25/12/09.
//  Copyright Flying Dolphin Studio 2009. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without 
//  modification, are permitted provided that the following conditions 
//  are met:
//
//  * Redistributions of source code must retain the above copyright notice, 
//    this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice, 
//    this list of conditions and the following disclaimer in the documentation 
//    and/or other materials provided with the distribution.
//  * Neither the name of Gianluca Bertani nor the names of its contributors 
//    may be used to endorse or promote products derived from this software 
//    without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
//  POSSIBILITY OF SUCH DAMAGE.
//

#import "Objective_ZipViewController.h"
#import "ZipFile.h"
#import "ZipException.h"
#import "FileInZipInfo.h"
#import "ZipWriteStream.h"
#import "ZipReadStream.h"


@implementation Objective_ZipViewController


- (void) loadView {
	[super loadView];
	
	_textView.font= [UIFont fontWithName:@"Helvetica" size:11.0];
}

- (void) dealloc {
	if (_testThread)
		_testThread = nil;
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction) zipUnzip {
	if (_testThread)
		_testThread = nil;
	
	_testThread= [[NSThread alloc] initWithTarget:self selector:@selector(test) object:nil];
	[_testThread start];
}

- (void) test {
    @autoreleasepool {
        @try {
            NSString *documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *filePath= [documentsDir stringByAppendingPathComponent:@"test.zip"];

            [self performSelectorOnMainThread:@selector(log:) withObject:@"Opening zip file for writing..." waitUntilDone:YES];
            
            ZipFile *zipFile= [[ZipFile alloc] initWithFileName:filePath mode:ZipFileModeCreate];

            [self performSelectorOnMainThread:@selector(log:) withObject:@"Adding first file..." waitUntilDone:YES];
            
            ZipWriteStream *stream1= [zipFile writeFileInZipWithName:@"abc.txt" fileDate:[NSDate dateWithTimeIntervalSinceNow:-86400.0] compressionLevel:ZipCompressionLevelBest];

            [self performSelectorOnMainThread:@selector(log:) withObject:@"Writing to first file's stream..." waitUntilDone:YES];

            NSString *text= @"abc";
            [stream1 writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];

            [self performSelectorOnMainThread:@selector(log:) withObject:@"Closing first file's stream..." waitUntilDone:YES];
            
            [stream1 finishedWriting];
            
            [self performSelectorOnMainThread:@selector(log:) withObject:@"Adding second file..." waitUntilDone:YES];
            
            ZipWriteStream *stream2= [zipFile writeFileInZipWithName:@"x/y/z/xyz.txt" compressionLevel:ZipCompressionLevelNone];
            
            [self performSelectorOnMainThread:@selector(log:) withObject:@"Writing to second file's stream..." waitUntilDone:YES];
            
            NSString *text2= @"XYZ";
            [stream2 writeData:[text2 dataUsingEncoding:NSUTF8StringEncoding]];
            
            [self performSelectorOnMainThread:@selector(log:) withObject:@"Closing second file's stream..." waitUntilDone:YES];
            
            [stream2 finishedWriting];
            
            [self performSelectorOnMainThread:@selector(log:) withObject:@"Closing zip file..." waitUntilDone:YES];
            
            [zipFile close];
            zipFile = nil;
            
            [self performSelectorOnMainThread:@selector(log:) withObject:@"Opening zip file for reading..." waitUntilDone:YES];
            
            ZipFile *unzipFile= [[ZipFile alloc] initWithFileName:filePath mode:ZipFileModeUnzip];
            
            [self performSelectorOnMainThread:@selector(log:) withObject:@"Reading file infos..." waitUntilDone:YES];
            
            NSArray *infos= [unzipFile listFileInZipInfos];
            for (FileInZipInfo *info in infos) {
                NSString *fileInfo= [NSString stringWithFormat:@"- %@ %@ %d (%d)", info.name, info.date, info.size, info.level];
                [self performSelectorOnMainThread:@selector(log:) withObject:fileInfo waitUntilDone:YES];
            }
            
            [self performSelectorOnMainThread:@selector(log:) withObject:@"Opening first file..." waitUntilDone:YES];
            
            [unzipFile goToFirstFileInZip];
            ZipReadStream *read1= [unzipFile readCurrentFileInZip];
            
            [self performSelectorOnMainThread:@selector(log:) withObject:@"Reading from first file's stream..." waitUntilDone:YES];
            
            NSMutableData *data1= [[NSMutableData alloc] initWithLength:256];
            int bytesRead1= [read1 readDataWithBuffer:data1];
            
            BOOL ok= NO;
            if (bytesRead1 == 3) {
                NSString *fileText1= [[NSString alloc] initWithBytes:[data1 bytes] length:bytesRead1 encoding:NSUTF8StringEncoding];
                if ([fileText1 isEqualToString:@"abc"])
                    ok= YES;
            }
            
            if (ok)
                [self performSelectorOnMainThread:@selector(log:) withObject:@"Content of first file is OK" waitUntilDone:YES];
            else
                [self performSelectorOnMainThread:@selector(log:) withObject:@"Content of first file is WRONG" waitUntilDone:YES];
                
            [self performSelectorOnMainThread:@selector(log:) withObject:@"Closing first file's stream..." waitUntilDone:YES];
            
            [read1 finishedReading];
            
            [self performSelectorOnMainThread:@selector(log:) withObject:@"Opening second file..." waitUntilDone:YES];

            [unzipFile goToNextFileInZip];
            ZipReadStream *read2= [unzipFile readCurrentFileInZip];

            [self performSelectorOnMainThread:@selector(log:) withObject:@"Reading from second file's stream..." waitUntilDone:YES];
            
            NSMutableData *data2= [[NSMutableData alloc] initWithLength:256];
            int bytesRead2= [read2 readDataWithBuffer:data2];
            
            ok= NO;
            if (bytesRead2 == 3) {
                NSString *fileText2= [[NSString alloc] initWithBytes:[data2 bytes] length:bytesRead2 encoding:NSUTF8StringEncoding];
                if ([fileText2 isEqualToString:@"XYZ"])
                    ok= YES;
            }
            
            if (ok)
                [self performSelectorOnMainThread:@selector(log:) withObject:@"Content of second file is OK" waitUntilDone:YES];
            else
                [self performSelectorOnMainThread:@selector(log:) withObject:@"Content of second file is WRONG" waitUntilDone:YES];
            
            [self performSelectorOnMainThread:@selector(log:) withObject:@"Closing second file's stream..." waitUntilDone:YES];
            
            [read2 finishedReading];
            
            [self performSelectorOnMainThread:@selector(log:) withObject:@"Closing zip file..." waitUntilDone:YES];
            
            [unzipFile close];
            unzipFile = nil;
            
            [self performSelectorOnMainThread:@selector(log:) withObject:@"Test terminated succesfully" waitUntilDone:YES];
            
        } @catch (ZipException *ze) {
            [self performSelectorOnMainThread:@selector(log:) withObject:@"Caught a ZipException (see logs), terminating..." waitUntilDone:YES];
            
            NSLog(@"ZipException caught: %d - %@", ze.error, [ze reason]);

        } @catch (id e) {
            [self performSelectorOnMainThread:@selector(log:) withObject:@"Caught a generic exception (see logs), terminating..." waitUntilDone:YES];

            NSLog(@"Exception caught: %@ - %@", [[e class] description], [e description]);
        }
    }
}


//Added by Bipin M on 13 Dec 2011
+(BOOL)unzipFileContents:(NSString*)zipFilePath {
    
    NSString *dataPath = [[zipFilePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"UNZIP_DIR"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
        
        BOOL fileOperationSuccess = [[NSFileManager defaultManager] removeItemAtPath:dataPath error:NULL];
        
        if(fileOperationSuccess == NO) {
            
            NSLog(@"Failed to delete existing un-zip directory: %@", dataPath);
            return NO;
        }
    }
    
    NSError *error;
    BOOL fileOperationSuccess = [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    
    if(fileOperationSuccess == NO) {
        
        NSLog(@"Failed to create un-zip directory: %@", dataPath);
        return NO;
    }
    
    ZipFile *zipFile = [[ZipFile alloc] initWithFileName:zipFilePath mode:ZipFileModeUnzip];
    [zipFile goToFirstFileInZip];
    
    BOOL continueExtract = YES;
    while (continueExtract) {
        
        // Get file info
        FileInZipInfo *info = [zipFile getCurrentFileInZipInfo];
        
        // Read data into buffer
        ZipReadStream *stream = [zipFile readCurrentFileInZip];
        NSMutableData *data = [[NSMutableData alloc] initWithLength:info.length];
        [stream readDataWithBuffer:data];
        
        // Save data to file
        NSString *writePath = [dataPath stringByAppendingPathComponent:info.name];
        NSString *extractFilePath = [writePath stringByDeletingLastPathComponent];
        
        //Ensure that directories are created before writing the files
        if (![[NSFileManager defaultManager] fileExistsAtPath:extractFilePath]) {
            
            fileOperationSuccess = [[NSFileManager defaultManager] createDirectoryAtPath:extractFilePath withIntermediateDirectories:YES attributes:nil error:&error]; //Create folder
            
            if(fileOperationSuccess == NO) {
                
                NSLog(@"Failed to create un-zip sub-directory: %@", extractFilePath);
                return NO;
            }
        }
        
        NSError *error = nil;
        [data writeToFile:writePath options:NSDataWritingAtomic error:&error];
        if (error) {
            NSLog(@"Error unzipping file: %@", [error localizedDescription]);
            return NO;
        }
        
        // Cleanup
        [stream finishedReading];
        data = nil;
        
        // Check if we should continue reading
        continueExtract = [zipFile goToNextFileInZip];
    }
    
    [zipFile close];
    
    return YES;
}


- (void) log:(NSString *)text {
	NSLog(@"%@", text);
	
	_textView.text= [_textView.text stringByAppendingString:text];
	_textView.text= [_textView.text stringByAppendingString:@"\n"];
	
	NSRange range;
	range.location= [_textView.text length] -6;
	range.length= 5;
	[_textView scrollRangeToVisible:range];
}

@end

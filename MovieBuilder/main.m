//
//  main.m
//  mbu
//
//  Created by Yoshiki Vázquez Baeza on 1/3/14.
//  Copyright (c) 2014 Knight Laboratory. All rights reserved.
//
//  Based on python code by Jens Uwe Nockel, http://pages.uoregon.edu/noeckel/
//  see this post: http://mathematica.stackexchange.com/a/4903/1509
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <QTKit/QTKit.h>

void CreateMOVFileFromFilenames(NSArray *filenames, NSArray *durations,
                                NSString *outputFilename);


int main(int argc, const char * argv[])
{

    @autoreleasepool {
        NSUserDefaults *args = [NSUserDefaults standardUserDefaults];

        NSError *error=nil;

        NSString *filepathForListOfFilenames = nil;
        NSString *outputFilepath = nil;

        filepathForListOfFilenames = [args stringForKey:@"i"] ? [args stringForKey:@"i"] : [args stringForKey:@"-input"];
        outputFilepath = [args stringForKey:@"o"] ? [args stringForKey:@"o"] : [args stringForKey:@"-output"];

        // ghetto way to check if help is on or not
        if ([[[NSProcessInfo processInfo] arguments] containsObject:@"-h"] ||
            [[[NSProcessInfo processInfo] arguments] containsObject:@"--help"]){
            fprintf(stdout, "mbu: movie builder\n");
            fprintf(stdout, "-i (--input) - input filepath to list of frames "\
                            "and durations\n");
            fprintf(stdout, "-o (--output) - output filepath to the name of "\
                            "the movie\n");
            fprintf(stdout, "-h (--help) - help text\n");
            exit(0);
        }

        // set default filename to out.mov
        if (outputFilepath == nil) {
            outputFilepath = @"out.mov";
        }

        // do not execute a thing if the file input is not passed in
        if (filepathForListOfFilenames == nil) {
            fprintf(stdout, "The -i (--input) argument is required, pass in a "
                    "list of filepaths\n");
            exit(11);
        }

        error = nil;
        NSString *contents = [NSString stringWithContentsOfFile:filepathForListOfFilenames
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];

        if (error) {
            fprintf(stdout, "Error reading contents of file: %s\n",
                    [[error localizedDescription] UTF8String]);
            exit(12);
        }

        // separate on new lines
        NSMutableArray *arrayOfLines = (NSMutableArray *)[contents componentsSeparatedByCharactersInSet:
                                                          [NSCharacterSet newlineCharacterSet]];
        [arrayOfLines removeObjectAtIndex:[arrayOfLines count]-1];
        NSMutableArray *arrayOfDurations = nil, *arrayOfFilenames = nil;

        // check if there are durations in the contents of the file
        if ([[[arrayOfLines objectAtIndex:0] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] count] > 1) {
            arrayOfFilenames = [[NSMutableArray alloc] init];
            arrayOfDurations = [[NSMutableArray alloc] init];

            NSArray *buffer = nil;

            // retrieve the durations and save them in the arrays
            for (NSString *string in arrayOfLines) {
                buffer = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

                [arrayOfFilenames addObject:[buffer objectAtIndex:0]];
                [arrayOfDurations addObject:[buffer objectAtIndex:1]];

                // worthwile checking that all filepaths exist
                if (![[NSFileManager defaultManager]
                      fileExistsAtPath:[buffer objectAtIndex:0]]) {
                    fprintf(stdout, "Error, file %s does not exist!\n",
                          [[buffer objectAtIndex:0] UTF8String]);
                    exit(12);
                }
            }
        }
        // if there is not a duration in the file then just set this to 30
        else{
            arrayOfFilenames = [[NSMutableArray alloc] initWithArray:arrayOfLines];
            arrayOfDurations = [[NSMutableArray alloc] init];

            for (NSUInteger index = 0; index<[arrayOfFilenames count]; index++) {
                [arrayOfDurations addObject:@"30"];
            }
        }
        fprintf(stdout, "%ld frames were loaded\n", [arrayOfFilenames count]);

        // create the movie
        CreateMOVFileFromFilenames((NSArray *)arrayOfFilenames,
                                   (NSArray *)arrayOfDurations, outputFilepath);

    }
    return 0;
}

void CreateMOVFileFromFilenames(NSArray *filenames, NSArray *durations,
                                NSString *outputFilename)
{
// for some reason Apple has deprecated most of what's in the QTKit as of 10.9
// this nifty trick was taken from http://stackoverflow.com/a/14065939/379593
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

    NSError *error = nil;
    NSImage *image = nil;
    QTTime frameDuration;

    NSNumber *codecQuality = [NSNumber numberWithLong:codecHighQuality];
    NSDictionary *attributes = @{QTAddImageCodecType: @"avc1",
                                 QTAddImageCodecQuality: codecQuality};

    QTMovie *movieBuilder = [[QTMovie alloc] initToWritableFile:outputFilename
                                                          error:&error];

    if (error) {
        fprintf(stdout, "Error ocurred when creating QTMovie: %s\n",
               [[error localizedDescription] UTF8String]);
        return;
    }

    for(int index=0; index < [filenames count]; index++){
        image = [[NSImage alloc]
                 initWithContentsOfFile:[filenames objectAtIndex:index]];

        frameDuration = QTMakeTime([[durations objectAtIndex:index] longLongValue],
                                   600);

        [movieBuilder addImage:image
                   forDuration:frameDuration
                withAttributes:attributes];
#ifdef DEBUG
        fprintf(stdout, "Added %d\n", index);
#endif
    }
    [movieBuilder updateMovieFile];
#pragma clang diagnostic pop
}



































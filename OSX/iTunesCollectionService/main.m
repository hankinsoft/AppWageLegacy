//
//  main.m
//  iTunesCollectionService
//
//  Created by Kyle Hankinson on 2014-03-03.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#include <xpc/xpc.h>
#include <Foundation/Foundation.h>

#import "CollectionListener.h"

int main(int argc, const char *argv[])
{
	// An XPCService should use this singleton instance of serviceListener. It is preconfigured to listen on the name advertised by this XPCService's Info.plist.
	NSXPCListener *listener = [NSXPCListener serviceListener];
	
	// Create the delegate of the listener.
	CollectionListener *collectionListener = [CollectionListener new];
	listener.delegate = collectionListener;

	// Calling resume on the serviceListener does not return. It will wait for incoming connections using CFRunLoop or a dispatch queue, as appropriate.
	[listener resume];

    // The resume method never returns.
    exit(EXIT_FAILURE);
}

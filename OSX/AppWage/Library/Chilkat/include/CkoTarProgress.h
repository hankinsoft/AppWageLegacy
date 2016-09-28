// Base class for CkoTar event callbacks.
// Applications can create a class that derives from this class.
	
#import "CkoProgress.h"
	
@interface CkoTarProgress : CkoProgress {

}

- (id)init;
- (void)dealloc;
- (void)dispose;

- (void)AbortCheck: (BOOL *)abort;

- (void)ProgressInfo: (NSString *)name 
	value: (NSString *)value;

- (void)NextTarFile: (NSString *)fileName 
	fileSize: (NSNumber *)fileSize
	bIsDirectory: (BOOL)bIsDirectory 
	skip: (BOOL *)skip;


@end

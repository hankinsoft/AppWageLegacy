// Base class for CkoSocket event callbacks.
// Applications can create a class that derives from this class.

#import "CkoProgress.h"

@interface CkoSocketProgress : CkoProgress {

}

- (id)init;
- (void)dealloc;
- (void)dispose;

- (void)AbortCheck: (BOOL *)abort;
- (void)PercentDone: (NSNumber *)pctDone
	abort: (BOOL *)abort;
- (void)ProgressInfo: (NSString *)name
	value: (NSString *)value;


- (void)DnsComplete: (NSNumber *)objectId
	domainName: (NSString *)domainName
	ipAddress: (NSString *)ipAddress
	success: (BOOL)success;

- (void)ConnectComplete: (NSNumber *)objectId
	domainName: (NSString *)domainName
	port: (NSNumber *)port
	success: (BOOL)success;

- (void)AcceptComplete: (NSNumber *)objectId
	ipAddress: (NSString *)ipAddress
	port: (NSNumber *)port
	success: (BOOL)success;

- (void)ReverseDnsComplete: (NSNumber *)objectId
	ipAddress: (NSString *)ipAddress
	domainName: (NSString *)domainName
	success: (BOOL)success;

- (void)SendComplete: (NSNumber *)objectId
	numBytes: (NSNumber *)numBytes
	success: (BOOL)success;

- (void)ReceiveBytesComplete: (NSNumber *)objectId
	byteData: (NSData *)byteData
	numBytes: (NSNumber *)numBytes
	success: (BOOL)success;

- (void)ReceiveStringComplete: (NSNumber *)objectId
	strReceived: (NSString *)strReceived
	success: (BOOL)success;

@end

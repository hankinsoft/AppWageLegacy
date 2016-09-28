// Chilkat Objective-C header.
// Generic/internal class name =  CkDateTime
// Wrapped Chilkat C++ class name =  CkDateTime



@interface CkoDateTime : NSObject {

	@private
		void *m_obj;

}

- (id)init;
- (void)dealloc;
- (void)dispose;
- (NSString *)stringWithUtf8: (const char *)s;
- (void *)CppImplObj;
- (void)setCppImplObj: (void *)pObj;

// property getter: DebugLogFilePath
- (NSString *)DebugLogFilePath;

// property setter: DebugLogFilePath
- (void)setDebugLogFilePath: (NSString *)input;

// property getter: IsDst
- (NSNumber *)IsDst;

// property getter: LastErrorHtml
- (NSString *)LastErrorHtml;

// property getter: LastErrorText
- (NSString *)LastErrorText;

// property getter: LastErrorXml
- (NSString *)LastErrorXml;

// property getter: UtcOffset
- (NSNumber *)UtcOffset;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// method: AddDays
- (BOOL)AddDays: (NSNumber *)numDays;

// method: DeSerialize
- (void)DeSerialize: (NSString *)serializedDateTime;

// method: GetAsDateTimeTicks
- (NSNumber *)GetAsDateTimeTicks: (BOOL)bLocal;

// method: GetAsDosDate
- (NSNumber *)GetAsDosDate: (BOOL)bLocal;

// method: GetAsOleDate
- (NSNumber *)GetAsOleDate: (BOOL)bLocal;

// method: GetAsRfc822
- (NSString *)GetAsRfc822: (BOOL)bLocal;

// method: GetAsSystemTime
- (NSDate *)GetAsSystemTime: (BOOL)bLocal;

// method: GetAsUnixTime
- (NSNumber *)GetAsUnixTime: (BOOL)bLocal;

// method: GetAsUnixTime64
- (NSNumber *)GetAsUnixTime64: (BOOL)bLocal;

// method: GetAsUnixTimeDbl
- (NSNumber *)GetAsUnixTimeDbl: (BOOL)bLocal;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: Serialize
- (NSString *)Serialize;

// method: SetFromCurrentSystemTime
- (void)SetFromCurrentSystemTime;

// method: SetFromDateTimeTicks
- (void)SetFromDateTimeTicks: (BOOL)bLocal 
	n: (NSNumber *)n;

// method: SetFromDosDate
- (void)SetFromDosDate: (BOOL)bLocal 
	t: (NSNumber *)t;

// method: SetFromOleDate
- (void)SetFromOleDate: (BOOL)bLocal 
	dt: (NSNumber *)dt;

// method: SetFromRfc822
- (BOOL)SetFromRfc822: (NSString *)rfc822Str;

// method: SetFromSystemTime
- (void)SetFromSystemTime: (BOOL)bLocal 
	sysTime: (NSDate *)sysTime;

// method: SetFromUnixTime
- (void)SetFromUnixTime: (BOOL)bLocal 
	t: (NSNumber *)t;

// method: SetFromUnixTime64
- (void)SetFromUnixTime64: (BOOL)bLocal 
	t: (NSNumber *)t;

// method: SetFromUnixTimeDbl
- (void)SetFromUnixTimeDbl: (BOOL)bLocal 
	t: (NSNumber *)t;


@end

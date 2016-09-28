// Chilkat Objective-C header.
// Generic/internal class name =  Bounce
// Wrapped Chilkat C++ class name =  CkBounce

@class CkoEmail;


@interface CkoBounce : NSObject {

	@private
		void *m_obj;

}

- (id)init;
- (void)dealloc;
- (void)dispose;
- (NSString *)stringWithUtf8: (const char *)s;
- (void *)CppImplObj;
- (void)setCppImplObj: (void *)pObj;

// property getter: BounceAddress
- (NSString *)BounceAddress;

// property getter: BounceData
- (NSString *)BounceData;

// property getter: BounceType
- (NSNumber *)BounceType;

// property getter: DebugLogFilePath
- (NSString *)DebugLogFilePath;

// property setter: DebugLogFilePath
- (void)setDebugLogFilePath: (NSString *)input;

// property getter: LastErrorHtml
- (NSString *)LastErrorHtml;

// property getter: LastErrorText
- (NSString *)LastErrorText;

// property getter: LastErrorXml
- (NSString *)LastErrorXml;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// method: ExamineEmail
- (BOOL)ExamineEmail: (CkoEmail *)email;

// method: ExamineEml
- (BOOL)ExamineEml: (NSString *)emlPath;

// method: ExamineMime
- (BOOL)ExamineMime: (NSString *)mimeString;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: UnlockComponent
- (BOOL)UnlockComponent: (NSString *)unlockCode;


@end

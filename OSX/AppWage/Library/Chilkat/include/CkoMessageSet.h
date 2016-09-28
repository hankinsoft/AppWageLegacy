// Chilkat Objective-C header.
// Generic/internal class name =  MessageSet
// Wrapped Chilkat C++ class name =  CkMessageSet



@interface CkoMessageSet : NSObject {

	@private
		void *m_obj;

}

- (id)init;
- (void)dealloc;
- (void)dispose;
- (NSString *)stringWithUtf8: (const char *)s;
- (void *)CppImplObj;
- (void)setCppImplObj: (void *)pObj;

// property getter: Count
- (NSNumber *)Count;

// property getter: DebugLogFilePath
- (NSString *)DebugLogFilePath;

// property setter: DebugLogFilePath
- (void)setDebugLogFilePath: (NSString *)input;

// property getter: HasUids
- (BOOL)HasUids;

// property setter: HasUids
- (void)setHasUids: (BOOL)boolVal;

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

// method: ContainsId
- (BOOL)ContainsId: (NSNumber *)id;

// method: FromCompactString
- (BOOL)FromCompactString: (NSString *)str;

// method: GetId
- (NSNumber *)GetId: (NSNumber *)index;

// method: InsertId
- (void)InsertId: (NSNumber *)id;

// method: RemoveId
- (void)RemoveId: (NSNumber *)id;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: ToCompactString
- (NSString *)ToCompactString;

// method: ToString
- (NSString *)ToString;


@end

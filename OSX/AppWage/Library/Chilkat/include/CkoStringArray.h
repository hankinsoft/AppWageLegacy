// Chilkat Objective-C header.
// Generic/internal class name =  StringArray
// Wrapped Chilkat C++ class name =  CkStringArray



@interface CkoStringArray : NSObject {

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

// property getter: Crlf
- (BOOL)Crlf;

// property setter: Crlf
- (void)setCrlf: (BOOL)boolVal;

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

// property getter: Trim
- (BOOL)Trim;

// property setter: Trim
- (void)setTrim: (BOOL)boolVal;

// property getter: Unique
- (BOOL)Unique;

// property setter: Unique
- (void)setUnique: (BOOL)boolVal;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// method: Append
- (BOOL)Append: (NSString *)str;

// method: AppendSerialized
- (BOOL)AppendSerialized: (NSString *)encodedStr;

// method: Clear
- (void)Clear;

// method: Contains
- (BOOL)Contains: (NSString *)str;

// method: Find
- (NSNumber *)Find: (NSString *)str 
	firstIndex: (NSNumber *)firstIndex;

// method: FindFirstMatch
- (NSNumber *)FindFirstMatch: (NSString *)str 
	firstIndex: (NSNumber *)firstIndex;

// method: GetString
- (NSString *)GetString: (NSNumber *)index;

// method: GetStringLen
- (NSNumber *)GetStringLen: (NSNumber *)index;

// method: InsertAt
- (void)InsertAt: (NSNumber *)index 
	str: (NSString *)str;

// method: LastString
- (NSString *)LastString;

// method: LoadFromFile
- (BOOL)LoadFromFile: (NSString *)path;

// method: LoadFromFile2
- (BOOL)LoadFromFile2: (NSString *)path 
	charset: (NSString *)charset;

// method: LoadFromText
- (void)LoadFromText: (NSString *)str;

// method: Pop
- (NSString *)Pop;

// method: Prepend
- (void)Prepend: (NSString *)str;

// method: Remove
- (void)Remove: (NSString *)str;

// method: RemoveAt
- (BOOL)RemoveAt: (NSNumber *)index;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: SaveNthToFile
- (BOOL)SaveNthToFile: (NSNumber *)index 
	path: (NSString *)path;

// method: SaveToFile
- (BOOL)SaveToFile: (NSString *)path;

// method: SaveToFile2
- (BOOL)SaveToFile2: (NSString *)path 
	charset: (NSString *)charset;

// method: SaveToText
- (NSString *)SaveToText;

// method: Serialize
- (NSString *)Serialize;

// method: Sort
- (void)Sort: (BOOL)ascending;

// method: SplitAndAppend
- (void)SplitAndAppend: (NSString *)str 
	boundary: (NSString *)boundary;

// method: StrAt
- (NSString *)StrAt: (NSNumber *)index;

// method: Subtract
- (void)Subtract: (CkoStringArray *)sa;

// method: Union
- (void)Union: (CkoStringArray *)sa;


@end

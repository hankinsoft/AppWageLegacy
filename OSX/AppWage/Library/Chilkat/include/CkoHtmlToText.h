// Chilkat Objective-C header.
// Generic/internal class name =  HtmlToText
// Wrapped Chilkat C++ class name =  CkHtmlToText



@interface CkoHtmlToText : NSObject {

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

// property getter: DecodeHtmlEntities
- (BOOL)DecodeHtmlEntities;

// property setter: DecodeHtmlEntities
- (void)setDecodeHtmlEntities: (BOOL)boolVal;

// property getter: LastErrorHtml
- (NSString *)LastErrorHtml;

// property getter: LastErrorText
- (NSString *)LastErrorText;

// property getter: LastErrorXml
- (NSString *)LastErrorXml;

// property getter: RightMargin
- (NSNumber *)RightMargin;

// property setter: RightMargin
- (void)setRightMargin: (NSNumber *)intVal;

// property getter: SuppressLinks
- (BOOL)SuppressLinks;

// property setter: SuppressLinks
- (void)setSuppressLinks: (BOOL)boolVal;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// method: IsUnlocked
- (BOOL)IsUnlocked;

// method: ReadFileToString
- (NSString *)ReadFileToString: (NSString *)path 
	srcCharset: (NSString *)srcCharset;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: ToText
- (NSString *)ToText: (NSString *)html;

// method: UnlockComponent
- (BOOL)UnlockComponent: (NSString *)code;

// method: WriteStringToFile
- (BOOL)WriteStringToFile: (NSString *)str 
	path: (NSString *)path 
	charset: (NSString *)charset;


@end

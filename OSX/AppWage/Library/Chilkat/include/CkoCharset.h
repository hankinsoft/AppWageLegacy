// Chilkat Objective-C header.
// Generic/internal class name =  Charset
// Wrapped Chilkat C++ class name =  CkCharset



@interface CkoCharset : NSObject {

	@private
		void *m_obj;

}

- (id)init;
- (void)dealloc;
- (void)dispose;
- (NSString *)stringWithUtf8: (const char *)s;
- (void *)CppImplObj;
- (void)setCppImplObj: (void *)pObj;

// property getter: AltToCharset
- (NSString *)AltToCharset;

// property setter: AltToCharset
- (void)setAltToCharset: (NSString *)input;

// property getter: DebugLogFilePath
- (NSString *)DebugLogFilePath;

// property setter: DebugLogFilePath
- (void)setDebugLogFilePath: (NSString *)input;

// property getter: ErrorAction
- (NSNumber *)ErrorAction;

// property setter: ErrorAction
- (void)setErrorAction: (NSNumber *)intVal;

// property getter: FromCharset
- (NSString *)FromCharset;

// property setter: FromCharset
- (void)setFromCharset: (NSString *)input;

// property getter: LastErrorHtml
- (NSString *)LastErrorHtml;

// property getter: LastErrorText
- (NSString *)LastErrorText;

// property getter: LastErrorXml
- (NSString *)LastErrorXml;

// property getter: LastInputAsHex
- (NSString *)LastInputAsHex;

// property getter: LastInputAsQP
- (NSString *)LastInputAsQP;

// property getter: LastOutputAsHex
- (NSString *)LastOutputAsHex;

// property getter: LastOutputAsQP
- (NSString *)LastOutputAsQP;

// property getter: SaveLast
- (BOOL)SaveLast;

// property setter: SaveLast
- (void)setSaveLast: (BOOL)boolVal;

// property getter: ToCharset
- (NSString *)ToCharset;

// property setter: ToCharset
- (void)setToCharset: (NSString *)input;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// method: CharsetToCodePage
- (NSNumber *)CharsetToCodePage: (NSString *)charsetName;

// method: CodePageToCharset
- (NSString *)CodePageToCharset: (NSNumber *)codePage;

// method: ConvertData
- (NSData *)ConvertData: (NSData *)inData;

// method: ConvertFile
- (BOOL)ConvertFile: (NSString *)srcPath 
	destPath: (NSString *)destPath;

// method: ConvertFileNoPreamble
- (BOOL)ConvertFileNoPreamble: (NSString *)srcPath 
	destPath: (NSString *)destPath;

// method: ConvertFromUtf16
- (NSData *)ConvertFromUtf16: (NSData *)uniData;

// method: ConvertHtml
- (NSData *)ConvertHtml: (NSData *)htmlIn;

// method: ConvertHtmlFile
- (BOOL)ConvertHtmlFile: (NSString *)srcPath 
	destPath: (NSString *)destPath;

// method: ConvertToUtf16
- (NSData *)ConvertToUtf16: (NSData *)mbData;

// method: EntityEncodeDec
- (NSString *)EntityEncodeDec: (NSString *)inStr;

// method: EntityEncodeHex
- (NSString *)EntityEncodeHex: (NSString *)inStr;

// method: GetHtmlCharset
- (NSString *)GetHtmlCharset: (NSData *)htmlData;

// method: GetHtmlFileCharset
- (NSString *)GetHtmlFileCharset: (NSString *)htmlPath;

// method: HtmlDecodeToStr
- (NSString *)HtmlDecodeToStr: (NSString *)str;

// method: HtmlEntityDecode
- (NSData *)HtmlEntityDecode: (NSData *)inData;

// method: HtmlEntityDecodeFile
- (BOOL)HtmlEntityDecodeFile: (NSString *)srcPath 
	destPath: (NSString *)destPath;

// method: IsUnlocked
- (BOOL)IsUnlocked;

// method: LowerCase
- (NSString *)LowerCase: (NSString *)inStr;

// method: ReadFile
- (NSData *)ReadFile: (NSString *)path;

// method: ReadFileToString
- (NSString *)ReadFileToString: (NSString *)path 
	srcCharset: (NSString *)srcCharset;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: SetErrorBytes
- (void)SetErrorBytes: (NSData *)pByteData 
	szByteData: (NSNumber *)szByteData;

// method: SetErrorString
- (void)SetErrorString: (NSString *)str 
	charset: (NSString *)charset;

// method: UnlockComponent
- (BOOL)UnlockComponent: (NSString *)unlockCode;

// method: UpperCase
- (NSString *)UpperCase: (NSString *)inStr;

// method: UrlDecodeStr
- (NSString *)UrlDecodeStr: (NSString *)inStr;

// method: VerifyData
- (BOOL)VerifyData: (NSString *)charset 
	charData: (NSData *)charData;

// method: VerifyFile
- (BOOL)VerifyFile: (NSString *)charset 
	path: (NSString *)path;

// method: WriteFile
- (BOOL)WriteFile: (NSString *)path 
	dataBuf: (NSData *)dataBuf;

// method: WriteStringToFile
- (BOOL)WriteStringToFile: (NSString *)str 
	path: (NSString *)path 
	charset: (NSString *)charset;


@end

// Chilkat Objective-C header.
// Generic/internal class name =  HttpResponse
// Wrapped Chilkat C++ class name =  CkHttpResponse



@interface CkoHttpResponse : NSObject {

	@private
		void *m_obj;

}

- (id)init;
- (void)dealloc;
- (void)dispose;
- (NSString *)stringWithUtf8: (const char *)s;
- (void *)CppImplObj;
- (void)setCppImplObj: (void *)pObj;

// property getter: Body
- (NSData *)Body;

// property getter: Body
- (NSMutableData *)BodyMutable;

// property getter: BodyQP
- (NSString *)BodyQP;

// property getter: BodyStr
- (NSString *)BodyStr;

// property getter: Charset
- (NSString *)Charset;

// property getter: ContentLength
- (NSNumber *)ContentLength;

// property getter: Date
- (NSDate *)Date;

// property getter: DateStr
- (NSString *)DateStr;

// property getter: DebugLogFilePath
- (NSString *)DebugLogFilePath;

// property setter: DebugLogFilePath
- (void)setDebugLogFilePath: (NSString *)input;

// property getter: Domain
- (NSString *)Domain;

// property getter: FullMime
- (NSString *)FullMime;

// property getter: Header
- (NSString *)Header;

// property getter: LastErrorHtml
- (NSString *)LastErrorHtml;

// property getter: LastErrorText
- (NSString *)LastErrorText;

// property getter: LastErrorXml
- (NSString *)LastErrorXml;

// property getter: NumCookies
- (NSNumber *)NumCookies;

// property getter: NumHeaderFields
- (NSNumber *)NumHeaderFields;

// property getter: StatusCode
- (NSNumber *)StatusCode;

// property getter: StatusLine
- (NSString *)StatusLine;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// method: GetCookieDomain
- (NSString *)GetCookieDomain: (NSNumber *)index;

// method: GetCookieExpires
- (NSDate *)GetCookieExpires: (NSNumber *)index;

// method: GetCookieExpiresStr
- (NSString *)GetCookieExpiresStr: (NSNumber *)index;

// method: GetCookieName
- (NSString *)GetCookieName: (NSNumber *)index;

// method: GetCookiePath
- (NSString *)GetCookiePath: (NSNumber *)index;

// method: GetCookieValue
- (NSString *)GetCookieValue: (NSNumber *)index;

// method: GetHeaderField
- (NSString *)GetHeaderField: (NSString *)fieldName;

// method: GetHeaderFieldAttr
- (NSString *)GetHeaderFieldAttr: (NSString *)fieldName 
	attrName: (NSString *)attrName;

// method: GetHeaderName
- (NSString *)GetHeaderName: (NSNumber *)index;

// method: GetHeaderValue
- (NSString *)GetHeaderValue: (NSNumber *)index;

// method: SaveBodyBinary
- (BOOL)SaveBodyBinary: (NSString *)path;

// method: SaveBodyText
- (BOOL)SaveBodyText: (BOOL)bCrlf 
	path: (NSString *)path;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: UrlEncParamValue
- (NSString *)UrlEncParamValue: (NSString *)encodedParams 
	paramName: (NSString *)paramName;


@end

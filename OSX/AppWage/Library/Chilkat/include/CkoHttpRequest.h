// Chilkat Objective-C header.
// Generic/internal class name =  HttpRequest
// Wrapped Chilkat C++ class name =  CkHttpRequest



@interface CkoHttpRequest : NSObject {

	@private
		void *m_obj;

}

- (id)init;
- (void)dealloc;
- (void)dispose;
- (NSString *)stringWithUtf8: (const char *)s;
- (void *)CppImplObj;
- (void)setCppImplObj: (void *)pObj;

// property getter: Charset
- (NSString *)Charset;

// property setter: Charset
- (void)setCharset: (NSString *)input;

// property getter: ContentType
- (NSString *)ContentType;

// property setter: ContentType
- (void)setContentType: (NSString *)input;

// property getter: DebugLogFilePath
- (NSString *)DebugLogFilePath;

// property setter: DebugLogFilePath
- (void)setDebugLogFilePath: (NSString *)input;

// property getter: EntireHeader
- (NSString *)EntireHeader;

// property setter: EntireHeader
- (void)setEntireHeader: (NSString *)input;

// property getter: HttpVerb
- (NSString *)HttpVerb;

// property setter: HttpVerb
- (void)setHttpVerb: (NSString *)input;

// property getter: HttpVersion
- (NSString *)HttpVersion;

// property setter: HttpVersion
- (void)setHttpVersion: (NSString *)input;

// property getter: LastErrorHtml
- (NSString *)LastErrorHtml;

// property getter: LastErrorText
- (NSString *)LastErrorText;

// property getter: LastErrorXml
- (NSString *)LastErrorXml;

// property getter: NumHeaderFields
- (NSNumber *)NumHeaderFields;

// property getter: NumParams
- (NSNumber *)NumParams;

// property getter: Path
- (NSString *)Path;

// property setter: Path
- (void)setPath: (NSString *)input;

// property getter: SendCharset
- (BOOL)SendCharset;

// property setter: SendCharset
- (void)setSendCharset: (BOOL)boolVal;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// method: AddBytesForUpload
- (BOOL)AddBytesForUpload: (NSString *)name 
	filename: (NSString *)filename 
	byteData: (NSData *)byteData;

// method: AddBytesForUpload2
- (BOOL)AddBytesForUpload2: (NSString *)name 
	filename: (NSString *)filename 
	byteData: (NSData *)byteData 
	contentType: (NSString *)contentType;

// method: AddFileForUpload
- (BOOL)AddFileForUpload: (NSString *)name 
	path: (NSString *)path;

// method: AddFileForUpload2
- (BOOL)AddFileForUpload2: (NSString *)name 
	path: (NSString *)path 
	contentType: (NSString *)contentType;

// method: AddHeader
- (void)AddHeader: (NSString *)name 
	value: (NSString *)value;

// method: AddParam
- (void)AddParam: (NSString *)name 
	value: (NSString *)value;

// method: AddStringForUpload
- (BOOL)AddStringForUpload: (NSString *)name 
	filename: (NSString *)filename 
	strData: (NSString *)strData 
	charset: (NSString *)charset;

// method: AddStringForUpload2
- (BOOL)AddStringForUpload2: (NSString *)name 
	filename: (NSString *)filename 
	strData: (NSString *)strData 
	charset: (NSString *)charset 
	contentType: (NSString *)contentType;

// method: GenerateRequestText
- (NSString *)GenerateRequestText;

// method: GetHeaderField
- (NSString *)GetHeaderField: (NSString *)name;

// method: GetHeaderName
- (NSString *)GetHeaderName: (NSNumber *)index;

// method: GetHeaderValue
- (NSString *)GetHeaderValue: (NSNumber *)index;

// method: GetParam
- (NSString *)GetParam: (NSString *)name;

// method: GetParamName
- (NSString *)GetParamName: (NSNumber *)index;

// method: GetParamValue
- (NSString *)GetParamValue: (NSNumber *)index;

// method: GetUrlEncodedParams
- (NSString *)GetUrlEncodedParams;

// method: LoadBodyFromBytes
- (BOOL)LoadBodyFromBytes: (NSData *)binaryData;

// method: LoadBodyFromFile
- (BOOL)LoadBodyFromFile: (NSString *)path;

// method: LoadBodyFromString
- (BOOL)LoadBodyFromString: (NSString *)bodyStr 
	charset: (NSString *)charset;

// method: RemoveAllParams
- (void)RemoveAllParams;

// method: RemoveHeader
- (BOOL)RemoveHeader: (NSString *)name;

// method: RemoveParam
- (void)RemoveParam: (NSString *)name;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: SetFromUrl
- (void)SetFromUrl: (NSString *)url;

// method: StreamBodyFromFile
- (BOOL)StreamBodyFromFile: (NSString *)path;

// method: UseGet
- (void)UseGet;

// method: UseHead
- (void)UseHead;

// method: UsePost
- (void)UsePost;

// method: UsePostMultipartForm
- (void)UsePostMultipartForm;

// method: UsePut
- (void)UsePut;

// method: UseUpload
- (void)UseUpload;

// method: UseUploadPut
- (void)UseUploadPut;

// method: UseXmlHttp
- (void)UseXmlHttp: (NSString *)xmlBody;


@end

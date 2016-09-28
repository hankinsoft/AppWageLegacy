// Chilkat Objective-C header.
// Generic/internal class name =  PublicKey
// Wrapped Chilkat C++ class name =  CkPublicKey



@interface CkoPublicKey : NSObject {

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

// method: GetOpenSslDer
- (NSData *)GetOpenSslDer;

// method: GetOpenSslPem
- (NSString *)GetOpenSslPem;

// method: GetRsaDer
- (NSData *)GetRsaDer;

// method: GetXml
- (NSString *)GetXml;

// method: LoadOpenSslDer
- (BOOL)LoadOpenSslDer: (NSData *)data;

// method: LoadOpenSslDerFile
- (BOOL)LoadOpenSslDerFile: (NSString *)path;

// method: LoadOpenSslPem
- (BOOL)LoadOpenSslPem: (NSString *)str;

// method: LoadOpenSslPemFile
- (BOOL)LoadOpenSslPemFile: (NSString *)path;

// method: LoadPkcs1Pem
- (BOOL)LoadPkcs1Pem: (NSString *)str;

// method: LoadRsaDer
- (BOOL)LoadRsaDer: (NSData *)data;

// method: LoadRsaDerFile
- (BOOL)LoadRsaDerFile: (NSString *)path;

// method: LoadXml
- (BOOL)LoadXml: (NSString *)xml;

// method: LoadXmlFile
- (BOOL)LoadXmlFile: (NSString *)path;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: SaveOpenSslDerFile
- (BOOL)SaveOpenSslDerFile: (NSString *)path;

// method: SaveOpenSslPemFile
- (BOOL)SaveOpenSslPemFile: (NSString *)path;

// method: SaveRsaDerFile
- (BOOL)SaveRsaDerFile: (NSString *)path;

// method: SaveXmlFile
- (BOOL)SaveXmlFile: (NSString *)path;


@end

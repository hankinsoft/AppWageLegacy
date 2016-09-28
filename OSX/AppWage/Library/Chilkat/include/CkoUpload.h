// Chilkat Objective-C header.
// Generic/internal class name =  Upload
// Wrapped Chilkat C++ class name =  CkUpload



@interface CkoUpload : NSObject {

	@private
		void *m_obj;

}

- (id)init;
- (void)dealloc;
- (void)dispose;
- (NSString *)stringWithUtf8: (const char *)s;
- (void *)CppImplObj;
- (void)setCppImplObj: (void *)pObj;

// property getter: ChunkSize
- (NSNumber *)ChunkSize;

// property setter: ChunkSize
- (void)setChunkSize: (NSNumber *)intVal;

// property getter: DebugLogFilePath
- (NSString *)DebugLogFilePath;

// property setter: DebugLogFilePath
- (void)setDebugLogFilePath: (NSString *)input;

// property getter: HeartbeatMs
- (NSNumber *)HeartbeatMs;

// property setter: HeartbeatMs
- (void)setHeartbeatMs: (NSNumber *)intVal;

// property getter: Hostname
- (NSString *)Hostname;

// property setter: Hostname
- (void)setHostname: (NSString *)input;

// property getter: IdleTimeoutMs
- (NSNumber *)IdleTimeoutMs;

// property setter: IdleTimeoutMs
- (void)setIdleTimeoutMs: (NSNumber *)intVal;

// property getter: LastErrorHtml
- (NSString *)LastErrorHtml;

// property getter: LastErrorText
- (NSString *)LastErrorText;

// property getter: LastErrorXml
- (NSString *)LastErrorXml;

// property getter: Login
- (NSString *)Login;

// property setter: Login
- (void)setLogin: (NSString *)input;

// property getter: NumBytesSent
- (NSNumber *)NumBytesSent;

// property getter: Password
- (NSString *)Password;

// property setter: Password
- (void)setPassword: (NSString *)input;

// property getter: Path
- (NSString *)Path;

// property setter: Path
- (void)setPath: (NSString *)input;

// property getter: PercentUploaded
- (NSNumber *)PercentUploaded;

// property getter: Port
- (NSNumber *)Port;

// property setter: Port
- (void)setPort: (NSNumber *)intVal;

// property getter: ProxyDomain
- (NSString *)ProxyDomain;

// property setter: ProxyDomain
- (void)setProxyDomain: (NSString *)input;

// property getter: ProxyLogin
- (NSString *)ProxyLogin;

// property setter: ProxyLogin
- (void)setProxyLogin: (NSString *)input;

// property getter: ProxyPassword
- (NSString *)ProxyPassword;

// property setter: ProxyPassword
- (void)setProxyPassword: (NSString *)input;

// property getter: ProxyPort
- (NSNumber *)ProxyPort;

// property setter: ProxyPort
- (void)setProxyPort: (NSNumber *)intVal;

// property getter: ResponseBody
- (NSData *)ResponseBody;

// property getter: ResponseBody
- (NSMutableData *)ResponseBodyMutable;

// property getter: ResponseHeader
- (NSString *)ResponseHeader;

// property getter: ResponseStatus
- (NSNumber *)ResponseStatus;

// property getter: Ssl
- (BOOL)Ssl;

// property setter: Ssl
- (void)setSsl: (BOOL)boolVal;

// property getter: TotalUploadSize
- (NSNumber *)TotalUploadSize;

// property getter: UploadInProgress
- (BOOL)UploadInProgress;

// property getter: UploadSuccess
- (BOOL)UploadSuccess;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// method: AbortUpload
- (void)AbortUpload;

// method: AddCustomHeader
- (void)AddCustomHeader: (NSString *)name 
	value: (NSString *)value;

// method: AddFileReference
- (void)AddFileReference: (NSString *)name 
	path: (NSString *)path;

// method: AddParam
- (void)AddParam: (NSString *)name 
	value: (NSString *)value;

// method: BeginUpload
- (BOOL)BeginUpload;

// method: BlockingUpload
- (BOOL)BlockingUpload;

// method: ClearFileReferences
- (void)ClearFileReferences;

// method: ClearParams
- (void)ClearParams;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: SleepMs
- (void)SleepMs: (NSNumber *)millisec;

// method: UploadToMemory
- (NSData *)UploadToMemory;


@end

// Chilkat Objective-C header.
// Generic/internal class name =  Mht
// Wrapped Chilkat C++ class name =  CkMht

@class CkoEmail;
@class CkoMime;


@interface CkoMht : NSObject {

	@private
		void *m_obj;

}

- (id)init;
- (void)dealloc;
- (void)dispose;
- (NSString *)stringWithUtf8: (const char *)s;
- (void *)CppImplObj;
- (void)setCppImplObj: (void *)pObj;

// property getter: BaseUrl
- (NSString *)BaseUrl;

// property setter: BaseUrl
- (void)setBaseUrl: (NSString *)input;

// property getter: ConnectTimeout
- (NSNumber *)ConnectTimeout;

// property setter: ConnectTimeout
- (void)setConnectTimeout: (NSNumber *)intVal;

// property getter: DebugHtmlAfter
- (NSString *)DebugHtmlAfter;

// property setter: DebugHtmlAfter
- (void)setDebugHtmlAfter: (NSString *)input;

// property getter: DebugHtmlBefore
- (NSString *)DebugHtmlBefore;

// property setter: DebugHtmlBefore
- (void)setDebugHtmlBefore: (NSString *)input;

// property getter: DebugLogFilePath
- (NSString *)DebugLogFilePath;

// property setter: DebugLogFilePath
- (void)setDebugLogFilePath: (NSString *)input;

// property getter: DebugTagCleaning
- (BOOL)DebugTagCleaning;

// property setter: DebugTagCleaning
- (void)setDebugTagCleaning: (BOOL)boolVal;

// property getter: EmbedImages
- (BOOL)EmbedImages;

// property setter: EmbedImages
- (void)setEmbedImages: (BOOL)boolVal;

// property getter: EmbedLocalOnly
- (BOOL)EmbedLocalOnly;

// property setter: EmbedLocalOnly
- (void)setEmbedLocalOnly: (BOOL)boolVal;

// property getter: FetchFromCache
- (BOOL)FetchFromCache;

// property setter: FetchFromCache
- (void)setFetchFromCache: (BOOL)boolVal;

// property getter: HeartbeatMs
- (NSNumber *)HeartbeatMs;

// property setter: HeartbeatMs
- (void)setHeartbeatMs: (NSNumber *)intVal;

// property getter: IgnoreMustRevalidate
- (BOOL)IgnoreMustRevalidate;

// property setter: IgnoreMustRevalidate
- (void)setIgnoreMustRevalidate: (BOOL)boolVal;

// property getter: IgnoreNoCache
- (BOOL)IgnoreNoCache;

// property setter: IgnoreNoCache
- (void)setIgnoreNoCache: (BOOL)boolVal;

// property getter: LastErrorHtml
- (NSString *)LastErrorHtml;

// property getter: LastErrorText
- (NSString *)LastErrorText;

// property getter: LastErrorXml
- (NSString *)LastErrorXml;

// property getter: NoScripts
- (BOOL)NoScripts;

// property setter: NoScripts
- (void)setNoScripts: (BOOL)boolVal;

// property getter: NtlmAuth
- (BOOL)NtlmAuth;

// property setter: NtlmAuth
- (void)setNtlmAuth: (BOOL)boolVal;

// property getter: NumCacheLevels
- (NSNumber *)NumCacheLevels;

// property setter: NumCacheLevels
- (void)setNumCacheLevels: (NSNumber *)intVal;

// property getter: NumCacheRoots
- (NSNumber *)NumCacheRoots;

// property getter: PreferMHTScripts
- (BOOL)PreferMHTScripts;

// property setter: PreferMHTScripts
- (void)setPreferMHTScripts: (BOOL)boolVal;

// property getter: Proxy
- (NSString *)Proxy;

// property setter: Proxy
- (void)setProxy: (NSString *)input;

// property getter: ProxyLogin
- (NSString *)ProxyLogin;

// property setter: ProxyLogin
- (void)setProxyLogin: (NSString *)input;

// property getter: ProxyPassword
- (NSString *)ProxyPassword;

// property setter: ProxyPassword
- (void)setProxyPassword: (NSString *)input;

// property getter: ReadTimeout
- (NSNumber *)ReadTimeout;

// property setter: ReadTimeout
- (void)setReadTimeout: (NSNumber *)intVal;

// property getter: SocksHostname
- (NSString *)SocksHostname;

// property setter: SocksHostname
- (void)setSocksHostname: (NSString *)input;

// property getter: SocksPassword
- (NSString *)SocksPassword;

// property setter: SocksPassword
- (void)setSocksPassword: (NSString *)input;

// property getter: SocksPort
- (NSNumber *)SocksPort;

// property setter: SocksPort
- (void)setSocksPort: (NSNumber *)intVal;

// property getter: SocksUsername
- (NSString *)SocksUsername;

// property setter: SocksUsername
- (void)setSocksUsername: (NSString *)input;

// property getter: SocksVersion
- (NSNumber *)SocksVersion;

// property setter: SocksVersion
- (void)setSocksVersion: (NSNumber *)intVal;

// property getter: UnpackUseRelPaths
- (BOOL)UnpackUseRelPaths;

// property setter: UnpackUseRelPaths
- (void)setUnpackUseRelPaths: (BOOL)boolVal;

// property getter: UpdateCache
- (BOOL)UpdateCache;

// property setter: UpdateCache
- (void)setUpdateCache: (BOOL)boolVal;

// property getter: UseCids
- (BOOL)UseCids;

// property setter: UseCids
- (void)setUseCids: (BOOL)boolVal;

// property getter: UseFilename
- (BOOL)UseFilename;

// property setter: UseFilename
- (void)setUseFilename: (BOOL)boolVal;

// property getter: UseIEProxy
- (BOOL)UseIEProxy;

// property setter: UseIEProxy
- (void)setUseIEProxy: (BOOL)boolVal;

// property getter: UseInline
- (BOOL)UseInline;

// property setter: UseInline
- (void)setUseInline: (BOOL)boolVal;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// property getter: WebSiteLogin
- (NSString *)WebSiteLogin;

// property setter: WebSiteLogin
- (void)setWebSiteLogin: (NSString *)input;

// property getter: WebSiteLoginDomain
- (NSString *)WebSiteLoginDomain;

// property setter: WebSiteLoginDomain
- (void)setWebSiteLoginDomain: (NSString *)input;

// property getter: WebSitePassword
- (NSString *)WebSitePassword;

// property setter: WebSitePassword
- (void)setWebSitePassword: (NSString *)input;

// method: AddCacheRoot
- (void)AddCacheRoot: (NSString *)dir;

// method: AddCustomHeader
- (void)AddCustomHeader: (NSString *)name 
	value: (NSString *)value;

// method: AddExternalStyleSheet
- (void)AddExternalStyleSheet: (NSString *)url;

// method: ClearCustomHeaders
- (void)ClearCustomHeaders;

// method: ExcludeImagesMatching
- (void)ExcludeImagesMatching: (NSString *)pattern;

// method: GetAndSaveEML
- (BOOL)GetAndSaveEML: (NSString *)url 
	emlPath: (NSString *)emlPath;

// method: GetAndSaveMHT
- (BOOL)GetAndSaveMHT: (NSString *)url 
	mhtPath: (NSString *)mhtPath;

// method: GetAndZipEML
- (BOOL)GetAndZipEML: (NSString *)url 
	zipEntryFilename: (NSString *)zipEntryFilename 
	zipPath: (NSString *)zipPath;

// method: GetAndZipMHT
- (BOOL)GetAndZipMHT: (NSString *)url 
	zipEntryFilename: (NSString *)zipEntryFilename 
	zipPath: (NSString *)zipPath;

// method: GetCacheRoot
- (NSString *)GetCacheRoot: (NSNumber *)index;

// method: GetEML
- (NSString *)GetEML: (NSString *)url;

// method: GetEmail
- (CkoEmail *)GetEmail: (NSString *)url;

// method: GetMHT
- (NSString *)GetMHT: (NSString *)url;

// method: GetMime
- (CkoMime *)GetMime: (NSString *)url;

// method: HtmlToEML
- (NSString *)HtmlToEML: (NSString *)htmlText;

// method: HtmlToEMLFile
- (BOOL)HtmlToEMLFile: (NSString *)html 
	emlPath: (NSString *)emlPath;

// method: HtmlToEmail
- (CkoEmail *)HtmlToEmail: (NSString *)htmlText;

// method: HtmlToMHT
- (NSString *)HtmlToMHT: (NSString *)htmlText;

// method: HtmlToMHTFile
- (BOOL)HtmlToMHTFile: (NSString *)html 
	mhtPath: (NSString *)mhtPath;

// method: IsUnlocked
- (BOOL)IsUnlocked;

// method: RemoveCustomHeader
- (void)RemoveCustomHeader: (NSString *)name;

// method: RestoreDefaults
- (void)RestoreDefaults;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: UnlockComponent
- (BOOL)UnlockComponent: (NSString *)unlockCode;

// method: UnpackMHT
- (BOOL)UnpackMHT: (NSString *)mhtPath 
	unpackDir: (NSString *)unpackDir 
	htmlFilename: (NSString *)htmlFilename 
	partsSubDir: (NSString *)partsSubDir;

// method: UnpackMHTString
- (BOOL)UnpackMHTString: (NSString *)mhtContents 
	unpackDir: (NSString *)unpackDir 
	htmlFilename: (NSString *)htmlFilename 
	partsSubDir: (NSString *)partsSubDir;


@end

// Chilkat Objective-C header.
// Generic/internal class name =  Spider
// Wrapped Chilkat C++ class name =  CkSpider



@interface CkoSpider : NSObject {

	@private
		void *m_obj;

}

- (id)init;
- (void)dealloc;
- (void)dispose;
- (NSString *)stringWithUtf8: (const char *)s;
- (void *)CppImplObj;
- (void)setCppImplObj: (void *)pObj;

// property getter: AvoidHttps
- (BOOL)AvoidHttps;

// property setter: AvoidHttps
- (void)setAvoidHttps: (BOOL)boolVal;

// property getter: CacheDir
- (NSString *)CacheDir;

// property setter: CacheDir
- (void)setCacheDir: (NSString *)input;

// property getter: ChopAtQuery
- (BOOL)ChopAtQuery;

// property setter: ChopAtQuery
- (void)setChopAtQuery: (BOOL)boolVal;

// property getter: ConnectTimeout
- (NSNumber *)ConnectTimeout;

// property setter: ConnectTimeout
- (void)setConnectTimeout: (NSNumber *)intVal;

// property getter: DebugLogFilePath
- (NSString *)DebugLogFilePath;

// property setter: DebugLogFilePath
- (void)setDebugLogFilePath: (NSString *)input;

// property getter: Domain
- (NSString *)Domain;

// property getter: FetchFromCache
- (BOOL)FetchFromCache;

// property setter: FetchFromCache
- (void)setFetchFromCache: (BOOL)boolVal;

// property getter: HeartbeatMs
- (NSNumber *)HeartbeatMs;

// property setter: HeartbeatMs
- (void)setHeartbeatMs: (NSNumber *)intVal;

// property getter: LastErrorHtml
- (NSString *)LastErrorHtml;

// property getter: LastErrorText
- (NSString *)LastErrorText;

// property getter: LastErrorXml
- (NSString *)LastErrorXml;

// property getter: LastFromCache
- (BOOL)LastFromCache;

// property getter: LastHtml
- (NSString *)LastHtml;

// property getter: LastHtmlDescription
- (NSString *)LastHtmlDescription;

// property getter: LastHtmlKeywords
- (NSString *)LastHtmlKeywords;

// property getter: LastHtmlTitle
- (NSString *)LastHtmlTitle;

// property getter: LastModDate
- (NSDate *)LastModDate;

// property getter: LastModDateStr
- (NSString *)LastModDateStr;

// property getter: LastUrl
- (NSString *)LastUrl;

// property getter: MaxResponseSize
- (NSNumber *)MaxResponseSize;

// property setter: MaxResponseSize
- (void)setMaxResponseSize: (NSNumber *)intVal;

// property getter: MaxUrlLen
- (NSNumber *)MaxUrlLen;

// property setter: MaxUrlLen
- (void)setMaxUrlLen: (NSNumber *)intVal;

// property getter: NumAvoidPatterns
- (NSNumber *)NumAvoidPatterns;

// property getter: NumFailed
- (NSNumber *)NumFailed;

// property getter: NumOutboundLinks
- (NSNumber *)NumOutboundLinks;

// property getter: NumSpidered
- (NSNumber *)NumSpidered;

// property getter: NumUnspidered
- (NSNumber *)NumUnspidered;

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

// property getter: ReadTimeout
- (NSNumber *)ReadTimeout;

// property setter: ReadTimeout
- (void)setReadTimeout: (NSNumber *)intVal;

// property getter: UpdateCache
- (BOOL)UpdateCache;

// property setter: UpdateCache
- (void)setUpdateCache: (BOOL)boolVal;

// property getter: UserAgent
- (NSString *)UserAgent;

// property setter: UserAgent
- (void)setUserAgent: (NSString *)input;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// property getter: WindDownCount
- (NSNumber *)WindDownCount;

// property setter: WindDownCount
- (void)setWindDownCount: (NSNumber *)intVal;

// method: AddAvoidOutboundLinkPattern
- (void)AddAvoidOutboundLinkPattern: (NSString *)pattern;

// method: AddAvoidPattern
- (void)AddAvoidPattern: (NSString *)pattern;

// method: AddMustMatchPattern
- (void)AddMustMatchPattern: (NSString *)pattern;

// method: AddUnspidered
- (void)AddUnspidered: (NSString *)url;

// method: CanonicalizeUrl
- (NSString *)CanonicalizeUrl: (NSString *)url;

// method: ClearFailedUrls
- (void)ClearFailedUrls;

// method: ClearOutboundLinks
- (void)ClearOutboundLinks;

// method: ClearSpideredUrls
- (void)ClearSpideredUrls;

// method: CrawlNext
- (BOOL)CrawlNext;

// method: FetchRobotsText
- (NSString *)FetchRobotsText;

// method: GetAvoidPattern
- (NSString *)GetAvoidPattern: (NSNumber *)index;

// method: GetBaseDomain
- (NSString *)GetBaseDomain: (NSString *)domain;

// method: GetFailedUrl
- (NSString *)GetFailedUrl: (NSNumber *)index;

// method: GetOutboundLink
- (NSString *)GetOutboundLink: (NSNumber *)index;

// method: GetSpideredUrl
- (NSString *)GetSpideredUrl: (NSNumber *)index;

// method: GetUnspideredUrl
- (NSString *)GetUnspideredUrl: (NSNumber *)index;

// method: GetUrlDomain
- (NSString *)GetUrlDomain: (NSString *)url;

// method: Initialize
- (void)Initialize: (NSString *)domain;

// method: RecrawlLast
- (BOOL)RecrawlLast;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: SkipUnspidered
- (void)SkipUnspidered: (NSNumber *)index;

// method: SleepMs
- (void)SleepMs: (NSNumber *)millisec;


@end

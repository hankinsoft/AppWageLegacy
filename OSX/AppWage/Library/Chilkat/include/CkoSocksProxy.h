// Chilkat Objective-C header.
// Generic/internal class name =  SocksProxy
// Wrapped Chilkat C++ class name =  CkSocksProxy



@interface CkoSocksProxy : NSObject {

	@private
		void *m_obj;

}

- (id)init;
- (void)dealloc;
- (void)dispose;
- (NSString *)stringWithUtf8: (const char *)s;
- (void *)CppImplObj;
- (void)setCppImplObj: (void *)pObj;

// property getter: AllowUnauthenticatedSocks5
- (BOOL)AllowUnauthenticatedSocks5;

// property setter: AllowUnauthenticatedSocks5
- (void)setAllowUnauthenticatedSocks5: (BOOL)boolVal;

// property getter: AuthenticatedSocks5
- (BOOL)AuthenticatedSocks5;

// property getter: ClientIp
- (NSString *)ClientIp;

// property getter: ClientPort
- (NSNumber *)ClientPort;

// property getter: ConnectionPending
- (BOOL)ConnectionPending;

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

// property getter: ListenBindIpAddress
- (NSString *)ListenBindIpAddress;

// property setter: ListenBindIpAddress
- (void)setListenBindIpAddress: (NSString *)input;

// property getter: Login
- (NSString *)Login;

// property getter: OutboundBindIpAddress
- (NSString *)OutboundBindIpAddress;

// property setter: OutboundBindIpAddress
- (void)setOutboundBindIpAddress: (NSString *)input;

// property getter: OutboundBindPort
- (NSNumber *)OutboundBindPort;

// property setter: OutboundBindPort
- (void)setOutboundBindPort: (NSNumber *)intVal;

// property getter: Password
- (NSString *)Password;

// property getter: ServerIp
- (NSString *)ServerIp;

// property getter: ServerPort
- (NSNumber *)ServerPort;

// property getter: SocksVersion
- (NSNumber *)SocksVersion;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// method: AllowConnection
- (BOOL)AllowConnection;

// method: GetTunnelsXml
- (NSString *)GetTunnelsXml;

// method: Initialize
- (BOOL)Initialize: (NSNumber *)port;

// method: ProceedSocks5
- (BOOL)ProceedSocks5;

// method: RejectConnection
- (BOOL)RejectConnection;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: StopAllTunnels
- (BOOL)StopAllTunnels: (NSNumber *)maxWaitMs;

// method: UnlockComponent
- (BOOL)UnlockComponent: (NSString *)unlockCode;

// method: WaitForConnection
- (BOOL)WaitForConnection: (NSNumber *)maxWaitMs;


@end

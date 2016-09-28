// Chilkat Objective-C header.
// Generic/internal class name =  SshTunnel
// Wrapped Chilkat C++ class name =  CkSshTunnel

@class CkoSshKey;


@interface CkoSshTunnel : NSObject {

	@private
		void *m_obj;

}

- (id)init;
- (void)dealloc;
- (void)dispose;
- (NSString *)stringWithUtf8: (const char *)s;
- (void *)CppImplObj;
- (void)setCppImplObj: (void *)pObj;

// property getter: AcceptThreadSessionLogPath
- (NSString *)AcceptThreadSessionLogPath;

// property setter: AcceptThreadSessionLogPath
- (void)setAcceptThreadSessionLogPath: (NSString *)input;

// property getter: ConnectLog
- (NSString *)ConnectLog;

// property setter: ConnectLog
- (void)setConnectLog: (NSString *)input;

// property getter: ConnectTimeoutMs
- (NSNumber *)ConnectTimeoutMs;

// property setter: ConnectTimeoutMs
- (void)setConnectTimeoutMs: (NSNumber *)intVal;

// property getter: DebugLogFilePath
- (NSString *)DebugLogFilePath;

// property setter: DebugLogFilePath
- (void)setDebugLogFilePath: (NSString *)input;

// property getter: DestHostname
- (NSString *)DestHostname;

// property setter: DestHostname
- (void)setDestHostname: (NSString *)input;

// property getter: DestPort
- (NSNumber *)DestPort;

// property setter: DestPort
- (void)setDestPort: (NSNumber *)intVal;

// property getter: HttpProxyAuthMethod
- (NSString *)HttpProxyAuthMethod;

// property setter: HttpProxyAuthMethod
- (void)setHttpProxyAuthMethod: (NSString *)input;

// property getter: HttpProxyDomain
- (NSString *)HttpProxyDomain;

// property setter: HttpProxyDomain
- (void)setHttpProxyDomain: (NSString *)input;

// property getter: HttpProxyHostname
- (NSString *)HttpProxyHostname;

// property setter: HttpProxyHostname
- (void)setHttpProxyHostname: (NSString *)input;

// property getter: HttpProxyPassword
- (NSString *)HttpProxyPassword;

// property setter: HttpProxyPassword
- (void)setHttpProxyPassword: (NSString *)input;

// property getter: HttpProxyPort
- (NSNumber *)HttpProxyPort;

// property setter: HttpProxyPort
- (void)setHttpProxyPort: (NSNumber *)intVal;

// property getter: HttpProxyUsername
- (NSString *)HttpProxyUsername;

// property setter: HttpProxyUsername
- (void)setHttpProxyUsername: (NSString *)input;

// property getter: IdleTimeoutMs
- (NSNumber *)IdleTimeoutMs;

// property setter: IdleTimeoutMs
- (void)setIdleTimeoutMs: (NSNumber *)intVal;

// property getter: IsAccepting
- (BOOL)IsAccepting;

// property getter: KeepConnectLog
- (BOOL)KeepConnectLog;

// property setter: KeepConnectLog
- (void)setKeepConnectLog: (BOOL)boolVal;

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

// property getter: ListenPort
- (NSNumber *)ListenPort;

// property getter: MaxPacketSize
- (NSNumber *)MaxPacketSize;

// property setter: MaxPacketSize
- (void)setMaxPacketSize: (NSNumber *)intVal;

// property getter: OutboundBindIpAddress
- (NSString *)OutboundBindIpAddress;

// property setter: OutboundBindIpAddress
- (void)setOutboundBindIpAddress: (NSString *)input;

// property getter: OutboundBindPort
- (NSNumber *)OutboundBindPort;

// property setter: OutboundBindPort
- (void)setOutboundBindPort: (NSNumber *)intVal;

// property getter: SoRcvBuf
- (NSNumber *)SoRcvBuf;

// property setter: SoRcvBuf
- (void)setSoRcvBuf: (NSNumber *)intVal;

// property getter: SoSndBuf
- (NSNumber *)SoSndBuf;

// property setter: SoSndBuf
- (void)setSoSndBuf: (NSNumber *)intVal;

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

// property getter: SshHostname
- (NSString *)SshHostname;

// property setter: SshHostname
- (void)setSshHostname: (NSString *)input;

// property getter: SshLogin
- (NSString *)SshLogin;

// property setter: SshLogin
- (void)setSshLogin: (NSString *)input;

// property getter: SshPassword
- (NSString *)SshPassword;

// property setter: SshPassword
- (void)setSshPassword: (NSString *)input;

// property getter: SshPort
- (NSNumber *)SshPort;

// property setter: SshPort
- (void)setSshPort: (NSNumber *)intVal;

// property getter: TcpNoDelay
- (BOOL)TcpNoDelay;

// property setter: TcpNoDelay
- (void)setTcpNoDelay: (BOOL)boolVal;

// property getter: TunnelErrors
- (NSString *)TunnelErrors;

// property getter: TunnelThreadSessionLogPath
- (NSString *)TunnelThreadSessionLogPath;

// property setter: TunnelThreadSessionLogPath
- (void)setTunnelThreadSessionLogPath: (NSString *)input;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// method: BeginAccepting
- (BOOL)BeginAccepting: (NSNumber *)listenPort;

// method: ClearTunnelErrors
- (void)ClearTunnelErrors;

// method: GetTunnelsXml
- (NSString *)GetTunnelsXml;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: SetSshAuthenticationKey
- (BOOL)SetSshAuthenticationKey: (CkoSshKey *)key;

// method: StopAccepting
- (BOOL)StopAccepting;

// method: StopAllTunnels
- (BOOL)StopAllTunnels: (NSNumber *)maxWaitMs;

// method: UnlockComponent
- (BOOL)UnlockComponent: (NSString *)unlockCode;


@end

// Chilkat Objective-C header.
// Generic/internal class name =  Ssh
// Wrapped Chilkat C++ class name =  CkSsh

@class CkoSshKey;
@class CkoStringArray;


@class CkoSshProgress;

@interface CkoSsh : NSObject {

	@private
		void *m_eventCallback;
		void *m_obj;

}

- (id)init;
- (void)dealloc;
- (void)dispose;
- (NSString *)stringWithUtf8: (const char *)s;
- (void *)CppImplObj;
- (void)setCppImplObj: (void *)pObj;

// property setter: EventCallbackObject
- (void)setEventCallbackObject: (CkoSshProgress *)eventObj;

// property getter: ChannelOpenFailCode
- (NSNumber *)ChannelOpenFailCode;

// property getter: ChannelOpenFailReason
- (NSString *)ChannelOpenFailReason;

// property getter: ClientIdentifier
- (NSString *)ClientIdentifier;

// property setter: ClientIdentifier
- (void)setClientIdentifier: (NSString *)input;

// property getter: ClientIpAddress
- (NSString *)ClientIpAddress;

// property setter: ClientIpAddress
- (void)setClientIpAddress: (NSString *)input;

// property getter: ConnectTimeoutMs
- (NSNumber *)ConnectTimeoutMs;

// property setter: ConnectTimeoutMs
- (void)setConnectTimeoutMs: (NSNumber *)intVal;

// property getter: DebugLogFilePath
- (NSString *)DebugLogFilePath;

// property setter: DebugLogFilePath
- (void)setDebugLogFilePath: (NSString *)input;

// property getter: DisconnectCode
- (NSNumber *)DisconnectCode;

// property getter: DisconnectReason
- (NSString *)DisconnectReason;

// property getter: ForceCipher
- (NSString *)ForceCipher;

// property setter: ForceCipher
- (void)setForceCipher: (NSString *)input;

// property getter: HeartbeatMs
- (NSNumber *)HeartbeatMs;

// property setter: HeartbeatMs
- (void)setHeartbeatMs: (NSNumber *)intVal;

// property getter: HostKeyAlg
- (NSString *)HostKeyAlg;

// property setter: HostKeyAlg
- (void)setHostKeyAlg: (NSString *)input;

// property getter: HostKeyFingerprint
- (NSString *)HostKeyFingerprint;

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

// property getter: IsConnected
- (BOOL)IsConnected;

// property getter: KeepSessionLog
- (BOOL)KeepSessionLog;

// property setter: KeepSessionLog
- (void)setKeepSessionLog: (BOOL)boolVal;

// property getter: LastErrorHtml
- (NSString *)LastErrorHtml;

// property getter: LastErrorText
- (NSString *)LastErrorText;

// property getter: LastErrorXml
- (NSString *)LastErrorXml;

// property getter: MaxPacketSize
- (NSNumber *)MaxPacketSize;

// property setter: MaxPacketSize
- (void)setMaxPacketSize: (NSNumber *)intVal;

// property getter: NumOpenChannels
- (NSNumber *)NumOpenChannels;

// property getter: PasswordChangeRequested
- (BOOL)PasswordChangeRequested;

// property getter: ReadTimeoutMs
- (NSNumber *)ReadTimeoutMs;

// property setter: ReadTimeoutMs
- (void)setReadTimeoutMs: (NSNumber *)intVal;

// property getter: SessionLog
- (NSString *)SessionLog;

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

// property getter: StderrToStdout
- (BOOL)StderrToStdout;

// property setter: StderrToStdout
- (void)setStderrToStdout: (BOOL)boolVal;

// property getter: TcpNoDelay
- (BOOL)TcpNoDelay;

// property setter: TcpNoDelay
- (void)setTcpNoDelay: (BOOL)boolVal;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// method: AuthenticatePk
- (BOOL)AuthenticatePk: (NSString *)username 
	privateKey: (CkoSshKey *)privateKey;

// method: AuthenticatePw
- (BOOL)AuthenticatePw: (NSString *)login 
	password: (NSString *)password;

// method: AuthenticatePwPk
- (BOOL)AuthenticatePwPk: (NSString *)username 
	password: (NSString *)password 
	privateKey: (CkoSshKey *)privateKey;

// method: ChannelIsOpen
- (BOOL)ChannelIsOpen: (NSNumber *)channelNum;

// method: ChannelPoll
- (NSNumber *)ChannelPoll: (NSNumber *)channelNum 
	pollTimeoutMs: (NSNumber *)pollTimeoutMs;

// method: ChannelRead
- (NSNumber *)ChannelRead: (NSNumber *)channelNum;

// method: ChannelReadAndPoll
- (NSNumber *)ChannelReadAndPoll: (NSNumber *)channelNum 
	pollTimeoutMs: (NSNumber *)pollTimeoutMs;

// method: ChannelReadAndPoll2
- (NSNumber *)ChannelReadAndPoll2: (NSNumber *)channelNum 
	pollTimeoutMs: (NSNumber *)pollTimeoutMs 
	maxNumBytes: (NSNumber *)maxNumBytes;

// method: ChannelReceiveToClose
- (BOOL)ChannelReceiveToClose: (NSNumber *)channelNum;

// method: ChannelReceiveUntilMatch
- (BOOL)ChannelReceiveUntilMatch: (NSNumber *)channelNum 
	matchPattern: (NSString *)matchPattern 
	charset: (NSString *)charset 
	caseSensitive: (BOOL)caseSensitive;

// method: ChannelReceiveUntilMatchN
- (BOOL)ChannelReceiveUntilMatchN: (NSNumber *)channelNum 
	matchPatterns: (CkoStringArray *)matchPatterns 
	charset: (NSString *)charset 
	caseSensitive: (BOOL)caseSensitive;

// method: ChannelReceivedClose
- (BOOL)ChannelReceivedClose: (NSNumber *)channelNum;

// method: ChannelReceivedEof
- (BOOL)ChannelReceivedEof: (NSNumber *)channelNum;

// method: ChannelReceivedExitStatus
- (BOOL)ChannelReceivedExitStatus: (NSNumber *)channelNum;

// method: ChannelSendClose
- (BOOL)ChannelSendClose: (NSNumber *)channelNum;

// method: ChannelSendData
- (BOOL)ChannelSendData: (NSNumber *)channelNum 
	data: (NSData *)data;

// method: ChannelSendEof
- (BOOL)ChannelSendEof: (NSNumber *)channelNum;

// method: ChannelSendString
- (BOOL)ChannelSendString: (NSNumber *)channelNum 
	strData: (NSString *)strData 
	charset: (NSString *)charset;

// method: ClearTtyModes
- (void)ClearTtyModes;

// method: Connect
- (BOOL)Connect: (NSString *)hostname 
	port: (NSNumber *)port;

// method: Disconnect
- (void)Disconnect;

// method: GetChannelExitStatus
- (NSNumber *)GetChannelExitStatus: (NSNumber *)channelNum;

// method: GetChannelNumber
- (NSNumber *)GetChannelNumber: (NSNumber *)index;

// method: GetChannelType
- (NSString *)GetChannelType: (NSNumber *)index;

// method: GetReceivedData
- (NSData *)GetReceivedData: (NSNumber *)channelNum;

// method: GetReceivedDataN
- (NSData *)GetReceivedDataN: (NSNumber *)channelNum 
	numBytes: (NSNumber *)numBytes;

// method: GetReceivedNumBytes
- (NSNumber *)GetReceivedNumBytes: (NSNumber *)channelNum;

// method: GetReceivedStderr
- (NSData *)GetReceivedStderr: (NSNumber *)channelNum;

// method: GetReceivedText
- (NSString *)GetReceivedText: (NSNumber *)channelNum 
	charset: (NSString *)charset;

// method: GetReceivedTextS
- (NSString *)GetReceivedTextS: (NSNumber *)channelNum 
	substr: (NSString *)substr 
	charset: (NSString *)charset;

// method: OpenCustomChannel
- (NSNumber *)OpenCustomChannel: (NSString *)channelType;

// method: OpenDirectTcpIpChannel
- (NSNumber *)OpenDirectTcpIpChannel: (NSString *)hostname 
	port: (NSNumber *)port;

// method: OpenSessionChannel
- (NSNumber *)OpenSessionChannel;

// method: PeekReceivedText
- (NSString *)PeekReceivedText: (NSNumber *)channelNum 
	charset: (NSString *)charset;

// method: ReKey
- (BOOL)ReKey;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: SendIgnore
- (BOOL)SendIgnore;

// method: SendReqExec
- (BOOL)SendReqExec: (NSNumber *)channelNum 
	command: (NSString *)command;

// method: SendReqPty
- (BOOL)SendReqPty: (NSNumber *)channelNum 
	xTermEnvVar: (NSString *)xTermEnvVar 
	widthInChars: (NSNumber *)widthInChars 
	heightInRows: (NSNumber *)heightInRows 
	pixWidth: (NSNumber *)pixWidth 
	pixHeight: (NSNumber *)pixHeight;

// method: SendReqSetEnv
- (BOOL)SendReqSetEnv: (NSNumber *)channelNum 
	name: (NSString *)name 
	value: (NSString *)value;

// method: SendReqShell
- (BOOL)SendReqShell: (NSNumber *)channelNum;

// method: SendReqSignal
- (BOOL)SendReqSignal: (NSNumber *)channelNum 
	signalName: (NSString *)signalName;

// method: SendReqSubsystem
- (BOOL)SendReqSubsystem: (NSNumber *)channelNum 
	subsystemName: (NSString *)subsystemName;

// method: SendReqWindowChange
- (BOOL)SendReqWindowChange: (NSNumber *)channelNum 
	widthInChars: (NSNumber *)widthInChars 
	heightInRows: (NSNumber *)heightInRows 
	pixWidth: (NSNumber *)pixWidth 
	pixHeight: (NSNumber *)pixHeight;

// method: SendReqX11Forwarding
- (BOOL)SendReqX11Forwarding: (NSNumber *)channelNum 
	singleConnection: (BOOL)singleConnection 
	authProt: (NSString *)authProt 
	authCookie: (NSString *)authCookie 
	screenNum: (NSNumber *)screenNum;

// method: SendReqXonXoff
- (BOOL)SendReqXonXoff: (NSNumber *)channelNum 
	clientCanDo: (BOOL)clientCanDo;

// method: SetTtyMode
- (BOOL)SetTtyMode: (NSString *)name 
	value: (NSNumber *)value;

// method: UnlockComponent
- (BOOL)UnlockComponent: (NSString *)unlockCode;


@end

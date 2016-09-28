// Chilkat Objective-C header.
// Generic/internal class name =  MailMan
// Wrapped Chilkat C++ class name =  CkMailMan

@class CkoEmailBundle;
@class CkoEmail;
@class CkoStringArray;
@class CkoCert;
@class CkoPrivateKey;
@class CkoSshKey;


@class CkoMailManProgress;

@interface CkoMailMan : NSObject {

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
- (void)setEventCallbackObject: (CkoMailManProgress *)eventObj;

// property getter: AllOrNone
- (BOOL)AllOrNone;

// property setter: AllOrNone
- (void)setAllOrNone: (BOOL)boolVal;

// property getter: AutoFix
- (BOOL)AutoFix;

// property setter: AutoFix
- (void)setAutoFix: (BOOL)boolVal;

// property getter: AutoGenMessageId
- (BOOL)AutoGenMessageId;

// property setter: AutoGenMessageId
- (void)setAutoGenMessageId: (BOOL)boolVal;

// property getter: AutoSmtpRset
- (BOOL)AutoSmtpRset;

// property setter: AutoSmtpRset
- (void)setAutoSmtpRset: (BOOL)boolVal;

// property getter: ClientIpAddress
- (NSString *)ClientIpAddress;

// property setter: ClientIpAddress
- (void)setClientIpAddress: (NSString *)input;

// property getter: ConnectTimeout
- (NSNumber *)ConnectTimeout;

// property setter: ConnectTimeout
- (void)setConnectTimeout: (NSNumber *)intVal;

// property getter: DebugLogFilePath
- (NSString *)DebugLogFilePath;

// property setter: DebugLogFilePath
- (void)setDebugLogFilePath: (NSString *)input;

// property getter: DsnEnvid
- (NSString *)DsnEnvid;

// property setter: DsnEnvid
- (void)setDsnEnvid: (NSString *)input;

// property getter: DsnNotify
- (NSString *)DsnNotify;

// property setter: DsnNotify
- (void)setDsnNotify: (NSString *)input;

// property getter: DsnRet
- (NSString *)DsnRet;

// property setter: DsnRet
- (void)setDsnRet: (NSString *)input;

// property getter: EmbedCertChain
- (BOOL)EmbedCertChain;

// property setter: EmbedCertChain
- (void)setEmbedCertChain: (BOOL)boolVal;

// property getter: Filter
- (NSString *)Filter;

// property setter: Filter
- (void)setFilter: (NSString *)input;

// property getter: HeartbeatMs
- (NSNumber *)HeartbeatMs;

// property setter: HeartbeatMs
- (void)setHeartbeatMs: (NSNumber *)intVal;

// property getter: HeloHostname
- (NSString *)HeloHostname;

// property setter: HeloHostname
- (void)setHeloHostname: (NSString *)input;

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

// property getter: ImmediateDelete
- (BOOL)ImmediateDelete;

// property setter: ImmediateDelete
- (void)setImmediateDelete: (BOOL)boolVal;

// property getter: IncludeRootCert
- (BOOL)IncludeRootCert;

// property setter: IncludeRootCert
- (void)setIncludeRootCert: (BOOL)boolVal;

// property getter: IsSmtpConnected
- (BOOL)IsSmtpConnected;

// property getter: LastErrorHtml
- (NSString *)LastErrorHtml;

// property getter: LastErrorText
- (NSString *)LastErrorText;

// property getter: LastErrorXml
- (NSString *)LastErrorXml;

// property getter: LastSendQFilename
- (NSString *)LastSendQFilename;

// property getter: LastSmtpStatus
- (NSNumber *)LastSmtpStatus;

// property getter: LogMailReceivedFilename
- (NSString *)LogMailReceivedFilename;

// property setter: LogMailReceivedFilename
- (void)setLogMailReceivedFilename: (NSString *)input;

// property getter: LogMailSentFilename
- (NSString *)LogMailSentFilename;

// property setter: LogMailSentFilename
- (void)setLogMailSentFilename: (NSString *)input;

// property getter: MailHost
- (NSString *)MailHost;

// property setter: MailHost
- (void)setMailHost: (NSString *)input;

// property getter: MailPort
- (NSNumber *)MailPort;

// property setter: MailPort
- (void)setMailPort: (NSNumber *)intVal;

// property getter: MaxCount
- (NSNumber *)MaxCount;

// property setter: MaxCount
- (void)setMaxCount: (NSNumber *)intVal;

// property getter: OpaqueSigning
- (BOOL)OpaqueSigning;

// property setter: OpaqueSigning
- (void)setOpaqueSigning: (BOOL)boolVal;

// property getter: Pop3SPA
- (BOOL)Pop3SPA;

// property setter: Pop3SPA
- (void)setPop3SPA: (BOOL)boolVal;

// property getter: Pop3SessionId
- (NSNumber *)Pop3SessionId;

// property getter: Pop3SessionLog
- (NSString *)Pop3SessionLog;

// property getter: Pop3SslServerCertVerified
- (BOOL)Pop3SslServerCertVerified;

// property getter: Pop3Stls
- (BOOL)Pop3Stls;

// property setter: Pop3Stls
- (void)setPop3Stls: (BOOL)boolVal;

// property getter: PopPassword
- (NSString *)PopPassword;

// property setter: PopPassword
- (void)setPopPassword: (NSString *)input;

// property getter: PopSsl
- (BOOL)PopSsl;

// property setter: PopSsl
- (void)setPopSsl: (BOOL)boolVal;

// property getter: PopUsername
- (NSString *)PopUsername;

// property setter: PopUsername
- (void)setPopUsername: (NSString *)input;

// property getter: ReadTimeout
- (NSNumber *)ReadTimeout;

// property setter: ReadTimeout
- (void)setReadTimeout: (NSNumber *)intVal;

// property getter: RequireSslCertVerify
- (BOOL)RequireSslCertVerify;

// property setter: RequireSslCertVerify
- (void)setRequireSslCertVerify: (BOOL)boolVal;

// property getter: ResetDateOnLoad
- (BOOL)ResetDateOnLoad;

// property setter: ResetDateOnLoad
- (void)setResetDateOnLoad: (BOOL)boolVal;

// property getter: SendBufferSize
- (NSNumber *)SendBufferSize;

// property setter: SendBufferSize
- (void)setSendBufferSize: (NSNumber *)intVal;

// property getter: SendIndividual
- (BOOL)SendIndividual;

// property setter: SendIndividual
- (void)setSendIndividual: (BOOL)boolVal;

// property getter: SizeLimit
- (NSNumber *)SizeLimit;

// property setter: SizeLimit
- (void)setSizeLimit: (NSNumber *)intVal;

// property getter: SmtpAuthMethod
- (NSString *)SmtpAuthMethod;

// property setter: SmtpAuthMethod
- (void)setSmtpAuthMethod: (NSString *)input;

// property getter: SmtpHost
- (NSString *)SmtpHost;

// property setter: SmtpHost
- (void)setSmtpHost: (NSString *)input;

// property getter: SmtpLoginDomain
- (NSString *)SmtpLoginDomain;

// property setter: SmtpLoginDomain
- (void)setSmtpLoginDomain: (NSString *)input;

// property getter: SmtpPassword
- (NSString *)SmtpPassword;

// property setter: SmtpPassword
- (void)setSmtpPassword: (NSString *)input;

// property getter: SmtpPort
- (NSNumber *)SmtpPort;

// property setter: SmtpPort
- (void)setSmtpPort: (NSNumber *)intVal;

// property getter: SmtpSessionLog
- (NSString *)SmtpSessionLog;

// property getter: SmtpSsl
- (BOOL)SmtpSsl;

// property setter: SmtpSsl
- (void)setSmtpSsl: (BOOL)boolVal;

// property getter: SmtpSslServerCertVerified
- (BOOL)SmtpSslServerCertVerified;

// property getter: SmtpUsername
- (NSString *)SmtpUsername;

// property setter: SmtpUsername
- (void)setSmtpUsername: (NSString *)input;

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

// property getter: StartTLS
- (BOOL)StartTLS;

// property setter: StartTLS
- (void)setStartTLS: (BOOL)boolVal;

// property getter: UseApop
- (BOOL)UseApop;

// property setter: UseApop
- (void)setUseApop: (BOOL)boolVal;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// method: AddPfxSourceData
- (BOOL)AddPfxSourceData: (NSData *)pfxData 
	password: (NSString *)password;

// method: AddPfxSourceFile
- (BOOL)AddPfxSourceFile: (NSString *)pfxFilePath 
	password: (NSString *)password;

// method: CheckMail
- (NSNumber *)CheckMail;

// method: ClearBadEmailAddresses
- (void)ClearBadEmailAddresses;

// method: ClearPop3SessionLog
- (void)ClearPop3SessionLog;

// method: ClearSmtpSessionLog
- (void)ClearSmtpSessionLog;

// method: CloseSmtpConnection
- (BOOL)CloseSmtpConnection;

// method: CopyMail
- (CkoEmailBundle *)CopyMail;

// method: DeleteBundle
- (BOOL)DeleteBundle: (CkoEmailBundle *)bundle;

// method: DeleteByMsgnum
- (BOOL)DeleteByMsgnum: (NSNumber *)msgnum;

// method: DeleteByUidl
- (BOOL)DeleteByUidl: (NSString *)uidl;

// method: DeleteEmail
- (BOOL)DeleteEmail: (CkoEmail *)email;

// method: DeleteMultiple
- (BOOL)DeleteMultiple: (CkoStringArray *)uidlArray;

// method: FetchByMsgnum
- (CkoEmail *)FetchByMsgnum: (NSNumber *)msgnum;

// method: FetchEmail
- (CkoEmail *)FetchEmail: (NSString *)uidl;

// method: FetchMime
- (NSData *)FetchMime: (NSString *)uidl;

// method: FetchMimeByMsgnum
- (NSData *)FetchMimeByMsgnum: (NSNumber *)msgnum;

// method: FetchMultiple
- (CkoEmailBundle *)FetchMultiple: (CkoStringArray *)uidlArray;

// method: FetchMultipleHeaders
- (CkoEmailBundle *)FetchMultipleHeaders: (CkoStringArray *)uidlArray 
	numBodyLines: (NSNumber *)numBodyLines;

// method: FetchMultipleMime
- (CkoStringArray *)FetchMultipleMime: (CkoStringArray *)uidlArray;

// method: FetchSingleHeader
- (CkoEmail *)FetchSingleHeader: (NSNumber *)numBodyLines 
	msgNum: (NSNumber *)msgNum;

// method: FetchSingleHeaderByUidl
- (CkoEmail *)FetchSingleHeaderByUidl: (NSNumber *)numBodyLines 
	uidl: (NSString *)uidl;

// method: GetAllHeaders
- (CkoEmailBundle *)GetAllHeaders: (NSNumber *)numBodyLines;

// method: GetBadEmailAddrs
- (CkoStringArray *)GetBadEmailAddrs;

// method: GetFullEmail
- (CkoEmail *)GetFullEmail: (CkoEmail *)email;

// method: GetHeaders
- (CkoEmailBundle *)GetHeaders: (NSNumber *)numBodyLines 
	fromIndex: (NSNumber *)fromIndex 
	toIndex: (NSNumber *)toIndex;

// method: GetMailboxCount
- (NSNumber *)GetMailboxCount;

// method: GetMailboxInfoXml
- (NSString *)GetMailboxInfoXml;

// method: GetMailboxSize
- (NSNumber *)GetMailboxSize;

// method: GetPop3SslServerCert
- (CkoCert *)GetPop3SslServerCert;

// method: GetSentToEmailAddrs
- (CkoStringArray *)GetSentToEmailAddrs;

// method: GetSizeByUidl
- (NSNumber *)GetSizeByUidl: (NSString *)uidl;

// method: GetSmtpSslServerCert
- (CkoCert *)GetSmtpSslServerCert;

// method: GetUidls
- (CkoStringArray *)GetUidls;

// method: IsSmtpDsnCapable
- (BOOL)IsSmtpDsnCapable;

// method: IsUnlocked
- (BOOL)IsUnlocked;

// method: LoadEml
- (CkoEmail *)LoadEml: (NSString *)emlPath;

// method: LoadMbx
- (CkoEmailBundle *)LoadMbx: (NSString *)mbxPath;

// method: LoadMime
- (CkoEmail *)LoadMime: (NSString *)mimeText;

// method: LoadXmlEmail
- (CkoEmail *)LoadXmlEmail: (NSString *)folderPath;

// method: LoadXmlEmailString
- (CkoEmail *)LoadXmlEmailString: (NSString *)xmlString;

// method: LoadXmlFile
- (CkoEmailBundle *)LoadXmlFile: (NSString *)folderPath;

// method: LoadXmlString
- (CkoEmailBundle *)LoadXmlString: (NSString *)xmlString;

// method: MxLookup
- (NSString *)MxLookup: (NSString *)emailAddr;

// method: MxLookupAll
- (CkoStringArray *)MxLookupAll: (NSString *)emailAddress;

// method: OpenSmtpConnection
- (BOOL)OpenSmtpConnection;

// method: Pop3BeginSession
- (BOOL)Pop3BeginSession;

// method: Pop3EndSession
- (BOOL)Pop3EndSession;

// method: Pop3EndSessionNoQuit
- (BOOL)Pop3EndSessionNoQuit;

// method: Pop3Noop
- (BOOL)Pop3Noop;

// method: Pop3Reset
- (BOOL)Pop3Reset;

// method: Pop3SendRawCommand
- (NSString *)Pop3SendRawCommand: (NSString *)command 
	charset: (NSString *)charset;

// method: QuickSend
- (BOOL)QuickSend: (NSString *)fromAddr 
	toAddrs: (NSString *)toAddrs 
	subject: (NSString *)subject 
	body: (NSString *)body 
	smtpServer: (NSString *)smtpServer;

// method: RenderToMime
- (NSString *)RenderToMime: (CkoEmail *)email;

// method: RenderToMimeBytes
- (NSData *)RenderToMimeBytes: (CkoEmail *)email;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: SendBundle
- (BOOL)SendBundle: (CkoEmailBundle *)bundle;

// method: SendEmail
- (BOOL)SendEmail: (CkoEmail *)email;

// method: SendMime
- (BOOL)SendMime: (NSString *)from 
	recipients: (NSString *)recipients 
	mimeMsg: (NSString *)mimeMsg;

// method: SendMimeBytes
- (BOOL)SendMimeBytes: (NSString *)from 
	recipients: (NSString *)recipients 
	mimeData: (NSData *)mimeData;

// method: SendMimeToList
- (BOOL)SendMimeToList: (NSString *)from 
	distListFile: (NSString *)distListFile 
	mimeText: (NSString *)mimeText;

// method: SendToDistributionList
- (BOOL)SendToDistributionList: (CkoEmail *)email 
	sa: (CkoStringArray *)sa;

// method: SetDecryptCert2
- (BOOL)SetDecryptCert2: (CkoCert *)cert 
	key: (CkoPrivateKey *)key;

// method: SetSslClientCert
- (BOOL)SetSslClientCert: (CkoCert *)cert;

// method: SetSslClientCertPem
- (BOOL)SetSslClientCertPem: (NSString *)pemDataOrPath 
	pemPassword: (NSString *)pemPassword;

// method: SetSslClientCertPfx
- (BOOL)SetSslClientCertPfx: (NSString *)pfxPath 
	pfxPassword: (NSString *)pfxPassword;

// method: SmtpNoop
- (BOOL)SmtpNoop;

// method: SmtpReset
- (BOOL)SmtpReset;

// method: SmtpSendRawCommand
- (NSString *)SmtpSendRawCommand: (NSString *)command 
	charset: (NSString *)charset 
	bEncodeBase64: (BOOL)bEncodeBase64;

// method: SshAuthenticatePk
- (BOOL)SshAuthenticatePk: (BOOL)bSmtp 
	sshLogin: (NSString *)sshLogin 
	privateKey: (CkoSshKey *)privateKey;

// method: SshAuthenticatePw
- (BOOL)SshAuthenticatePw: (BOOL)bSmtp 
	sshLogin: (NSString *)sshLogin 
	sshPassword: (NSString *)sshPassword;

// method: SshCloseTunnel
- (BOOL)SshCloseTunnel: (BOOL)bSmtp;

// method: SshTunnel
- (BOOL)SshTunnel: (BOOL)bSmtp 
	sshServerHostname: (NSString *)sshServerHostname 
	sshServerPort: (NSNumber *)sshServerPort;

// method: TransferMail
- (CkoEmailBundle *)TransferMail;

// method: TransferMultipleMime
- (CkoStringArray *)TransferMultipleMime: (CkoStringArray *)uidlArray;

// method: UnlockComponent
- (BOOL)UnlockComponent: (NSString *)code;

// method: VerifyPopConnection
- (BOOL)VerifyPopConnection;

// method: VerifyPopLogin
- (BOOL)VerifyPopLogin;

// method: VerifyRecips
- (BOOL)VerifyRecips: (CkoEmail *)email 
	saBadAddrs: (CkoStringArray *)saBadAddrs;

// method: VerifySmtpConnection
- (BOOL)VerifySmtpConnection;

// method: VerifySmtpLogin
- (BOOL)VerifySmtpLogin;


@end

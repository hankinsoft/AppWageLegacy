// Chilkat Objective-C header.
// Generic/internal class name =  Ftp2
// Wrapped Chilkat C++ class name =  CkFtp2

@class CkoDateTime;
@class CkoCert;


@class CkoFtp2Progress;

@interface CkoFtp2 : NSObject {

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
- (void)setEventCallbackObject: (CkoFtp2Progress *)eventObj;

// property getter: Account
- (NSString *)Account;

// property setter: Account
- (void)setAccount: (NSString *)input;

// property getter: ActivePortRangeEnd
- (NSNumber *)ActivePortRangeEnd;

// property setter: ActivePortRangeEnd
- (void)setActivePortRangeEnd: (NSNumber *)intVal;

// property getter: ActivePortRangeStart
- (NSNumber *)ActivePortRangeStart;

// property setter: ActivePortRangeStart
- (void)setActivePortRangeStart: (NSNumber *)intVal;

// property getter: AllocateSize
- (NSNumber *)AllocateSize;

// property setter: AllocateSize
- (void)setAllocateSize: (NSNumber *)ulongVal;

// property getter: AsyncBytesReceived
- (NSNumber *)AsyncBytesReceived;

// property getter: AsyncBytesReceived64
- (NSNumber *)AsyncBytesReceived64;

// property getter: AsyncBytesReceivedStr
- (NSString *)AsyncBytesReceivedStr;

// property getter: AsyncBytesSent
- (NSNumber *)AsyncBytesSent;

// property getter: AsyncBytesSent64
- (NSNumber *)AsyncBytesSent64;

// property getter: AsyncBytesSentStr
- (NSString *)AsyncBytesSentStr;

// property getter: AsyncFinished
- (BOOL)AsyncFinished;

// property getter: AsyncLog
- (NSString *)AsyncLog;

// property getter: AsyncSuccess
- (BOOL)AsyncSuccess;

// property getter: AuthSsl
- (BOOL)AuthSsl;

// property setter: AuthSsl
- (void)setAuthSsl: (BOOL)boolVal;

// property getter: AuthTls
- (BOOL)AuthTls;

// property setter: AuthTls
- (void)setAuthTls: (BOOL)boolVal;

// property getter: AutoFeat
- (BOOL)AutoFeat;

// property setter: AutoFeat
- (void)setAutoFeat: (BOOL)boolVal;

// property getter: AutoFix
- (BOOL)AutoFix;

// property setter: AutoFix
- (void)setAutoFix: (BOOL)boolVal;

// property getter: AutoGetSizeForProgress
- (BOOL)AutoGetSizeForProgress;

// property setter: AutoGetSizeForProgress
- (void)setAutoGetSizeForProgress: (BOOL)boolVal;

// property getter: AutoSyst
- (BOOL)AutoSyst;

// property setter: AutoSyst
- (void)setAutoSyst: (BOOL)boolVal;

// property getter: AutoXcrc
- (BOOL)AutoXcrc;

// property setter: AutoXcrc
- (void)setAutoXcrc: (BOOL)boolVal;

// property getter: BandwidthThrottleDown
- (NSNumber *)BandwidthThrottleDown;

// property setter: BandwidthThrottleDown
- (void)setBandwidthThrottleDown: (NSNumber *)intVal;

// property getter: BandwidthThrottleUp
- (NSNumber *)BandwidthThrottleUp;

// property setter: BandwidthThrottleUp
- (void)setBandwidthThrottleUp: (NSNumber *)intVal;

// property getter: ClientIpAddress
- (NSString *)ClientIpAddress;

// property setter: ClientIpAddress
- (void)setClientIpAddress: (NSString *)input;

// property getter: ConnectFailReason
- (NSNumber *)ConnectFailReason;

// property getter: ConnectTimeout
- (NSNumber *)ConnectTimeout;

// property setter: ConnectTimeout
- (void)setConnectTimeout: (NSNumber *)intVal;

// property getter: ConnectVerified
- (BOOL)ConnectVerified;

// property getter: CrlfMode
- (NSNumber *)CrlfMode;

// property setter: CrlfMode
- (void)setCrlfMode: (NSNumber *)intVal;

// property getter: DebugLogFilePath
- (NSString *)DebugLogFilePath;

// property setter: DebugLogFilePath
- (void)setDebugLogFilePath: (NSString *)input;

// property getter: DirListingCharset
- (NSString *)DirListingCharset;

// property setter: DirListingCharset
- (void)setDirListingCharset: (NSString *)input;

// property getter: DownloadRate
- (NSNumber *)DownloadRate;

// property getter: ForcePortIpAddress
- (NSString *)ForcePortIpAddress;

// property setter: ForcePortIpAddress
- (void)setForcePortIpAddress: (NSString *)input;

// property getter: Greeting
- (NSString *)Greeting;

// property getter: HasModeZ
- (BOOL)HasModeZ;

// property getter: HeartbeatMs
- (NSNumber *)HeartbeatMs;

// property setter: HeartbeatMs
- (void)setHeartbeatMs: (NSNumber *)intVal;

// property getter: Hostname
- (NSString *)Hostname;

// property setter: Hostname
- (void)setHostname: (NSString *)input;

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

// property getter: LastReply
- (NSString *)LastReply;

// property getter: ListPattern
- (NSString *)ListPattern;

// property setter: ListPattern
- (void)setListPattern: (NSString *)input;

// property getter: LoginVerified
- (BOOL)LoginVerified;

// property getter: NumFilesAndDirs
- (NSNumber *)NumFilesAndDirs;

// property getter: PartialTransfer
- (BOOL)PartialTransfer;

// property getter: Passive
- (BOOL)Passive;

// property setter: Passive
- (void)setPassive: (BOOL)boolVal;

// property getter: PassiveUseHostAddr
- (BOOL)PassiveUseHostAddr;

// property setter: PassiveUseHostAddr
- (void)setPassiveUseHostAddr: (BOOL)boolVal;

// property getter: Password
- (NSString *)Password;

// property setter: Password
- (void)setPassword: (NSString *)input;

// property getter: Port
- (NSNumber *)Port;

// property setter: Port
- (void)setPort: (NSNumber *)intVal;

// property getter: PreferNlst
- (BOOL)PreferNlst;

// property setter: PreferNlst
- (void)setPreferNlst: (BOOL)boolVal;

// property getter: ProgressMonSize
- (NSNumber *)ProgressMonSize;

// property setter: ProgressMonSize
- (void)setProgressMonSize: (NSNumber *)intVal;

// property getter: ProgressMonSize64
- (NSNumber *)ProgressMonSize64;

// property setter: ProgressMonSize64
- (void)setProgressMonSize64: (NSNumber *)longlongVal;

// property getter: ProxyHostname
- (NSString *)ProxyHostname;

// property setter: ProxyHostname
- (void)setProxyHostname: (NSString *)input;

// property getter: ProxyMethod
- (NSNumber *)ProxyMethod;

// property setter: ProxyMethod
- (void)setProxyMethod: (NSNumber *)intVal;

// property getter: ProxyPassword
- (NSString *)ProxyPassword;

// property setter: ProxyPassword
- (void)setProxyPassword: (NSString *)input;

// property getter: ProxyPort
- (NSNumber *)ProxyPort;

// property setter: ProxyPort
- (void)setProxyPort: (NSNumber *)intVal;

// property getter: ProxyUsername
- (NSString *)ProxyUsername;

// property setter: ProxyUsername
- (void)setProxyUsername: (NSString *)input;

// property getter: ReadTimeout
- (NSNumber *)ReadTimeout;

// property setter: ReadTimeout
- (void)setReadTimeout: (NSNumber *)intVal;

// property getter: RequireSslCertVerify
- (BOOL)RequireSslCertVerify;

// property setter: RequireSslCertVerify
- (void)setRequireSslCertVerify: (BOOL)boolVal;

// property getter: RestartNext
- (BOOL)RestartNext;

// property setter: RestartNext
- (void)setRestartNext: (BOOL)boolVal;

// property getter: SendBufferSize
- (NSNumber *)SendBufferSize;

// property setter: SendBufferSize
- (void)setSendBufferSize: (NSNumber *)intVal;

// property getter: SessionLog
- (NSString *)SessionLog;

// property getter: SkipFinalReply
- (BOOL)SkipFinalReply;

// property setter: SkipFinalReply
- (void)setSkipFinalReply: (BOOL)boolVal;

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

// property getter: Ssl
- (BOOL)Ssl;

// property setter: Ssl
- (void)setSsl: (BOOL)boolVal;

// property getter: SslProtocol
- (NSString *)SslProtocol;

// property setter: SslProtocol
- (void)setSslProtocol: (NSString *)input;

// property getter: SslServerCertVerified
- (BOOL)SslServerCertVerified;

// property getter: SyncPreview
- (NSString *)SyncPreview;

// property getter: UploadRate
- (NSNumber *)UploadRate;

// property getter: UseEpsv
- (BOOL)UseEpsv;

// property setter: UseEpsv
- (void)setUseEpsv: (BOOL)boolVal;

// property getter: Username
- (NSString *)Username;

// property setter: Username
- (void)setUsername: (NSString *)input;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// method: AppendFile
- (BOOL)AppendFile: (NSString *)localPath 
	remoteFilename: (NSString *)remoteFilename;

// method: AppendFileFromBinaryData
- (BOOL)AppendFileFromBinaryData: (NSString *)remoteFilename 
	binaryData: (NSData *)binaryData;

// method: AppendFileFromTextData
- (BOOL)AppendFileFromTextData: (NSString *)remoteFilename 
	textData: (NSString *)textData 
	charset: (NSString *)charset;

// method: AsyncAbort
- (void)AsyncAbort;

// method: AsyncAppendFileStart
- (BOOL)AsyncAppendFileStart: (NSString *)localPath 
	remoteFilename: (NSString *)remoteFilename;

// method: AsyncGetFileStart
- (BOOL)AsyncGetFileStart: (NSString *)remoteFilename 
	localFilename: (NSString *)localFilename;

// method: AsyncPutFileStart
- (BOOL)AsyncPutFileStart: (NSString *)localPath 
	remoteFilename: (NSString *)remoteFilename;

// method: ChangeRemoteDir
- (BOOL)ChangeRemoteDir: (NSString *)relativeDirPath;

// method: ClearControlChannel
- (BOOL)ClearControlChannel;

// method: ClearDirCache
- (void)ClearDirCache;

// method: ClearSessionLog
- (void)ClearSessionLog;

// method: Connect
- (BOOL)Connect;

// method: ConnectOnly
- (BOOL)ConnectOnly;

// method: ConvertToTls
- (BOOL)ConvertToTls;

// method: CreatePlan
- (NSString *)CreatePlan: (NSString *)localDir;

// method: CreateRemoteDir
- (BOOL)CreateRemoteDir: (NSString *)dir;

// method: DeleteMatching
- (NSNumber *)DeleteMatching: (NSString *)remotePattern;

// method: DeleteRemoteFile
- (BOOL)DeleteRemoteFile: (NSString *)filename;

// method: DeleteTree
- (BOOL)DeleteTree;

// method: DetermineProxyMethod
- (NSNumber *)DetermineProxyMethod;

// method: DetermineSettings
- (NSString *)DetermineSettings;

// method: DirTreeXml
- (NSString *)DirTreeXml;

// method: Disconnect
- (BOOL)Disconnect;

// method: DownloadTree
- (BOOL)DownloadTree: (NSString *)localRoot;

// method: Feat
- (NSString *)Feat;

// method: GetCreateDt
- (CkoDateTime *)GetCreateDt: (NSNumber *)index;

// method: GetCreateDtByName
- (CkoDateTime *)GetCreateDtByName: (NSString *)filename;

// method: GetCreateTime
- (NSDate *)GetCreateTime: (NSNumber *)index;

// method: GetCreateTimeByName
- (NSDate *)GetCreateTimeByName: (NSString *)filename;

// method: GetCreateTimeByNameStr
- (NSString *)GetCreateTimeByNameStr: (NSString *)filename;

// method: GetCreateTimeStr
- (NSString *)GetCreateTimeStr: (NSNumber *)index;

// method: GetCurrentRemoteDir
- (NSString *)GetCurrentRemoteDir;

// method: GetFile
- (BOOL)GetFile: (NSString *)remoteFilename 
	localPath: (NSString *)localPath;

// method: GetFilename
- (NSString *)GetFilename: (NSNumber *)index;

// method: GetIsDirectory
- (BOOL)GetIsDirectory: (NSNumber *)index;

// method: GetIsSymbolicLink
- (BOOL)GetIsSymbolicLink: (NSNumber *)index;

// method: GetLastAccessDt
- (CkoDateTime *)GetLastAccessDt: (NSNumber *)index;

// method: GetLastAccessDtByName
- (CkoDateTime *)GetLastAccessDtByName: (NSString *)filename;

// method: GetLastAccessTime
- (NSDate *)GetLastAccessTime: (NSNumber *)index;

// method: GetLastAccessTimeByName
- (NSDate *)GetLastAccessTimeByName: (NSString *)filename;

// method: GetLastAccessTimeByNameStr
- (NSString *)GetLastAccessTimeByNameStr: (NSString *)filename;

// method: GetLastAccessTimeStr
- (NSString *)GetLastAccessTimeStr: (NSNumber *)index;

// method: GetLastModDt
- (CkoDateTime *)GetLastModDt: (NSNumber *)index;

// method: GetLastModDtByName
- (CkoDateTime *)GetLastModDtByName: (NSString *)filename;

// method: GetLastModifiedTime
- (NSDate *)GetLastModifiedTime: (NSNumber *)index;

// method: GetLastModifiedTimeByName
- (NSDate *)GetLastModifiedTimeByName: (NSString *)filename;

// method: GetLastModifiedTimeByNameStr
- (NSString *)GetLastModifiedTimeByNameStr: (NSString *)filename;

// method: GetLastModifiedTimeStr
- (NSString *)GetLastModifiedTimeStr: (NSNumber *)index;

// method: GetRemoteFileBinaryData
- (NSData *)GetRemoteFileBinaryData: (NSString *)remoteFilename;

// method: GetRemoteFileTextC
- (NSString *)GetRemoteFileTextC: (NSString *)remoteFilename 
	charset: (NSString *)charset;

// method: GetRemoteFileTextData
- (NSString *)GetRemoteFileTextData: (NSString *)remoteFilename;

// method: GetSize
- (NSNumber *)GetSize: (NSNumber *)index;

// method: GetSize64
- (NSNumber *)GetSize64: (NSNumber *)index;

// method: GetSizeByName
- (NSNumber *)GetSizeByName: (NSString *)filname;

// method: GetSizeByName64
- (NSNumber *)GetSizeByName64: (NSString *)filename;

// method: GetSizeStr
- (NSString *)GetSizeStr: (NSNumber *)index;

// method: GetSizeStrByName
- (NSString *)GetSizeStrByName: (NSString *)filename;

// method: GetSslServerCert
- (CkoCert *)GetSslServerCert;

// method: GetTextDirListing
- (NSString *)GetTextDirListing: (NSString *)pattern;

// method: GetXmlDirListing
- (NSString *)GetXmlDirListing: (NSString *)pattern;

// method: IsUnlocked
- (BOOL)IsUnlocked;

// method: LoginAfterConnectOnly
- (BOOL)LoginAfterConnectOnly;

// method: MGetFiles
- (NSNumber *)MGetFiles: (NSString *)remotePattern 
	localDir: (NSString *)localDir;

// method: MPutFiles
- (NSNumber *)MPutFiles: (NSString *)pattern;

// method: NlstXml
- (NSString *)NlstXml: (NSString *)pattern;

// method: Noop
- (BOOL)Noop;

// method: PutFile
- (BOOL)PutFile: (NSString *)localPath 
	remoteFilename: (NSString *)remoteFilename;

// method: PutFileFromBinaryData
- (BOOL)PutFileFromBinaryData: (NSString *)remoteFilename 
	binaryData: (NSData *)binaryData;

// method: PutFileFromTextData
- (BOOL)PutFileFromTextData: (NSString *)remoteFilename 
	textData: (NSString *)textData 
	charset: (NSString *)charset;

// method: PutPlan
- (BOOL)PutPlan: (NSString *)planUtf8 
	planLogFilePath: (NSString *)planLogFilePath;

// method: PutTree
- (BOOL)PutTree: (NSString *)localDir;

// method: Quote
- (BOOL)Quote: (NSString *)cmd;

// method: RemoveRemoteDir
- (BOOL)RemoveRemoteDir: (NSString *)dir;

// method: RenameRemoteFile
- (BOOL)RenameRemoteFile: (NSString *)existingFilename 
	newFilename: (NSString *)newFilename;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: SendCommand
- (NSString *)SendCommand: (NSString *)cmd;

// method: SetModeZ
- (BOOL)SetModeZ;

// method: SetOldestDate
- (void)SetOldestDate: (NSDate *)oldestDateTime;

// method: SetOldestDateStr
- (void)SetOldestDateStr: (NSString *)oldestDateTimeStr;

// method: SetRemoteFileDateTime
- (BOOL)SetRemoteFileDateTime: (NSDate *)dateTime 
	remoteFilename: (NSString *)remoteFilename;

// method: SetRemoteFileDateTimeStr
- (BOOL)SetRemoteFileDateTimeStr: (NSString *)dateTimeStr 
	remoteFilename: (NSString *)remoteFilename;

// method: SetRemoteFileDt
- (BOOL)SetRemoteFileDt: (CkoDateTime *)dt 
	remoteFilename: (NSString *)remoteFilename;

// method: SetSslCertRequirement
- (void)SetSslCertRequirement: (NSString *)name 
	value: (NSString *)value;

// method: SetSslClientCert
- (BOOL)SetSslClientCert: (CkoCert *)cert;

// method: SetSslClientCertPem
- (BOOL)SetSslClientCertPem: (NSString *)pemDataOrFilename 
	pemPassword: (NSString *)pemPassword;

// method: SetSslClientCertPfx
- (BOOL)SetSslClientCertPfx: (NSString *)pfxPath 
	pfxPassword: (NSString *)pfxPassword;

// method: SetTypeAscii
- (BOOL)SetTypeAscii;

// method: SetTypeBinary
- (BOOL)SetTypeBinary;

// method: Site
- (BOOL)Site: (NSString *)parms;

// method: SleepMs
- (void)SleepMs: (NSNumber *)millisec;

// method: Stat
- (NSString *)Stat;

// method: SyncDeleteRemote
- (BOOL)SyncDeleteRemote: (NSString *)localRoot;

// method: SyncLocalDir
- (BOOL)SyncLocalDir: (NSString *)localRoot 
	mode: (NSNumber *)mode;

// method: SyncLocalTree
- (BOOL)SyncLocalTree: (NSString *)localRoot 
	mode: (NSNumber *)mode;

// method: SyncRemoteTree
- (BOOL)SyncRemoteTree: (NSString *)localRoot 
	mode: (NSNumber *)mode;

// method: SyncRemoteTree2
- (BOOL)SyncRemoteTree2: (NSString *)localRoot 
	mode: (NSNumber *)mode 
	bDescend: (BOOL)bDescend 
	bPreviewOnly: (BOOL)bPreviewOnly;

// method: Syst
- (NSString *)Syst;

// method: UnlockComponent
- (BOOL)UnlockComponent: (NSString *)code;


@end

// Chilkat Objective-C header.
// Generic/internal class name =  Ntlm
// Wrapped Chilkat C++ class name =  CkNtlm



@interface CkoNtlm : NSObject {

	@private
		void *m_obj;

}

- (id)init;
- (void)dealloc;
- (void)dispose;
- (NSString *)stringWithUtf8: (const char *)s;
- (void *)CppImplObj;
- (void)setCppImplObj: (void *)pObj;

// property getter: ClientChallenge
- (NSString *)ClientChallenge;

// property setter: ClientChallenge
- (void)setClientChallenge: (NSString *)input;

// property getter: DebugLogFilePath
- (NSString *)DebugLogFilePath;

// property setter: DebugLogFilePath
- (void)setDebugLogFilePath: (NSString *)input;

// property getter: DnsComputerName
- (NSString *)DnsComputerName;

// property setter: DnsComputerName
- (void)setDnsComputerName: (NSString *)input;

// property getter: DnsDomainName
- (NSString *)DnsDomainName;

// property setter: DnsDomainName
- (void)setDnsDomainName: (NSString *)input;

// property getter: Domain
- (NSString *)Domain;

// property setter: Domain
- (void)setDomain: (NSString *)input;

// property getter: EncodingMode
- (NSString *)EncodingMode;

// property setter: EncodingMode
- (void)setEncodingMode: (NSString *)input;

// property getter: Flags
- (NSString *)Flags;

// property setter: Flags
- (void)setFlags: (NSString *)input;

// property getter: LastErrorHtml
- (NSString *)LastErrorHtml;

// property getter: LastErrorText
- (NSString *)LastErrorText;

// property getter: LastErrorXml
- (NSString *)LastErrorXml;

// property getter: NetBiosComputerName
- (NSString *)NetBiosComputerName;

// property setter: NetBiosComputerName
- (void)setNetBiosComputerName: (NSString *)input;

// property getter: NetBiosDomainName
- (NSString *)NetBiosDomainName;

// property setter: NetBiosDomainName
- (void)setNetBiosDomainName: (NSString *)input;

// property getter: NtlmVersion
- (NSNumber *)NtlmVersion;

// property setter: NtlmVersion
- (void)setNtlmVersion: (NSNumber *)intVal;

// property getter: OemCodePage
- (NSNumber *)OemCodePage;

// property setter: OemCodePage
- (void)setOemCodePage: (NSNumber *)intVal;

// property getter: Password
- (NSString *)Password;

// property setter: Password
- (void)setPassword: (NSString *)input;

// property getter: ServerChallenge
- (NSString *)ServerChallenge;

// property setter: ServerChallenge
- (void)setServerChallenge: (NSString *)input;

// property getter: TargetName
- (NSString *)TargetName;

// property setter: TargetName
- (void)setTargetName: (NSString *)input;

// property getter: UserName
- (NSString *)UserName;

// property setter: UserName
- (void)setUserName: (NSString *)input;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// property getter: Workstation
- (NSString *)Workstation;

// property setter: Workstation
- (void)setWorkstation: (NSString *)input;

// method: CompareType3
- (BOOL)CompareType3: (NSString *)msg1 
	msg2: (NSString *)msg2;

// method: GenType1
- (NSString *)GenType1;

// method: GenType2
- (NSString *)GenType2: (NSString *)type1Msg;

// method: GenType3
- (NSString *)GenType3: (NSString *)type2Msg;

// method: LoadType3
- (BOOL)LoadType3: (NSString *)type3Msg;

// method: ParseType1
- (NSString *)ParseType1: (NSString *)type1Msg;

// method: ParseType2
- (NSString *)ParseType2: (NSString *)type2Msg;

// method: ParseType3
- (NSString *)ParseType3: (NSString *)type3Msg;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: SetFlag
- (BOOL)SetFlag: (NSString *)flagLetter 
	on: (BOOL)on;

// method: UnlockComponent
- (BOOL)UnlockComponent: (NSString *)unlockCode;


@end

// Chilkat Objective-C header.
// Generic/internal class name =  Dkim
// Wrapped Chilkat C++ class name =  CkDkim



@interface CkoDkim : NSObject {

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

// property getter: DkimAlg
- (NSString *)DkimAlg;

// property setter: DkimAlg
- (void)setDkimAlg: (NSString *)input;

// property getter: DkimBodyLengthCount
- (NSNumber *)DkimBodyLengthCount;

// property setter: DkimBodyLengthCount
- (void)setDkimBodyLengthCount: (NSNumber *)intVal;

// property getter: DkimCanon
- (NSString *)DkimCanon;

// property setter: DkimCanon
- (void)setDkimCanon: (NSString *)input;

// property getter: DkimDomain
- (NSString *)DkimDomain;

// property setter: DkimDomain
- (void)setDkimDomain: (NSString *)input;

// property getter: DkimHeaders
- (NSString *)DkimHeaders;

// property setter: DkimHeaders
- (void)setDkimHeaders: (NSString *)input;

// property getter: DkimSelector
- (NSString *)DkimSelector;

// property setter: DkimSelector
- (void)setDkimSelector: (NSString *)input;

// property getter: DomainKeyAlg
- (NSString *)DomainKeyAlg;

// property setter: DomainKeyAlg
- (void)setDomainKeyAlg: (NSString *)input;

// property getter: DomainKeyCanon
- (NSString *)DomainKeyCanon;

// property setter: DomainKeyCanon
- (void)setDomainKeyCanon: (NSString *)input;

// property getter: DomainKeyDomain
- (NSString *)DomainKeyDomain;

// property setter: DomainKeyDomain
- (void)setDomainKeyDomain: (NSString *)input;

// property getter: DomainKeyHeaders
- (NSString *)DomainKeyHeaders;

// property setter: DomainKeyHeaders
- (void)setDomainKeyHeaders: (NSString *)input;

// property getter: DomainKeySelector
- (NSString *)DomainKeySelector;

// property setter: DomainKeySelector
- (void)setDomainKeySelector: (NSString *)input;

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

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// method: AddDkimSignature
- (NSData *)AddDkimSignature: (NSData *)mimeIn;

// method: AddDomainKeySignature
- (NSData *)AddDomainKeySignature: (NSData *)mimeIn;

// method: LoadDkimPk
- (BOOL)LoadDkimPk: (NSString *)privateKey 
	optionalPassword: (NSString *)optionalPassword;

// method: LoadDkimPkBytes
- (BOOL)LoadDkimPkBytes: (NSData *)privateKeyDer 
	optionalPassword: (NSString *)optionalPassword;

// method: LoadDkimPkFile
- (BOOL)LoadDkimPkFile: (NSString *)privateKeyFilepath 
	optionalPassword: (NSString *)optionalPassword;

// method: LoadDomainKeyPk
- (BOOL)LoadDomainKeyPk: (NSString *)privateKey 
	optionalPassword: (NSString *)optionalPassword;

// method: LoadDomainKeyPkBytes
- (BOOL)LoadDomainKeyPkBytes: (NSData *)privateKeyDer 
	optionalPassword: (NSString *)optionalPassword;

// method: LoadDomainKeyPkFile
- (BOOL)LoadDomainKeyPkFile: (NSString *)privateKeyFilepath 
	optionalPassword: (NSString *)optionalPassword;

// method: LoadPublicKey
- (BOOL)LoadPublicKey: (NSString *)selector 
	domain: (NSString *)domain 
	publicKey: (NSString *)publicKey;

// method: LoadPublicKeyFile
- (BOOL)LoadPublicKeyFile: (NSString *)selector 
	domain: (NSString *)domain 
	publicKeyFilepath: (NSString *)publicKeyFilepath;

// method: NumDkimSignatures
- (NSNumber *)NumDkimSignatures: (NSData *)mimeData;

// method: NumDomainKeySignatures
- (NSNumber *)NumDomainKeySignatures: (NSData *)mimeData;

// method: PrefetchPublicKey
- (BOOL)PrefetchPublicKey: (NSString *)selector 
	domain: (NSString *)domain;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: UnlockComponent
- (BOOL)UnlockComponent: (NSString *)unlockCode;

// method: VerifyDkimSignature
- (BOOL)VerifyDkimSignature: (NSNumber *)sigIdx 
	mimeData: (NSData *)mimeData;

// method: VerifyDomainKeySignature
- (BOOL)VerifyDomainKeySignature: (NSNumber *)sigIdx 
	mimeData: (NSData *)mimeData;


@end

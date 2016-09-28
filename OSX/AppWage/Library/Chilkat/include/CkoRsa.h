// Chilkat Objective-C header.
// Generic/internal class name =  Rsa
// Wrapped Chilkat C++ class name =  CkRsa



@interface CkoRsa : NSObject {

	@private
		void *m_obj;

}

- (id)init;
- (void)dealloc;
- (void)dispose;
- (NSString *)stringWithUtf8: (const char *)s;
- (void *)CppImplObj;
- (void)setCppImplObj: (void *)pObj;

// property getter: Charset
- (NSString *)Charset;

// property setter: Charset
- (void)setCharset: (NSString *)input;

// property getter: DebugLogFilePath
- (NSString *)DebugLogFilePath;

// property setter: DebugLogFilePath
- (void)setDebugLogFilePath: (NSString *)input;

// property getter: EncodingMode
- (NSString *)EncodingMode;

// property setter: EncodingMode
- (void)setEncodingMode: (NSString *)input;

// property getter: LastErrorHtml
- (NSString *)LastErrorHtml;

// property getter: LastErrorText
- (NSString *)LastErrorText;

// property getter: LastErrorXml
- (NSString *)LastErrorXml;

// property getter: LittleEndian
- (BOOL)LittleEndian;

// property setter: LittleEndian
- (void)setLittleEndian: (BOOL)boolVal;

// property getter: NoUnpad
- (BOOL)NoUnpad;

// property setter: NoUnpad
- (void)setNoUnpad: (BOOL)boolVal;

// property getter: NumBits
- (NSNumber *)NumBits;

// property getter: OaepPadding
- (BOOL)OaepPadding;

// property setter: OaepPadding
- (void)setOaepPadding: (BOOL)boolVal;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// method: DecryptBytes
- (NSData *)DecryptBytes: (NSData *)bData 
	bUsePrivateKey: (BOOL)bUsePrivateKey;

// method: DecryptBytesENC
- (NSData *)DecryptBytesENC: (NSString *)str 
	bUsePrivateKey: (BOOL)bUsePrivateKey;

// method: DecryptString
- (NSString *)DecryptString: (NSData *)bData 
	bUsePrivateKey: (BOOL)bUsePrivateKey;

// method: DecryptStringENC
- (NSString *)DecryptStringENC: (NSString *)str 
	bUsePrivateKey: (BOOL)bUsePrivateKey;

// method: EncryptBytes
- (NSData *)EncryptBytes: (NSData *)bData 
	bUsePrivateKey: (BOOL)bUsePrivateKey;

// method: EncryptBytesENC
- (NSString *)EncryptBytesENC: (NSData *)bData 
	bUsePrivateKey: (BOOL)bUsePrivateKey;

// method: EncryptString
- (NSData *)EncryptString: (NSString *)str 
	bUsePrivateKey: (BOOL)bUsePrivateKey;

// method: EncryptStringENC
- (NSString *)EncryptStringENC: (NSString *)str 
	bUsePrivateKey: (BOOL)bUsePrivateKey;

// method: ExportPrivateKey
- (NSString *)ExportPrivateKey;

// method: ExportPublicKey
- (NSString *)ExportPublicKey;

// method: GenerateKey
- (BOOL)GenerateKey: (NSNumber *)numBits;

// method: ImportPrivateKey
- (BOOL)ImportPrivateKey: (NSString *)strXml;

// method: ImportPublicKey
- (BOOL)ImportPublicKey: (NSString *)strXml;

// method: OpenSslSignBytes
- (NSData *)OpenSslSignBytes: (NSData *)data;

// method: OpenSslSignBytesENC
- (NSString *)OpenSslSignBytesENC: (NSData *)data;

// method: OpenSslSignString
- (NSData *)OpenSslSignString: (NSString *)str;

// method: OpenSslSignStringENC
- (NSString *)OpenSslSignStringENC: (NSString *)str;

// method: OpenSslVerifyBytes
- (NSData *)OpenSslVerifyBytes: (NSData *)signature;

// method: OpenSslVerifyBytesENC
- (NSData *)OpenSslVerifyBytesENC: (NSString *)str;

// method: OpenSslVerifyString
- (NSString *)OpenSslVerifyString: (NSData *)data;

// method: OpenSslVerifyStringENC
- (NSString *)OpenSslVerifyStringENC: (NSString *)str;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: SignBytes
- (NSData *)SignBytes: (NSData *)bData 
	hashAlg: (NSString *)hashAlg;

// method: SignBytesENC
- (NSString *)SignBytesENC: (NSData *)bData 
	hashAlg: (NSString *)hashAlg;

// method: SignHash
- (NSData *)SignHash: (NSData *)hashBytes 
	hashAlg: (NSString *)hashAlg;

// method: SignHashENC
- (NSString *)SignHashENC: (NSString *)encodedHash 
	hashAlg: (NSString *)hashAlg;

// method: SignString
- (NSData *)SignString: (NSString *)str 
	hashAlg: (NSString *)hashAlg;

// method: SignStringENC
- (NSString *)SignStringENC: (NSString *)str 
	hashAlg: (NSString *)hashAlg;

// method: SnkToXml
- (NSString *)SnkToXml: (NSString *)snkPath;

// method: UnlockComponent
- (BOOL)UnlockComponent: (NSString *)unlockCode;

// method: VerifyBytes
- (BOOL)VerifyBytes: (NSData *)bData 
	hashAlg: (NSString *)hashAlg 
	sigData: (NSData *)sigData;

// method: VerifyBytesENC
- (BOOL)VerifyBytesENC: (NSData *)bData 
	hashAlg: (NSString *)hashAlg 
	encodedSig: (NSString *)encodedSig;

// method: VerifyHash
- (BOOL)VerifyHash: (NSData *)hashBytes 
	hashAlg: (NSString *)hashAlg 
	sigBytes: (NSData *)sigBytes;

// method: VerifyHashENC
- (BOOL)VerifyHashENC: (NSString *)encodedHash 
	hashAlg: (NSString *)hashAlg 
	encodedSig: (NSString *)encodedSig;

// method: VerifyPrivateKey
- (BOOL)VerifyPrivateKey: (NSString *)xml;

// method: VerifyString
- (BOOL)VerifyString: (NSString *)str 
	hashAlg: (NSString *)hashAlg 
	sigData: (NSData *)sigData;

// method: VerifyStringENC
- (BOOL)VerifyStringENC: (NSString *)str 
	hashAlg: (NSString *)hashAlg 
	sig: (NSString *)sig;


@end

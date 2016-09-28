// Chilkat Objective-C header.
// Generic/internal class name =  Dsa
// Wrapped Chilkat C++ class name =  CkDsa



@interface CkoDsa : NSObject {

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

// property getter: GroupSize
- (NSNumber *)GroupSize;

// property setter: GroupSize
- (void)setGroupSize: (NSNumber *)intVal;

// property getter: Hash
- (NSData *)Hash;

// property setter: Hash
- (void)setHash: (NSData *)data;

// property getter: Hash
- (NSMutableData *)HashMutable;

// property setter: Hash
- (void)setHashMutable: (NSMutableData *)data;

// property getter: HexG
- (NSString *)HexG;

// property getter: HexP
- (NSString *)HexP;

// property getter: HexQ
- (NSString *)HexQ;

// property getter: HexX
- (NSString *)HexX;

// property getter: HexY
- (NSString *)HexY;

// property getter: LastErrorHtml
- (NSString *)LastErrorHtml;

// property getter: LastErrorText
- (NSString *)LastErrorText;

// property getter: LastErrorXml
- (NSString *)LastErrorXml;

// property getter: Signature
- (NSData *)Signature;

// property setter: Signature
- (void)setSignature: (NSData *)data;

// property getter: Signature
- (NSMutableData *)SignatureMutable;

// property setter: Signature
- (void)setSignatureMutable: (NSMutableData *)data;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// method: FromDer
- (BOOL)FromDer: (NSData *)derData;

// method: FromDerFile
- (BOOL)FromDerFile: (NSString *)path;

// method: FromEncryptedPem
- (BOOL)FromEncryptedPem: (NSString *)password 
	pemData: (NSString *)pemData;

// method: FromPem
- (BOOL)FromPem: (NSString *)pemData;

// method: FromPublicDer
- (BOOL)FromPublicDer: (NSData *)derData;

// method: FromPublicDerFile
- (BOOL)FromPublicDerFile: (NSString *)path;

// method: FromPublicPem
- (BOOL)FromPublicPem: (NSString *)pemData;

// method: FromXml
- (BOOL)FromXml: (NSString *)xmlKey;

// method: GenKey
- (BOOL)GenKey: (NSNumber *)numBits;

// method: GenKeyFromParamsDer
- (BOOL)GenKeyFromParamsDer: (NSData *)derBytes;

// method: GenKeyFromParamsDerFile
- (BOOL)GenKeyFromParamsDerFile: (NSString *)path;

// method: GenKeyFromParamsPem
- (BOOL)GenKeyFromParamsPem: (NSString *)pem;

// method: GenKeyFromParamsPemFile
- (BOOL)GenKeyFromParamsPemFile: (NSString *)path;

// method: GetEncodedHash
- (NSString *)GetEncodedHash: (NSString *)encoding;

// method: GetEncodedSignature
- (NSString *)GetEncodedSignature: (NSString *)encoding;

// method: LoadText
- (NSString *)LoadText: (NSString *)path;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: SaveText
- (BOOL)SaveText: (NSString *)strToSave 
	path: (NSString *)path;

// method: SetEncodedHash
- (BOOL)SetEncodedHash: (NSString *)encoding 
	encodedHash: (NSString *)encodedHash;

// method: SetEncodedSignature
- (BOOL)SetEncodedSignature: (NSString *)encoding 
	encodedSig: (NSString *)encodedSig;

// method: SetEncodedSignatureRS
- (BOOL)SetEncodedSignatureRS: (NSString *)encoding 
	encodedR: (NSString *)encodedR 
	encodedS: (NSString *)encodedS;

// method: SetKeyExplicit
- (BOOL)SetKeyExplicit: (NSNumber *)groupSizeInBytes 
	pHex: (NSString *)pHex 
	qHex: (NSString *)qHex 
	gHex: (NSString *)gHex 
	xHex: (NSString *)xHex;

// method: SetPubKeyExplicit
- (BOOL)SetPubKeyExplicit: (NSNumber *)groupSizeInBytes 
	pHex: (NSString *)pHex 
	qHex: (NSString *)qHex 
	gHex: (NSString *)gHex 
	yHex: (NSString *)yHex;

// method: SignHash
- (BOOL)SignHash;

// method: ToDer
- (NSData *)ToDer;

// method: ToDerFile
- (BOOL)ToDerFile: (NSString *)path;

// method: ToEncryptedPem
- (NSString *)ToEncryptedPem: (NSString *)password;

// method: ToPem
- (NSString *)ToPem;

// method: ToPublicDer
- (NSData *)ToPublicDer;

// method: ToPublicDerFile
- (BOOL)ToPublicDerFile: (NSString *)path;

// method: ToPublicPem
- (NSString *)ToPublicPem;

// method: ToXml
- (NSString *)ToXml: (BOOL)bPublicOnly;

// method: UnlockComponent
- (BOOL)UnlockComponent: (NSString *)unlockCode;

// method: Verify
- (BOOL)Verify;

// method: VerifyKey
- (BOOL)VerifyKey;


@end

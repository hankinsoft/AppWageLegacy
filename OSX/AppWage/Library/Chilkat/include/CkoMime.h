// Chilkat Objective-C header.
// Generic/internal class name =  Mime
// Wrapped Chilkat C++ class name =  CkMime

@class CkoCert;
@class CkoPrivateKey;
@class CkoStringArray;


@interface CkoMime : NSObject {

	@private
		void *m_obj;

}

- (id)init;
- (void)dealloc;
- (void)dispose;
- (NSString *)stringWithUtf8: (const char *)s;
- (void *)CppImplObj;
- (void)setCppImplObj: (void *)pObj;

// property getter: Boundary
- (NSString *)Boundary;

// property setter: Boundary
- (void)setBoundary: (NSString *)input;

// property getter: Charset
- (NSString *)Charset;

// property setter: Charset
- (void)setCharset: (NSString *)input;

// property getter: ContentType
- (NSString *)ContentType;

// property setter: ContentType
- (void)setContentType: (NSString *)input;

// property getter: CurrentDateTime
- (NSString *)CurrentDateTime;

// property getter: DebugLogFilePath
- (NSString *)DebugLogFilePath;

// property setter: DebugLogFilePath
- (void)setDebugLogFilePath: (NSString *)input;

// property getter: Disposition
- (NSString *)Disposition;

// property setter: Disposition
- (void)setDisposition: (NSString *)input;

// property getter: Encoding
- (NSString *)Encoding;

// property setter: Encoding
- (void)setEncoding: (NSString *)input;

// property getter: Filename
- (NSString *)Filename;

// property setter: Filename
- (void)setFilename: (NSString *)input;

// property getter: LastErrorHtml
- (NSString *)LastErrorHtml;

// property getter: LastErrorText
- (NSString *)LastErrorText;

// property getter: LastErrorXml
- (NSString *)LastErrorXml;

// property getter: Micalg
- (NSString *)Micalg;

// property setter: Micalg
- (void)setMicalg: (NSString *)input;

// property getter: Name
- (NSString *)Name;

// property setter: Name
- (void)setName: (NSString *)input;

// property getter: NumEncryptCerts
- (NSNumber *)NumEncryptCerts;

// property getter: NumHeaderFields
- (NSNumber *)NumHeaderFields;

// property getter: NumParts
- (NSNumber *)NumParts;

// property getter: NumSignerCerts
- (NSNumber *)NumSignerCerts;

// property getter: Pkcs7CryptAlg
- (NSString *)Pkcs7CryptAlg;

// property setter: Pkcs7CryptAlg
- (void)setPkcs7CryptAlg: (NSString *)input;

// property getter: Pkcs7KeyLength
- (NSNumber *)Pkcs7KeyLength;

// property setter: Pkcs7KeyLength
- (void)setPkcs7KeyLength: (NSNumber *)intVal;

// property getter: Protocol
- (NSString *)Protocol;

// property setter: Protocol
- (void)setProtocol: (NSString *)input;

// property getter: SigningHashAlg
- (NSString *)SigningHashAlg;

// property setter: SigningHashAlg
- (void)setSigningHashAlg: (NSString *)input;

// property getter: UnwrapExtras
- (BOOL)UnwrapExtras;

// property setter: UnwrapExtras
- (void)setUnwrapExtras: (BOOL)boolVal;

// property getter: UseMmDescription
- (BOOL)UseMmDescription;

// property setter: UseMmDescription
- (void)setUseMmDescription: (BOOL)boolVal;

// property getter: UseXPkcs7
- (BOOL)UseXPkcs7;

// property setter: UseXPkcs7
- (void)setUseXPkcs7: (BOOL)boolVal;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// method: AddContentLength
- (void)AddContentLength;

// method: AddDetachedSignature
- (BOOL)AddDetachedSignature: (CkoCert *)cert;

// method: AddDetachedSignature2
- (BOOL)AddDetachedSignature2: (CkoCert *)cert 
	transferHeaderFields: (BOOL)transferHeaderFields;

// method: AddDetachedSignaturePk
- (BOOL)AddDetachedSignaturePk: (CkoCert *)cert 
	privateKey: (CkoPrivateKey *)privateKey;

// method: AddDetachedSignaturePk2
- (BOOL)AddDetachedSignaturePk2: (CkoCert *)cert 
	privateKey: (CkoPrivateKey *)privateKey 
	transferHeaderFields: (BOOL)transferHeaderFields;

// method: AddEncryptCert
- (BOOL)AddEncryptCert: (CkoCert *)cert;

// method: AddHeaderField
- (BOOL)AddHeaderField: (NSString *)name 
	value: (NSString *)value;

// method: AddPfxSourceData
- (BOOL)AddPfxSourceData: (NSData *)pfxData 
	password: (NSString *)password;

// method: AddPfxSourceFile
- (BOOL)AddPfxSourceFile: (NSString *)pfxFilePath 
	password: (NSString *)password;

// method: AppendPart
- (BOOL)AppendPart: (CkoMime *)mime;

// method: AppendPartFromFile
- (BOOL)AppendPartFromFile: (NSString *)path;

// method: AsnBodyToXml
- (NSString *)AsnBodyToXml;

// method: ClearEncryptCerts
- (void)ClearEncryptCerts;

// method: ContainsEncryptedParts
- (BOOL)ContainsEncryptedParts;

// method: ContainsSignedParts
- (BOOL)ContainsSignedParts;

// method: Convert8Bit
- (void)Convert8Bit;

// method: ConvertToMultipartAlt
- (void)ConvertToMultipartAlt;

// method: ConvertToMultipartMixed
- (void)ConvertToMultipartMixed;

// method: ConvertToSigned
- (BOOL)ConvertToSigned: (CkoCert *)cert;

// method: ConvertToSignedPk
- (BOOL)ConvertToSignedPk: (CkoCert *)cert 
	privateKey: (CkoPrivateKey *)privateKey;

// method: Decrypt
- (BOOL)Decrypt;

// method: Decrypt2
- (BOOL)Decrypt2: (CkoCert *)cert 
	privateKey: (CkoPrivateKey *)privateKey;

// method: DecryptUsingPfxData
- (BOOL)DecryptUsingPfxData: (NSData *)pfxData 
	password: (NSString *)password;

// method: DecryptUsingPfxFile
- (BOOL)DecryptUsingPfxFile: (NSString *)pfxFilePath 
	password: (NSString *)password;

// method: Encrypt
- (BOOL)Encrypt: (CkoCert *)cert;

// method: EncryptN
- (BOOL)EncryptN;

// method: ExtractPartsToFiles
- (CkoStringArray *)ExtractPartsToFiles: (NSString *)dirPath;

// method: FindIssuer
- (CkoCert *)FindIssuer: (CkoCert *)cert;

// method: GetBodyBinary
- (NSData *)GetBodyBinary;

// method: GetBodyDecoded
- (NSString *)GetBodyDecoded;

// method: GetBodyEncoded
- (NSString *)GetBodyEncoded;

// method: GetEncryptCert
- (CkoCert *)GetEncryptCert: (NSNumber *)index;

// method: GetEntireBody
- (NSString *)GetEntireBody;

// method: GetEntireHead
- (NSString *)GetEntireHead;

// method: GetHeaderField
- (NSString *)GetHeaderField: (NSString *)name;

// method: GetHeaderFieldAttribute
- (NSString *)GetHeaderFieldAttribute: (NSString *)name 
	attrName: (NSString *)attrName;

// method: GetHeaderFieldName
- (NSString *)GetHeaderFieldName: (NSNumber *)index;

// method: GetHeaderFieldValue
- (NSString *)GetHeaderFieldValue: (NSNumber *)index;

// method: GetMime
- (NSString *)GetMime;

// method: GetMimeBytes
- (NSData *)GetMimeBytes;

// method: GetPart
- (CkoMime *)GetPart: (NSNumber *)index;

// method: GetSignatureSigningTime
- (NSDate *)GetSignatureSigningTime: (NSNumber *)index;

// method: GetSignatureSigningTimeStr
- (NSString *)GetSignatureSigningTimeStr: (NSNumber *)index;

// method: GetSignerCert
- (CkoCert *)GetSignerCert: (NSNumber *)index;

// method: GetXml
- (NSString *)GetXml;

// method: HasSignatureSigningTime
- (BOOL)HasSignatureSigningTime: (NSNumber *)index;

// method: IsApplicationData
- (BOOL)IsApplicationData;

// method: IsAttachment
- (BOOL)IsAttachment;

// method: IsAudio
- (BOOL)IsAudio;

// method: IsEncrypted
- (BOOL)IsEncrypted;

// method: IsHtml
- (BOOL)IsHtml;

// method: IsImage
- (BOOL)IsImage;

// method: IsMultipart
- (BOOL)IsMultipart;

// method: IsMultipartAlternative
- (BOOL)IsMultipartAlternative;

// method: IsMultipartMixed
- (BOOL)IsMultipartMixed;

// method: IsMultipartRelated
- (BOOL)IsMultipartRelated;

// method: IsPlainText
- (BOOL)IsPlainText;

// method: IsSigned
- (BOOL)IsSigned;

// method: IsText
- (BOOL)IsText;

// method: IsUnlocked
- (BOOL)IsUnlocked;

// method: IsVideo
- (BOOL)IsVideo;

// method: IsXml
- (BOOL)IsXml;

// method: LoadMime
- (BOOL)LoadMime: (NSString *)mimeText;

// method: LoadMimeBytes
- (BOOL)LoadMimeBytes: (NSData *)bData;

// method: LoadMimeFile
- (BOOL)LoadMimeFile: (NSString *)path;

// method: LoadXml
- (BOOL)LoadXml: (NSString *)xmlText;

// method: LoadXmlFile
- (BOOL)LoadXmlFile: (NSString *)path;

// method: NewMessageRfc822
- (BOOL)NewMessageRfc822: (CkoMime *)mimeObject;

// method: NewMultipartAlternative
- (BOOL)NewMultipartAlternative;

// method: NewMultipartMixed
- (BOOL)NewMultipartMixed;

// method: NewMultipartRelated
- (BOOL)NewMultipartRelated;

// method: RemoveHeaderField
- (void)RemoveHeaderField: (NSString *)name 
	bAllOccurances: (BOOL)bAllOccurances;

// method: RemovePart
- (BOOL)RemovePart: (NSNumber *)index;

// method: SaveBody
- (BOOL)SaveBody: (NSString *)path;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: SaveMime
- (BOOL)SaveMime: (NSString *)path;

// method: SaveXml
- (BOOL)SaveXml: (NSString *)path;

// method: SetBody
- (void)SetBody: (NSString *)str;

// method: SetBodyFromBinary
- (BOOL)SetBodyFromBinary: (NSData *)dbuf;

// method: SetBodyFromEncoded
- (BOOL)SetBodyFromEncoded: (NSString *)encoding 
	str: (NSString *)str;

// method: SetBodyFromFile
- (BOOL)SetBodyFromFile: (NSString *)path;

// method: SetBodyFromHtml
- (BOOL)SetBodyFromHtml: (NSString *)str;

// method: SetBodyFromPlainText
- (BOOL)SetBodyFromPlainText: (NSString *)str;

// method: SetBodyFromXml
- (BOOL)SetBodyFromXml: (NSString *)str;

// method: SetHeaderField
- (BOOL)SetHeaderField: (NSString *)name 
	value: (NSString *)value;

// method: SetVerifyCert
- (void)SetVerifyCert: (CkoCert *)cert;

// method: UnlockComponent
- (BOOL)UnlockComponent: (NSString *)unlockCode;

// method: UnwrapSecurity
- (BOOL)UnwrapSecurity;

// method: UrlEncodeBody
- (void)UrlEncodeBody: (NSString *)charset;

// method: Verify
- (BOOL)Verify;


@end

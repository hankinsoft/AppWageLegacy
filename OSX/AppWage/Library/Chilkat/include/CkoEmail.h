// Chilkat Objective-C header.
// Generic/internal class name =  Email
// Wrapped Chilkat C++ class name =  CkEmail

@class CkoCert;
@class CkoStringArray;
@class CkoDateTime;
@class CkoMime;
@class CkoPrivateKey;


@interface CkoEmail : NSObject {

	@private
		void *m_obj;

}

- (id)init;
- (void)dealloc;
- (void)dispose;
- (NSString *)stringWithUtf8: (const char *)s;
- (void *)CppImplObj;
- (void)setCppImplObj: (void *)pObj;

// property getter: Body
- (NSString *)Body;

// property setter: Body
- (void)setBody: (NSString *)input;

// property getter: BounceAddress
- (NSString *)BounceAddress;

// property setter: BounceAddress
- (void)setBounceAddress: (NSString *)input;

// property getter: Charset
- (NSString *)Charset;

// property setter: Charset
- (void)setCharset: (NSString *)input;

// property getter: DebugLogFilePath
- (NSString *)DebugLogFilePath;

// property setter: DebugLogFilePath
- (void)setDebugLogFilePath: (NSString *)input;

// property getter: Decrypted
- (BOOL)Decrypted;

// property getter: EmailDate
- (NSDate *)EmailDate;

// property setter: EmailDate
- (void)setEmailDate: (NSDate *)dateVal;

// property getter: EmailDateStr
- (NSString *)EmailDateStr;

// property setter: EmailDateStr
- (void)setEmailDateStr: (NSString *)input;

// property getter: EncryptedBy
- (NSString *)EncryptedBy;

// property getter: FileDistList
- (NSString *)FileDistList;

// property setter: FileDistList
- (void)setFileDistList: (NSString *)input;

// property getter: From
- (NSString *)From;

// property setter: From
- (void)setFrom: (NSString *)input;

// property getter: FromAddress
- (NSString *)FromAddress;

// property setter: FromAddress
- (void)setFromAddress: (NSString *)input;

// property getter: FromName
- (NSString *)FromName;

// property setter: FromName
- (void)setFromName: (NSString *)input;

// property getter: Header
- (NSString *)Header;

// property getter: Language
- (NSString *)Language;

// property getter: LastErrorHtml
- (NSString *)LastErrorHtml;

// property getter: LastErrorText
- (NSString *)LastErrorText;

// property getter: LastErrorXml
- (NSString *)LastErrorXml;

// property getter: LocalDate
- (NSDate *)LocalDate;

// property setter: LocalDate
- (void)setLocalDate: (NSDate *)dateVal;

// property getter: LocalDateStr
- (NSString *)LocalDateStr;

// property setter: LocalDateStr
- (void)setLocalDateStr: (NSString *)input;

// property getter: Mailer
- (NSString *)Mailer;

// property setter: Mailer
- (void)setMailer: (NSString *)input;

// property getter: NumAlternatives
- (NSNumber *)NumAlternatives;

// property getter: NumAttachedMessages
- (NSNumber *)NumAttachedMessages;

// property getter: NumAttachments
- (NSNumber *)NumAttachments;

// property getter: NumBcc
- (NSNumber *)NumBcc;

// property getter: NumCC
- (NSNumber *)NumCC;

// property getter: NumDaysOld
- (NSNumber *)NumDaysOld;

// property getter: NumHeaderFields
- (NSNumber *)NumHeaderFields;

// property getter: NumRelatedItems
- (NSNumber *)NumRelatedItems;

// property getter: NumReplacePatterns
- (NSNumber *)NumReplacePatterns;

// property getter: NumReports
- (NSNumber *)NumReports;

// property getter: NumTo
- (NSNumber *)NumTo;

// property getter: OverwriteExisting
- (BOOL)OverwriteExisting;

// property setter: OverwriteExisting
- (void)setOverwriteExisting: (BOOL)boolVal;

// property getter: Pkcs7CryptAlg
- (NSString *)Pkcs7CryptAlg;

// property setter: Pkcs7CryptAlg
- (void)setPkcs7CryptAlg: (NSString *)input;

// property getter: Pkcs7KeyLength
- (NSNumber *)Pkcs7KeyLength;

// property setter: Pkcs7KeyLength
- (void)setPkcs7KeyLength: (NSNumber *)intVal;

// property getter: PreferredCharset
- (NSString *)PreferredCharset;

// property setter: PreferredCharset
- (void)setPreferredCharset: (NSString *)input;

// property getter: PrependHeaders
- (BOOL)PrependHeaders;

// property setter: PrependHeaders
- (void)setPrependHeaders: (BOOL)boolVal;

// property getter: ReceivedEncrypted
- (BOOL)ReceivedEncrypted;

// property getter: ReceivedSigned
- (BOOL)ReceivedSigned;

// property getter: ReplyTo
- (NSString *)ReplyTo;

// property setter: ReplyTo
- (void)setReplyTo: (NSString *)input;

// property getter: ReturnReceipt
- (BOOL)ReturnReceipt;

// property setter: ReturnReceipt
- (void)setReturnReceipt: (BOOL)boolVal;

// property getter: SendEncrypted
- (BOOL)SendEncrypted;

// property setter: SendEncrypted
- (void)setSendEncrypted: (BOOL)boolVal;

// property getter: SendSigned
- (BOOL)SendSigned;

// property setter: SendSigned
- (void)setSendSigned: (BOOL)boolVal;

// property getter: SignaturesValid
- (BOOL)SignaturesValid;

// property getter: SignedBy
- (NSString *)SignedBy;

// property getter: SigningHashAlg
- (NSString *)SigningHashAlg;

// property setter: SigningHashAlg
- (void)setSigningHashAlg: (NSString *)input;

// property getter: Size
- (NSNumber *)Size;

// property getter: Subject
- (NSString *)Subject;

// property setter: Subject
- (void)setSubject: (NSString *)input;

// property getter: Uidl
- (NSString *)Uidl;

// property getter: UnpackUseRelPaths
- (BOOL)UnpackUseRelPaths;

// property setter: UnpackUseRelPaths
- (void)setUnpackUseRelPaths: (BOOL)boolVal;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// method: AddAttachmentHeader
- (void)AddAttachmentHeader: (NSNumber *)index 
	fieldName: (NSString *)fieldName 
	fieldValue: (NSString *)fieldValue;

// method: AddBcc
- (BOOL)AddBcc: (NSString *)friendlyName 
	emailAddress: (NSString *)emailAddress;

// method: AddCC
- (BOOL)AddCC: (NSString *)friendlyName 
	emailAddress: (NSString *)emailAddress;

// method: AddDataAttachment
- (BOOL)AddDataAttachment: (NSString *)fileName 
	pByteData: (NSData *)pByteData 
	szByteData: (NSNumber *)szByteData;

// method: AddDataAttachment2
- (BOOL)AddDataAttachment2: (NSString *)fileName 
	content: (NSData *)content 
	contentType: (NSString *)contentType;

// method: AddEncryptCert
- (BOOL)AddEncryptCert: (CkoCert *)cert;

// method: AddFileAttachment
- (NSString *)AddFileAttachment: (NSString *)path;

// method: AddFileAttachment2
- (BOOL)AddFileAttachment2: (NSString *)path 
	contentType: (NSString *)contentType;

// method: AddHeaderField
- (void)AddHeaderField: (NSString *)fieldName 
	fieldValue: (NSString *)fieldValue;

// method: AddHeaderField2
- (void)AddHeaderField2: (NSString *)fieldName 
	fieldValue: (NSString *)fieldValue;

// method: AddHtmlAlternativeBody
- (BOOL)AddHtmlAlternativeBody: (NSString *)body;

// method: AddMultipleBcc
- (BOOL)AddMultipleBcc: (NSString *)commaSeparatedAddresses;

// method: AddMultipleCC
- (BOOL)AddMultipleCC: (NSString *)commaSeparatedAddresses;

// method: AddMultipleTo
- (BOOL)AddMultipleTo: (NSString *)commaSeparatedAddresses;

// method: AddPfxSourceData
- (BOOL)AddPfxSourceData: (NSData *)pfxData 
	password: (NSString *)password;

// method: AddPfxSourceFile
- (BOOL)AddPfxSourceFile: (NSString *)pfxFilePath 
	password: (NSString *)password;

// method: AddPlainTextAlternativeBody
- (BOOL)AddPlainTextAlternativeBody: (NSString *)body;

// method: AddRelatedData
- (NSString *)AddRelatedData: (NSString *)fileName 
	inData: (NSData *)inData;

// method: AddRelatedData2
- (void)AddRelatedData2: (NSData *)inData 
	fileNameInHtml: (NSString *)fileNameInHtml;

// method: AddRelatedData2P
- (void)AddRelatedData2P: (NSData *)pByteData 
	szByteData: (NSNumber *)szByteData 
	fileNameInHtml: (NSString *)fileNameInHtml;

// method: AddRelatedDataP
- (NSString *)AddRelatedDataP: (NSString *)nameInHtml 
	pByteData: (NSData *)pByteData 
	szByteData: (NSNumber *)szByteData;

// method: AddRelatedFile
- (NSString *)AddRelatedFile: (NSString *)path;

// method: AddRelatedFile2
- (BOOL)AddRelatedFile2: (NSString *)fileNameOnDisk 
	filenameInHtml: (NSString *)filenameInHtml;

// method: AddRelatedHeader
- (void)AddRelatedHeader: (NSNumber *)index 
	fieldName: (NSString *)fieldName 
	fieldValue: (NSString *)fieldValue;

// method: AddRelatedString
- (NSString *)AddRelatedString: (NSString *)nameInHtml 
	str: (NSString *)str 
	charset: (NSString *)charset;

// method: AddRelatedString2
- (void)AddRelatedString2: (NSString *)str 
	charset: (NSString *)charset 
	filenameInHtml: (NSString *)filenameInHtml;

// method: AddStringAttachment
- (BOOL)AddStringAttachment: (NSString *)fileName 
	str: (NSString *)str;

// method: AddStringAttachment2
- (BOOL)AddStringAttachment2: (NSString *)fileName 
	str: (NSString *)str 
	charset: (NSString *)charset;

// method: AddTo
- (BOOL)AddTo: (NSString *)friendlyName 
	emailAddress: (NSString *)emailAddress;

// method: AddiCalendarAlternativeBody
- (BOOL)AddiCalendarAlternativeBody: (NSString *)body 
	methodName: (NSString *)methodName;

// method: AesDecrypt
- (BOOL)AesDecrypt: (NSString *)password;

// method: AesEncrypt
- (BOOL)AesEncrypt: (NSString *)password;

// method: AppendToBody
- (void)AppendToBody: (NSString *)str;

// method: AspUnpack
- (BOOL)AspUnpack: (NSString *)prefix 
	saveDir: (NSString *)saveDir 
	urlPath: (NSString *)urlPath 
	cleanFiles: (BOOL)cleanFiles;

// method: AspUnpack2
- (NSData *)AspUnpack2: (NSString *)prefix 
	saveDir: (NSString *)saveDir 
	urlPath: (NSString *)urlPath 
	cleanFiles: (BOOL)cleanFiles;

// method: AttachMessage
- (BOOL)AttachMessage: (NSData *)mimeBytes;

// method: BEncodeBytes
- (NSString *)BEncodeBytes: (NSData *)pByteData 
	szByteData: (NSNumber *)szByteData 
	charset: (NSString *)charset;

// method: BEncodeString
- (NSString *)BEncodeString: (NSString *)str 
	charset: (NSString *)charset;

// method: ClearBcc
- (void)ClearBcc;

// method: ClearCC
- (void)ClearCC;

// method: ClearEncryptCerts
- (void)ClearEncryptCerts;

// method: ClearTo
- (void)ClearTo;

// method: Clone
- (CkoEmail *)Clone;

// method: ComputeGlobalKey
- (NSString *)ComputeGlobalKey: (NSString *)encoding 
	bFold: (BOOL)bFold;

// method: CreateDsn
- (CkoEmail *)CreateDsn: (NSString *)explanation 
	xmlDeliveryStatus: (NSString *)xmlDeliveryStatus 
	bHeaderOnly: (BOOL)bHeaderOnly;

// method: CreateForward
- (CkoEmail *)CreateForward;

// method: CreateMdn
- (CkoEmail *)CreateMdn: (NSString *)explanation 
	xmlMdnFields: (NSString *)xmlMdnFields 
	bHeaderOnly: (BOOL)bHeaderOnly;

// method: CreateReply
- (CkoEmail *)CreateReply;

// method: CreateTempMht
- (NSString *)CreateTempMht: (NSString *)inPath;

// method: DropAttachments
- (void)DropAttachments;

// method: DropRelatedItem
- (void)DropRelatedItem: (NSNumber *)index;

// method: DropRelatedItems
- (void)DropRelatedItems;

// method: DropSingleAttachment
- (BOOL)DropSingleAttachment: (NSNumber *)index;

// method: FindIssuer
- (CkoCert *)FindIssuer: (CkoCert *)cert;

// method: GenerateFilename
- (NSString *)GenerateFilename;

// method: GetAltHeaderField
- (NSString *)GetAltHeaderField: (NSNumber *)index 
	fieldName: (NSString *)fieldName;

// method: GetAlternativeBody
- (NSString *)GetAlternativeBody: (NSNumber *)index;

// method: GetAlternativeBodyByContentType
- (NSString *)GetAlternativeBodyByContentType: (NSString *)contentType;

// method: GetAlternativeContentType
- (NSString *)GetAlternativeContentType: (NSNumber *)index;

// method: GetAttachedMessage
- (CkoEmail *)GetAttachedMessage: (NSNumber *)index;

// method: GetAttachedMessageFilename
- (NSString *)GetAttachedMessageFilename: (NSNumber *)index;

// method: GetAttachmentContentID
- (NSString *)GetAttachmentContentID: (NSNumber *)index;

// method: GetAttachmentContentType
- (NSString *)GetAttachmentContentType: (NSNumber *)index;

// method: GetAttachmentData
- (NSData *)GetAttachmentData: (NSNumber *)index;

// method: GetAttachmentFilename
- (NSString *)GetAttachmentFilename: (NSNumber *)index;

// method: GetAttachmentHeader
- (NSString *)GetAttachmentHeader: (NSNumber *)index 
	fieldName: (NSString *)fieldName;

// method: GetAttachmentSize
- (NSNumber *)GetAttachmentSize: (NSNumber *)index;

// method: GetAttachmentString
- (NSString *)GetAttachmentString: (NSNumber *)index 
	charset: (NSString *)charset;

// method: GetAttachmentStringCrLf
- (NSString *)GetAttachmentStringCrLf: (NSNumber *)index 
	charset: (NSString *)charset;

// method: GetBcc
- (NSString *)GetBcc: (NSNumber *)index;

// method: GetBccAddr
- (NSString *)GetBccAddr: (NSNumber *)index;

// method: GetBccName
- (NSString *)GetBccName: (NSNumber *)index;

// method: GetCC
- (NSString *)GetCC: (NSNumber *)index;

// method: GetCcAddr
- (NSString *)GetCcAddr: (NSNumber *)index;

// method: GetCcName
- (NSString *)GetCcName: (NSNumber *)index;

// method: GetDeliveryStatusInfo
- (NSString *)GetDeliveryStatusInfo: (NSString *)fieldName;

// method: GetDsnFinalRecipients
- (CkoStringArray *)GetDsnFinalRecipients;

// method: GetDt
- (CkoDateTime *)GetDt;

// method: GetEncryptCert
- (CkoCert *)GetEncryptCert;

// method: GetEncryptedByCert
- (CkoCert *)GetEncryptedByCert;

// method: GetFileContent
- (NSData *)GetFileContent: (NSString *)path;

// method: GetHeaderField
- (NSString *)GetHeaderField: (NSString *)fieldName;

// method: GetHeaderFieldName
- (NSString *)GetHeaderFieldName: (NSNumber *)index;

// method: GetHeaderFieldValue
- (NSString *)GetHeaderFieldValue: (NSNumber *)index;

// method: GetHtmlBody
- (NSString *)GetHtmlBody;

// method: GetImapUid
- (NSNumber *)GetImapUid;

// method: GetLinkedDomains
- (void)GetLinkedDomains: (CkoStringArray *)sa;

// method: GetMbHeaderField
- (NSData *)GetMbHeaderField: (NSString *)fieldName;

// method: GetMbHeaderField2
- (NSData *)GetMbHeaderField2: (NSString *)charset 
	fieldName: (NSString *)fieldName;

// method: GetMbHtmlBody
- (NSData *)GetMbHtmlBody: (NSString *)charset;

// method: GetMbPlainTextBody
- (NSData *)GetMbPlainTextBody: (NSString *)charset;

// method: GetMime
- (NSString *)GetMime;

// method: GetMimeBinary
- (NSData *)GetMimeBinary;

// method: GetMimeObject
- (CkoMime *)GetMimeObject;

// method: GetPlainTextBody
- (NSString *)GetPlainTextBody;

// method: GetRelatedContentID
- (NSString *)GetRelatedContentID: (NSNumber *)index;

// method: GetRelatedContentLocation
- (NSString *)GetRelatedContentLocation: (NSNumber *)index;

// method: GetRelatedContentType
- (NSString *)GetRelatedContentType: (NSNumber *)index;

// method: GetRelatedData
- (NSData *)GetRelatedData: (NSNumber *)index;

// method: GetRelatedFilename
- (NSString *)GetRelatedFilename: (NSNumber *)index;

// method: GetRelatedString
- (NSString *)GetRelatedString: (NSNumber *)index 
	charset: (NSString *)charset;

// method: GetRelatedStringCrLf
- (NSString *)GetRelatedStringCrLf: (NSNumber *)index 
	charset: (NSString *)charset;

// method: GetReplacePattern
- (NSString *)GetReplacePattern: (NSNumber *)index;

// method: GetReplaceString
- (NSString *)GetReplaceString: (NSNumber *)index;

// method: GetReplaceString2
- (NSString *)GetReplaceString2: (NSString *)pattern;

// method: GetReport
- (NSString *)GetReport: (NSNumber *)index;

// method: GetSignedByCert
- (CkoCert *)GetSignedByCert;

// method: GetSigningCert
- (CkoCert *)GetSigningCert;

// method: GetTo
- (NSString *)GetTo: (NSNumber *)index;

// method: GetToAddr
- (NSString *)GetToAddr: (NSNumber *)index;

// method: GetToName
- (NSString *)GetToName: (NSNumber *)index;

// method: GetXml
- (NSString *)GetXml;

// method: HasHeaderMatching
- (BOOL)HasHeaderMatching: (NSString *)fieldName 
	valuePattern: (NSString *)valuePattern 
	caseInsensitive: (BOOL)caseInsensitive;

// method: HasHtmlBody
- (BOOL)HasHtmlBody;

// method: HasPlainTextBody
- (BOOL)HasPlainTextBody;

// method: IsMultipartReport
- (BOOL)IsMultipartReport;

// method: LoadEml
- (BOOL)LoadEml: (NSString *)mimePath;

// method: LoadXml
- (BOOL)LoadXml: (NSString *)xmlPath;

// method: LoadXmlString
- (BOOL)LoadXmlString: (NSString *)xmlStr;

// method: QEncodeBytes
- (NSString *)QEncodeBytes: (NSData *)pByteData 
	szByteData: (NSNumber *)szByteData 
	charset: (NSString *)charset;

// method: QEncodeString
- (NSString *)QEncodeString: (NSString *)str 
	charset: (NSString *)charset;

// method: RemoveAttachedMessage
- (void)RemoveAttachedMessage: (NSNumber *)index;

// method: RemoveAttachedMessages
- (void)RemoveAttachedMessages;

// method: RemoveAttachmentPaths
- (void)RemoveAttachmentPaths;

// method: RemoveHeaderField
- (void)RemoveHeaderField: (NSString *)fieldName;

// method: RemoveHtmlAlternative
- (void)RemoveHtmlAlternative;

// method: RemovePlainTextAlternative
- (void)RemovePlainTextAlternative;

// method: SaveAllAttachments
- (BOOL)SaveAllAttachments: (NSString *)directory;

// method: SaveAttachedFile
- (BOOL)SaveAttachedFile: (NSNumber *)index 
	directory: (NSString *)directory;

// method: SaveEml
- (BOOL)SaveEml: (NSString *)path;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: SaveRelatedItem
- (BOOL)SaveRelatedItem: (NSNumber *)index 
	directory: (NSString *)directory;

// method: SaveXml
- (BOOL)SaveXml: (NSString *)path;

// method: SetAttachmentCharset
- (BOOL)SetAttachmentCharset: (NSNumber *)index 
	charset: (NSString *)charset;

// method: SetAttachmentDisposition
- (BOOL)SetAttachmentDisposition: (NSNumber *)index 
	disposition: (NSString *)disposition;

// method: SetAttachmentFilename
- (BOOL)SetAttachmentFilename: (NSNumber *)index 
	filename: (NSString *)filename;

// method: SetDecryptCert2
- (BOOL)SetDecryptCert2: (CkoCert *)cert 
	key: (CkoPrivateKey *)key;

// method: SetDt
- (BOOL)SetDt: (CkoDateTime *)dt;

// method: SetEncryptCert
- (BOOL)SetEncryptCert: (CkoCert *)cert;

// method: SetFromMimeBytes
- (BOOL)SetFromMimeBytes: (NSData *)mimeBytes;

// method: SetFromMimeBytes2
- (BOOL)SetFromMimeBytes2: (NSData *)mimeBytes 
	charset: (NSString *)charset;

// method: SetFromMimeObject
- (BOOL)SetFromMimeObject: (CkoMime *)mime;

// method: SetFromMimeText
- (BOOL)SetFromMimeText: (NSString *)mimeText;

// method: SetFromXmlText
- (BOOL)SetFromXmlText: (NSString *)xmlStr;

// method: SetHtmlBody
- (void)SetHtmlBody: (NSString *)html;

// method: SetMbHtmlBody
- (BOOL)SetMbHtmlBody: (NSString *)charset 
	pByteData: (NSData *)pByteData 
	szByteData: (NSNumber *)szByteData;

// method: SetMbPlainTextBody
- (BOOL)SetMbPlainTextBody: (NSString *)charset 
	pByteData: (NSData *)pByteData 
	szByteData: (NSNumber *)szByteData;

// method: SetRelatedFilename
- (BOOL)SetRelatedFilename: (NSNumber *)index 
	filename: (NSString *)filename;

// method: SetReplacePattern
- (BOOL)SetReplacePattern: (NSString *)pattern 
	replaceString: (NSString *)replaceString;

// method: SetSigningCert
- (BOOL)SetSigningCert: (CkoCert *)cert;

// method: SetSigningCert2
- (BOOL)SetSigningCert2: (CkoCert *)cert 
	key: (CkoPrivateKey *)key;

// method: SetTextBody
- (void)SetTextBody: (NSString *)bodyText 
	contentType: (NSString *)contentType;

// method: UidlEquals
- (BOOL)UidlEquals: (CkoEmail *)e;

// method: UnSpamify
- (void)UnSpamify;

// method: UnpackHtml
- (BOOL)UnpackHtml: (NSString *)unpackDir 
	htmlFilename: (NSString *)htmlFilename 
	partsSubdir: (NSString *)partsSubdir;

// method: UnzipAttachments
- (BOOL)UnzipAttachments;

// method: ZipAttachments
- (BOOL)ZipAttachments: (NSString *)zipFilename;


@end

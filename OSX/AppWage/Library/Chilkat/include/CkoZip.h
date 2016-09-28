// Chilkat Objective-C header.
// Generic/internal class name =  Zip
// Wrapped Chilkat C++ class name =  CkZip

@class CkoZipEntry;
@class CkoStringArray;


@class CkoZipProgress;

@interface CkoZip : NSObject {

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
- (void)setEventCallbackObject: (CkoZipProgress *)eventObj;

// property getter: AppendFromDir
- (NSString *)AppendFromDir;

// property setter: AppendFromDir
- (void)setAppendFromDir: (NSString *)input;

// property getter: CaseSensitive
- (BOOL)CaseSensitive;

// property setter: CaseSensitive
- (void)setCaseSensitive: (BOOL)boolVal;

// property getter: ClearArchiveAttribute
- (BOOL)ClearArchiveAttribute;

// property setter: ClearArchiveAttribute
- (void)setClearArchiveAttribute: (BOOL)boolVal;

// property getter: ClearReadOnlyAttr
- (BOOL)ClearReadOnlyAttr;

// property setter: ClearReadOnlyAttr
- (void)setClearReadOnlyAttr: (BOOL)boolVal;

// property getter: Comment
- (NSString *)Comment;

// property setter: Comment
- (void)setComment: (NSString *)input;

// property getter: DebugLogFilePath
- (NSString *)DebugLogFilePath;

// property setter: DebugLogFilePath
- (void)setDebugLogFilePath: (NSString *)input;

// property getter: DecryptPassword
- (NSString *)DecryptPassword;

// property setter: DecryptPassword
- (void)setDecryptPassword: (NSString *)input;

// property getter: DiscardPaths
- (BOOL)DiscardPaths;

// property setter: DiscardPaths
- (void)setDiscardPaths: (BOOL)boolVal;

// property getter: EncryptKeyLength
- (NSNumber *)EncryptKeyLength;

// property setter: EncryptKeyLength
- (void)setEncryptKeyLength: (NSNumber *)intVal;

// property getter: EncryptPassword
- (NSString *)EncryptPassword;

// property setter: EncryptPassword
- (void)setEncryptPassword: (NSString *)input;

// property getter: Encryption
- (NSNumber *)Encryption;

// property setter: Encryption
- (void)setEncryption: (NSNumber *)intVal;

// property getter: FileCount
- (NSNumber *)FileCount;

// property getter: FileName
- (NSString *)FileName;

// property setter: FileName
- (void)setFileName: (NSString *)input;

// property getter: HasZipFormatErrors
- (BOOL)HasZipFormatErrors;

// property getter: HeartbeatMs
- (NSNumber *)HeartbeatMs;

// property setter: HeartbeatMs
- (void)setHeartbeatMs: (NSNumber *)intVal;

// property getter: IgnoreAccessDenied
- (BOOL)IgnoreAccessDenied;

// property setter: IgnoreAccessDenied
- (void)setIgnoreAccessDenied: (BOOL)boolVal;

// property getter: LastErrorHtml
- (NSString *)LastErrorHtml;

// property getter: LastErrorText
- (NSString *)LastErrorText;

// property getter: LastErrorXml
- (NSString *)LastErrorXml;

// property getter: NumEntries
- (NSNumber *)NumEntries;

// property getter: OemCodePage
- (NSNumber *)OemCodePage;

// property setter: OemCodePage
- (void)setOemCodePage: (NSNumber *)intVal;

// property getter: OverwriteExisting
- (BOOL)OverwriteExisting;

// property setter: OverwriteExisting
- (void)setOverwriteExisting: (BOOL)boolVal;

// property getter: PasswordProtect
- (BOOL)PasswordProtect;

// property setter: PasswordProtect
- (void)setPasswordProtect: (BOOL)boolVal;

// property getter: PathPrefix
- (NSString *)PathPrefix;

// property setter: PathPrefix
- (void)setPathPrefix: (NSString *)input;

// property getter: Proxy
- (NSString *)Proxy;

// property setter: Proxy
- (void)setProxy: (NSString *)input;

// property getter: TempDir
- (NSString *)TempDir;

// property setter: TempDir
- (void)setTempDir: (NSString *)input;

// property getter: TextFlag
- (BOOL)TextFlag;

// property setter: TextFlag
- (void)setTextFlag: (BOOL)boolVal;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// property getter: Zipx
- (BOOL)Zipx;

// property setter: Zipx
- (void)setZipx: (BOOL)boolVal;

// property getter: ZipxDefaultAlg
- (NSString *)ZipxDefaultAlg;

// property setter: ZipxDefaultAlg
- (void)setZipxDefaultAlg: (NSString *)input;

// method: AddNoCompressExtension
- (void)AddNoCompressExtension: (NSString *)fileExtension;

// method: AppendBase64
- (CkoZipEntry *)AppendBase64: (NSString *)pathInZip 
	data: (NSString *)data;

// method: AppendCompressed
- (CkoZipEntry *)AppendCompressed: (NSString *)pathInZip 
	data: (NSData *)data;

// method: AppendData
- (CkoZipEntry *)AppendData: (NSString *)pathInZip 
	data: (NSData *)data;

// method: AppendData2
- (CkoZipEntry *)AppendData2: (NSString *)pathInZip 
	pByteData: (NSData *)pByteData 
	szByteData: (NSNumber *)szByteData;

// method: AppendFiles
- (BOOL)AppendFiles: (NSString *)filePattern 
	recurse: (BOOL)recurse;

// method: AppendFilesEx
- (BOOL)AppendFilesEx: (NSString *)filePattern 
	recurse: (BOOL)recurse 
	saveExtraPath: (BOOL)saveExtraPath 
	archiveOnly: (BOOL)archiveOnly 
	includeHidden: (BOOL)includeHidden 
	includeSystem: (BOOL)includeSystem;

// method: AppendHex
- (CkoZipEntry *)AppendHex: (NSString *)pathInZip 
	data: (NSString *)data;

// method: AppendMultiple
- (BOOL)AppendMultiple: (CkoStringArray *)fileSpecs 
	recurse: (BOOL)recurse;

// method: AppendNew
- (CkoZipEntry *)AppendNew: (NSString *)pathInZip;

// method: AppendNewDir
- (CkoZipEntry *)AppendNewDir: (NSString *)pathInZip;

// method: AppendOneFileOrDir
- (BOOL)AppendOneFileOrDir: (NSString *)path 
	saveExtraPath: (BOOL)saveExtraPath;

// method: AppendString
- (CkoZipEntry *)AppendString: (NSString *)pathInZip 
	str: (NSString *)str;

// method: AppendString2
- (CkoZipEntry *)AppendString2: (NSString *)pathInZip 
	str: (NSString *)str 
	charset: (NSString *)charset;

// method: AppendZip
- (BOOL)AppendZip: (NSString *)zipPath;

// method: CloseZip
- (void)CloseZip;

// method: DeleteEntry
- (BOOL)DeleteEntry: (CkoZipEntry *)entry;

// method: ExcludeDir
- (void)ExcludeDir: (NSString *)dirName;

// method: Extract
- (BOOL)Extract: (NSString *)dirPath;

// method: ExtractInto
- (BOOL)ExtractInto: (NSString *)dirPath;

// method: ExtractMatching
- (BOOL)ExtractMatching: (NSString *)dirPath 
	pattern: (NSString *)pattern;

// method: ExtractNewer
- (BOOL)ExtractNewer: (NSString *)dirPath;

// method: ExtractOne
- (BOOL)ExtractOne: (CkoZipEntry *)entry 
	dirPath: (NSString *)dirPath;

// method: FirstEntry
- (CkoZipEntry *)FirstEntry;

// method: FirstMatchingEntry
- (CkoZipEntry *)FirstMatchingEntry: (NSString *)pattern;

// method: GetDirectoryAsXML
- (NSString *)GetDirectoryAsXML;

// method: GetEntryByID
- (CkoZipEntry *)GetEntryByID: (NSNumber *)entryID;

// method: GetEntryByIndex
- (CkoZipEntry *)GetEntryByIndex: (NSNumber *)index;

// method: GetEntryByName
- (CkoZipEntry *)GetEntryByName: (NSString *)entryName;

// method: GetExclusions
- (CkoStringArray *)GetExclusions;

// method: InsertNew
- (CkoZipEntry *)InsertNew: (NSString *)pathInZip 
	beforeIndex: (NSNumber *)beforeIndex;

// method: IsNoCompressExtension
- (BOOL)IsNoCompressExtension: (NSString *)fileExtension;

// method: IsPasswordProtected
- (BOOL)IsPasswordProtected: (NSString *)zipPath;

// method: IsUnlocked
- (BOOL)IsUnlocked;

// method: NewZip
- (BOOL)NewZip: (NSString *)zipPath;

// method: OpenFromByteData
- (BOOL)OpenFromByteData: (NSData *)byteData;

// method: OpenFromMemory
- (BOOL)OpenFromMemory: (NSData *)pByteData 
	szByteData: (NSNumber *)szByteData;

// method: OpenFromWeb
- (BOOL)OpenFromWeb: (NSString *)url;

// method: OpenZip
- (BOOL)OpenZip: (NSString *)zipPath;

// method: QuickAppend
- (BOOL)QuickAppend: (NSString *)zipPath;

// method: RemoveNoCompressExtension
- (void)RemoveNoCompressExtension: (NSString *)fileExtension;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: SetCompressionLevel
- (void)SetCompressionLevel: (NSNumber *)level;

// method: SetExclusions
- (void)SetExclusions: (CkoStringArray *)excludePatterns;

// method: SetPassword
- (void)SetPassword: (NSString *)password;

// method: UnlockComponent
- (BOOL)UnlockComponent: (NSString *)regCode;

// method: Unzip
- (NSNumber *)Unzip: (NSString *)dirPath;

// method: UnzipInto
- (NSNumber *)UnzipInto: (NSString *)dirPath;

// method: UnzipMatching
- (NSNumber *)UnzipMatching: (NSString *)dirPath 
	pattern: (NSString *)pattern 
	verbose: (BOOL)verbose;

// method: UnzipMatchingInto
- (NSNumber *)UnzipMatchingInto: (NSString *)dirPath 
	pattern: (NSString *)pattern 
	verbose: (BOOL)verbose;

// method: UnzipNewer
- (NSNumber *)UnzipNewer: (NSString *)dirPath;

// method: VerifyPassword
- (BOOL)VerifyPassword;

// method: WriteToMemory
- (NSData *)WriteToMemory;

// method: WriteZip
- (BOOL)WriteZip;

// method: WriteZipAndClose
- (BOOL)WriteZipAndClose;


@end

// Chilkat Objective-C header.
// Generic/internal class name =  Gzip
// Wrapped Chilkat C++ class name =  CkGzip

@class CkoDateTime;


@interface CkoGzip : NSObject {

	@private
		void *m_obj;

}

- (id)init;
- (void)dealloc;
- (void)dispose;
- (NSString *)stringWithUtf8: (const char *)s;
- (void *)CppImplObj;
- (void)setCppImplObj: (void *)pObj;

// property getter: Comment
- (NSString *)Comment;

// property setter: Comment
- (void)setComment: (NSString *)input;

// property getter: DebugLogFilePath
- (NSString *)DebugLogFilePath;

// property setter: DebugLogFilePath
- (void)setDebugLogFilePath: (NSString *)input;

// property getter: ExtraData
- (NSData *)ExtraData;

// property setter: ExtraData
- (void)setExtraData: (NSData *)data;

// property getter: ExtraData
- (NSMutableData *)ExtraDataMutable;

// property setter: ExtraData
- (void)setExtraDataMutable: (NSMutableData *)data;

// property getter: Filename
- (NSString *)Filename;

// property setter: Filename
- (void)setFilename: (NSString *)input;

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

// property getter: LastMod
- (NSDate *)LastMod;

// property setter: LastMod
- (void)setLastMod: (NSDate *)dateVal;

// property getter: LastModStr
- (NSString *)LastModStr;

// property setter: LastModStr
- (void)setLastModStr: (NSString *)input;

// property getter: UseCurrentDate
- (BOOL)UseCurrentDate;

// property setter: UseCurrentDate
- (void)setUseCurrentDate: (BOOL)boolVal;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// method: CompressFile
- (BOOL)CompressFile: (NSString *)srcPath 
	destPath: (NSString *)destPath;

// method: CompressFile2
- (BOOL)CompressFile2: (NSString *)srcPath 
	embeddedFilename: (NSString *)embeddedFilename 
	destPath: (NSString *)destPath;

// method: CompressFileToMem
- (NSData *)CompressFileToMem: (NSString *)srcPath;

// method: CompressMemToFile
- (BOOL)CompressMemToFile: (NSData *)db 
	destPath: (NSString *)destPath;

// method: CompressMemory
- (NSData *)CompressMemory: (NSData *)dbIn;

// method: CompressString
- (NSData *)CompressString: (NSString *)inStr 
	destCharset: (NSString *)destCharset;

// method: CompressStringENC
- (NSString *)CompressStringENC: (NSString *)strIn 
	charset: (NSString *)charset 
	encoding: (NSString *)encoding;

// method: CompressStringToFile
- (BOOL)CompressStringToFile: (NSString *)inStr 
	destCharset: (NSString *)destCharset 
	destPath: (NSString *)destPath;

// method: Decode
- (NSData *)Decode: (NSString *)str 
	encoding: (NSString *)encoding;

// method: DeflateStringENC
- (NSString *)DeflateStringENC: (NSString *)str 
	charset: (NSString *)charset 
	encoding: (NSString *)encoding;

// method: Encode
- (NSString *)Encode: (NSData *)byteData 
	encoding: (NSString *)encoding;

// method: ExamineFile
- (BOOL)ExamineFile: (NSString *)inGzPath;

// method: ExamineMemory
- (BOOL)ExamineMemory: (NSData *)inGzData;

// method: GetDt
- (CkoDateTime *)GetDt;

// method: InflateStringENC
- (NSString *)InflateStringENC: (NSString *)str 
	charset: (NSString *)charset 
	encoding: (NSString *)encoding;

// method: IsUnlocked
- (BOOL)IsUnlocked;

// method: ReadFile
- (NSData *)ReadFile: (NSString *)path;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: SetDt
- (BOOL)SetDt: (CkoDateTime *)dt;

// method: UnTarGz
- (BOOL)UnTarGz: (NSString *)gzPath 
	destDir: (NSString *)destDir 
	bNoAbsolute: (BOOL)bNoAbsolute;

// method: UncompressFile
- (BOOL)UncompressFile: (NSString *)srcPath 
	destPath: (NSString *)destPath;

// method: UncompressFileToMem
- (NSData *)UncompressFileToMem: (NSString *)srcPath;

// method: UncompressFileToString
- (NSString *)UncompressFileToString: (NSString *)srcPath 
	inCharset: (NSString *)inCharset;

// method: UncompressMemToFile
- (BOOL)UncompressMemToFile: (NSData *)db 
	destPath: (NSString *)destPath;

// method: UncompressMemory
- (NSData *)UncompressMemory: (NSData *)dbIn;

// method: UncompressString
- (NSString *)UncompressString: (NSData *)inData 
	inCharset: (NSString *)inCharset;

// method: UncompressStringENC
- (NSString *)UncompressStringENC: (NSString *)strIn 
	charset: (NSString *)charset 
	encoding: (NSString *)encoding;

// method: UnlockComponent
- (BOOL)UnlockComponent: (NSString *)unlockCode;

// method: WriteFile
- (BOOL)WriteFile: (NSString *)path 
	binaryData: (NSData *)binaryData;

// method: XfdlToXml
- (NSString *)XfdlToXml: (NSString *)xfdl;


@end

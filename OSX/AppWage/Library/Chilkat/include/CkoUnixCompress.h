// Chilkat Objective-C header.
// Generic/internal class name =  UnixCompress
// Wrapped Chilkat C++ class name =  CkUnixCompress



@interface CkoUnixCompress : NSObject {

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

// method: CompressFile
- (BOOL)CompressFile: (NSString *)srcPath 
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
	charset: (NSString *)charset;

// method: CompressStringToFile
- (BOOL)CompressStringToFile: (NSString *)inStr 
	charset: (NSString *)charset 
	destPath: (NSString *)destPath;

// method: IsUnlocked
- (BOOL)IsUnlocked;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: UnTarZ
- (BOOL)UnTarZ: (NSString *)zPath 
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

// method: UnlockComponent
- (BOOL)UnlockComponent: (NSString *)unlockCode;


@end

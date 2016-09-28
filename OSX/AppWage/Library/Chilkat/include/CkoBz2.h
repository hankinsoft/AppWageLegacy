// Chilkat Objective-C header.
// Generic/internal class name =  Bz2
// Wrapped Chilkat C++ class name =  CkBz2



@interface CkoBz2 : NSObject {

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

// method: CompressFile
- (BOOL)CompressFile: (NSString *)inPath 
	toPath: (NSString *)toPath;

// method: CompressFileToMem
- (NSData *)CompressFileToMem: (NSString *)inPath;

// method: CompressMemToFile
- (BOOL)CompressMemToFile: (NSData *)inData 
	toPath: (NSString *)toPath;

// method: CompressMemory
- (NSData *)CompressMemory: (NSData *)inData;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: UncompressFile
- (BOOL)UncompressFile: (NSString *)inPath 
	toPath: (NSString *)toPath;

// method: UncompressFileToMem
- (NSData *)UncompressFileToMem: (NSString *)inPath;

// method: UncompressMemToFile
- (BOOL)UncompressMemToFile: (NSData *)inData 
	toPath: (NSString *)toPath;

// method: UncompressMemory
- (NSData *)UncompressMemory: (NSData *)inData;

// method: UnlockComponent
- (BOOL)UnlockComponent: (NSString *)unlockCode;


@end

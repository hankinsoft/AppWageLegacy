// Chilkat Objective-C header.
// Generic/internal class name =  Compression
// Wrapped Chilkat C++ class name =  CkCompression



@interface CkoCompression : NSObject {

	@private
		void *m_obj;

}

- (id)init;
- (void)dealloc;
- (void)dispose;
- (NSString *)stringWithUtf8: (const char *)s;
- (void *)CppImplObj;
- (void)setCppImplObj: (void *)pObj;

// property getter: Algorithm
- (NSString *)Algorithm;

// property setter: Algorithm
- (void)setAlgorithm: (NSString *)input;

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

// method: BeginCompressBytes
- (NSData *)BeginCompressBytes: (NSData *)bData;

// method: BeginCompressBytesENC
- (NSString *)BeginCompressBytesENC: (NSData *)bData;

// method: BeginCompressString
- (NSData *)BeginCompressString: (NSString *)str;

// method: BeginCompressStringENC
- (NSString *)BeginCompressStringENC: (NSString *)str;

// method: BeginDecompressBytes
- (NSData *)BeginDecompressBytes: (NSData *)bData;

// method: BeginDecompressBytesENC
- (NSData *)BeginDecompressBytesENC: (NSString *)str;

// method: BeginDecompressString
- (NSString *)BeginDecompressString: (NSData *)bData;

// method: BeginDecompressStringENC
- (NSString *)BeginDecompressStringENC: (NSString *)str;

// method: CompressBytes
- (NSData *)CompressBytes: (NSData *)bData;

// method: CompressBytesENC
- (NSString *)CompressBytesENC: (NSData *)bData;

// method: CompressFile
- (BOOL)CompressFile: (NSString *)srcPath 
	destPath: (NSString *)destPath;

// method: CompressString
- (NSData *)CompressString: (NSString *)str;

// method: CompressStringENC
- (NSString *)CompressStringENC: (NSString *)str;

// method: DecompressBytes
- (NSData *)DecompressBytes: (NSData *)bData;

// method: DecompressBytesENC
- (NSData *)DecompressBytesENC: (NSString *)str;

// method: DecompressFile
- (BOOL)DecompressFile: (NSString *)srcPath 
	destPath: (NSString *)destPath;

// method: DecompressString
- (NSString *)DecompressString: (NSData *)bData;

// method: DecompressStringENC
- (NSString *)DecompressStringENC: (NSString *)str;

// method: EndCompressBytes
- (NSData *)EndCompressBytes;

// method: EndCompressBytesENC
- (NSString *)EndCompressBytesENC;

// method: EndCompressString
- (NSData *)EndCompressString;

// method: EndCompressStringENC
- (NSString *)EndCompressStringENC;

// method: EndDecompressBytes
- (NSData *)EndDecompressBytes;

// method: EndDecompressBytesENC
- (NSData *)EndDecompressBytesENC;

// method: EndDecompressString
- (NSString *)EndDecompressString;

// method: EndDecompressStringENC
- (NSString *)EndDecompressStringENC;

// method: MoreCompressBytes
- (NSData *)MoreCompressBytes: (NSData *)bData;

// method: MoreCompressBytesENC
- (NSString *)MoreCompressBytesENC: (NSData *)bData;

// method: MoreCompressString
- (NSData *)MoreCompressString: (NSString *)str;

// method: MoreCompressStringENC
- (NSString *)MoreCompressStringENC: (NSString *)str;

// method: MoreDecompressBytes
- (NSData *)MoreDecompressBytes: (NSData *)bData;

// method: MoreDecompressBytesENC
- (NSData *)MoreDecompressBytesENC: (NSString *)str;

// method: MoreDecompressString
- (NSString *)MoreDecompressString: (NSData *)bData;

// method: MoreDecompressStringENC
- (NSString *)MoreDecompressStringENC: (NSString *)str;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: UnlockComponent
- (BOOL)UnlockComponent: (NSString *)unlockCode;


@end

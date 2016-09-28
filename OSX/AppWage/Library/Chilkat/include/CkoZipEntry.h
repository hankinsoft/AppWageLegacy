// Chilkat Objective-C header.
// Generic/internal class name =  ZipEntry
// Wrapped Chilkat C++ class name =  CkZipEntry

@class CkoDateTime;


@interface CkoZipEntry : NSObject {

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

// property getter: CompressedLength
- (NSNumber *)CompressedLength;

// property getter: CompressedLengthStr
- (NSString *)CompressedLengthStr;

// property getter: CompressionLevel
- (NSNumber *)CompressionLevel;

// property setter: CompressionLevel
- (void)setCompressionLevel: (NSNumber *)intVal;

// property getter: CompressionMethod
- (NSNumber *)CompressionMethod;

// property setter: CompressionMethod
- (void)setCompressionMethod: (NSNumber *)intVal;

// property getter: Crc
- (NSNumber *)Crc;

// property getter: DebugLogFilePath
- (NSString *)DebugLogFilePath;

// property setter: DebugLogFilePath
- (void)setDebugLogFilePath: (NSString *)input;

// property getter: EntryID
- (NSNumber *)EntryID;

// property getter: EntryType
- (NSNumber *)EntryType;

// property getter: FileDateTime
- (NSDate *)FileDateTime;

// property setter: FileDateTime
- (void)setFileDateTime: (NSDate *)dateVal;

// property getter: FileDateTimeStr
- (NSString *)FileDateTimeStr;

// property setter: FileDateTimeStr
- (void)setFileDateTimeStr: (NSString *)input;

// property getter: FileName
- (NSString *)FileName;

// property setter: FileName
- (void)setFileName: (NSString *)input;

// property getter: HeartbeatMs
- (NSNumber *)HeartbeatMs;

// property setter: HeartbeatMs
- (void)setHeartbeatMs: (NSNumber *)intVal;

// property getter: IsDirectory
- (BOOL)IsDirectory;

// property getter: LastErrorHtml
- (NSString *)LastErrorHtml;

// property getter: LastErrorText
- (NSString *)LastErrorText;

// property getter: LastErrorXml
- (NSString *)LastErrorXml;

// property getter: TextFlag
- (BOOL)TextFlag;

// property setter: TextFlag
- (void)setTextFlag: (BOOL)boolVal;

// property getter: UncompressedLength
- (NSNumber *)UncompressedLength;

// property getter: UncompressedLengthStr
- (NSString *)UncompressedLengthStr;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// method: AppendData
- (BOOL)AppendData: (NSData *)bdata;

// method: AppendString
- (BOOL)AppendString: (NSString *)inStr 
	charset: (NSString *)charset;

// method: Copy
- (NSData *)Copy;

// method: CopyToBase64
- (NSString *)CopyToBase64;

// method: CopyToHex
- (NSString *)CopyToHex;

// method: Extract
- (BOOL)Extract: (NSString *)dirPath;

// method: ExtractInto
- (BOOL)ExtractInto: (NSString *)dirPath;

// method: GetDt
- (CkoDateTime *)GetDt;

// method: Inflate
- (NSData *)Inflate;

// method: NextEntry
- (CkoZipEntry *)NextEntry;

// method: ReplaceData
- (BOOL)ReplaceData: (NSData *)bdata;

// method: ReplaceString
- (BOOL)ReplaceString: (NSString *)inStr 
	charset: (NSString *)charset;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: SetDt
- (void)SetDt: (CkoDateTime *)dt;

// method: UnzipToString
- (NSString *)UnzipToString: (NSNumber *)lineEndingBehavior 
	srcCharset: (NSString *)srcCharset;


@end

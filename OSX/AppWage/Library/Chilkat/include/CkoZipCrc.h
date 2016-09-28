// Chilkat Objective-C header.
// Generic/internal class name =  ZipCrc
// Wrapped Chilkat C++ class name =  CkZipCrc



@interface CkoZipCrc : NSObject {

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

// method: BeginStream
- (void)BeginStream;

// method: CalculateCrc
- (NSNumber *)CalculateCrc: (NSData *)byteData;

// method: EndStream
- (NSNumber *)EndStream;

// method: FileCrc
- (NSNumber *)FileCrc: (NSString *)filename;

// method: MoreData
- (void)MoreData: (NSData *)byteData;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)filename;

// method: ToHex
- (NSString *)ToHex: (NSNumber *)crc;


@end

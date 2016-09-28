// Chilkat Objective-C header.
// Generic/internal class name =  SFtpDir
// Wrapped Chilkat C++ class name =  CkSFtpDir

@class CkoSFtpFile;


@interface CkoSFtpDir : NSObject {

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

// property getter: NumFilesAndDirs
- (NSNumber *)NumFilesAndDirs;

// property getter: OriginalPath
- (NSString *)OriginalPath;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// method: GetFileObject
- (CkoSFtpFile *)GetFileObject: (NSNumber *)index;

// method: GetFilename
- (NSString *)GetFilename: (NSNumber *)index;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;


@end

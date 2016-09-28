// Chilkat Objective-C header.
// Generic/internal class name =  EmailBundle
// Wrapped Chilkat C++ class name =  CkEmailBundle

@class CkoEmail;
@class CkoStringArray;


@interface CkoEmailBundle : NSObject {

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

// property getter: MessageCount
- (NSNumber *)MessageCount;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// method: AddEmail
- (BOOL)AddEmail: (CkoEmail *)email;

// method: FindByHeader
- (CkoEmail *)FindByHeader: (NSString *)name 
	value: (NSString *)value;

// method: GetEmail
- (CkoEmail *)GetEmail: (NSNumber *)index;

// method: GetUidls
- (CkoStringArray *)GetUidls;

// method: GetXml
- (NSString *)GetXml;

// method: LoadXml
- (BOOL)LoadXml: (NSString *)path;

// method: LoadXmlString
- (BOOL)LoadXmlString: (NSString *)xmlStr;

// method: RemoveEmail
- (BOOL)RemoveEmail: (CkoEmail *)email;

// method: RemoveEmailByIndex
- (BOOL)RemoveEmailByIndex: (NSNumber *)index;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: SaveXml
- (BOOL)SaveXml: (NSString *)path;

// method: SortByDate
- (void)SortByDate: (BOOL)ascending;

// method: SortByRecipient
- (void)SortByRecipient: (BOOL)ascending;

// method: SortBySender
- (void)SortBySender: (BOOL)ascending;

// method: SortBySubject
- (void)SortBySubject: (BOOL)ascending;


@end

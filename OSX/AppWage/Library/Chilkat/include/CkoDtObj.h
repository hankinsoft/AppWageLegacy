// Chilkat Objective-C header.
// Generic/internal class name =  DtObj
// Wrapped Chilkat C++ class name =  CkDtObj



@interface CkoDtObj : NSObject {

	@private
		void *m_obj;

}

- (id)init;
- (void)dealloc;
- (void)dispose;
- (NSString *)stringWithUtf8: (const char *)s;
- (void *)CppImplObj;
- (void)setCppImplObj: (void *)pObj;

// property getter: Day
- (NSNumber *)Day;

// property setter: Day
- (void)setDay: (NSNumber *)intVal;

// property getter: DebugLogFilePath
- (NSString *)DebugLogFilePath;

// property setter: DebugLogFilePath
- (void)setDebugLogFilePath: (NSString *)input;

// property getter: Hour
- (NSNumber *)Hour;

// property setter: Hour
- (void)setHour: (NSNumber *)intVal;

// property getter: LastErrorHtml
- (NSString *)LastErrorHtml;

// property getter: LastErrorText
- (NSString *)LastErrorText;

// property getter: LastErrorXml
- (NSString *)LastErrorXml;

// property getter: Minute
- (NSNumber *)Minute;

// property setter: Minute
- (void)setMinute: (NSNumber *)intVal;

// property getter: Month
- (NSNumber *)Month;

// property setter: Month
- (void)setMonth: (NSNumber *)intVal;

// property getter: Second
- (NSNumber *)Second;

// property setter: Second
- (void)setSecond: (NSNumber *)intVal;

// property getter: StructTmMonth
- (NSNumber *)StructTmMonth;

// property setter: StructTmMonth
- (void)setStructTmMonth: (NSNumber *)intVal;

// property getter: StructTmYear
- (NSNumber *)StructTmYear;

// property setter: StructTmYear
- (void)setStructTmYear: (NSNumber *)intVal;

// property getter: Utc
- (BOOL)Utc;

// property setter: Utc
- (void)setUtc: (BOOL)boolVal;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// property getter: Year
- (NSNumber *)Year;

// property setter: Year
- (void)setYear: (NSNumber *)intVal;

// method: DeSerialize
- (void)DeSerialize: (NSString *)serializedDtObj;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: Serialize
- (NSString *)Serialize;


@end

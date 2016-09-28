// Chilkat Objective-C header.
// Generic/internal class name =  Xmp
// Wrapped Chilkat C++ class name =  CkXmp

@class CkoXml;
@class CkoStringArray;


@interface CkoXmp : NSObject {

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

// property getter: NumEmbedded
- (NSNumber *)NumEmbedded;

// property getter: StructInnerDescrip
- (BOOL)StructInnerDescrip;

// property setter: StructInnerDescrip
- (void)setStructInnerDescrip: (BOOL)boolVal;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// method: AddArray
- (BOOL)AddArray: (CkoXml *)xml 
	arrType: (NSString *)arrType 
	propName: (NSString *)propName 
	values: (CkoStringArray *)values;

// method: AddNsMapping
- (void)AddNsMapping: (NSString *)ns 
	uri: (NSString *)uri;

// method: AddSimpleDate
- (BOOL)AddSimpleDate: (CkoXml *)xml 
	propName: (NSString *)propName 
	sysTime: (NSDate *)sysTime;

// method: AddSimpleInt
- (BOOL)AddSimpleInt: (CkoXml *)xml 
	propName: (NSString *)propName 
	propVal: (NSNumber *)propVal;

// method: AddSimpleStr
- (BOOL)AddSimpleStr: (CkoXml *)xml 
	propName: (NSString *)propName 
	propVal: (NSString *)propVal;

// method: AddStructProp
- (BOOL)AddStructProp: (CkoXml *)xml 
	structName: (NSString *)structName 
	propName: (NSString *)propName 
	propVal: (NSString *)propVal;

// method: Append
- (BOOL)Append: (CkoXml *)xml;

// method: DateToString
- (NSString *)DateToString: (NSDate *)sysTime;

// method: GetArray
- (CkoStringArray *)GetArray: (CkoXml *)xml 
	propName: (NSString *)propName;

// method: GetEmbedded
- (CkoXml *)GetEmbedded: (NSNumber *)index;

// method: GetProperty
- (CkoXml *)GetProperty: (CkoXml *)xml 
	propName: (NSString *)propName;

// method: GetSimpleDate
- (NSDate *)GetSimpleDate: (CkoXml *)xml 
	propName: (NSString *)propName;

// method: GetSimpleInt
- (NSNumber *)GetSimpleInt: (CkoXml *)xml 
	propName: (NSString *)propName;

// method: GetSimpleStr
- (NSString *)GetSimpleStr: (CkoXml *)xml 
	propName: (NSString *)propName;

// method: GetStructPropNames
- (CkoStringArray *)GetStructPropNames: (CkoXml *)xml 
	structName: (NSString *)structName;

// method: GetStructValue
- (NSString *)GetStructValue: (CkoXml *)xml 
	structName: (NSString *)structName 
	propName: (NSString *)propName;

// method: LoadAppFile
- (BOOL)LoadAppFile: (NSString *)path;

// method: LoadFromBuffer
- (BOOL)LoadFromBuffer: (NSData *)byteData 
	ext: (NSString *)ext;

// method: NewXmp
- (CkoXml *)NewXmp;

// method: RemoveAllEmbedded
- (void)RemoveAllEmbedded;

// method: RemoveArray
- (BOOL)RemoveArray: (CkoXml *)xml 
	propName: (NSString *)propName;

// method: RemoveNsMapping
- (void)RemoveNsMapping: (NSString *)ns;

// method: RemoveSimple
- (BOOL)RemoveSimple: (CkoXml *)xml 
	propName: (NSString *)propName;

// method: RemoveStruct
- (BOOL)RemoveStruct: (CkoXml *)xml 
	structName: (NSString *)structName;

// method: RemoveStructProp
- (BOOL)RemoveStructProp: (CkoXml *)xml 
	structName: (NSString *)structName 
	propName: (NSString *)propName;

// method: SaveAppFile
- (BOOL)SaveAppFile: (NSString *)path;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: SaveToBuffer
- (NSData *)SaveToBuffer;

// method: StringToDate
- (NSDate *)StringToDate: (NSString *)str;

// method: UnlockComponent
- (BOOL)UnlockComponent: (NSString *)unlockCode;


@end

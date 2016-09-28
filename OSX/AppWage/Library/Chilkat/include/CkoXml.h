// Chilkat Objective-C header.
// Generic/internal class name =  Xml
// Wrapped Chilkat C++ class name =  CkXml



@interface CkoXml : NSObject {

	@private
		void *m_obj;

}

- (id)init;
- (void)dealloc;
- (void)dispose;
- (NSString *)stringWithUtf8: (const char *)s;
- (void *)CppImplObj;
- (void)setCppImplObj: (void *)pObj;

// property getter: Cdata
- (BOOL)Cdata;

// property setter: Cdata
- (void)setCdata: (BOOL)boolVal;

// property getter: Content
- (NSString *)Content;

// property setter: Content
- (void)setContent: (NSString *)input;

// property getter: ContentInt
- (NSNumber *)ContentInt;

// property setter: ContentInt
- (void)setContentInt: (NSNumber *)intVal;

// property getter: DebugLogFilePath
- (NSString *)DebugLogFilePath;

// property setter: DebugLogFilePath
- (void)setDebugLogFilePath: (NSString *)input;

// property getter: DocType
- (NSString *)DocType;

// property setter: DocType
- (void)setDocType: (NSString *)input;

// property getter: EmitXmlDecl
- (BOOL)EmitXmlDecl;

// property setter: EmitXmlDecl
- (void)setEmitXmlDecl: (BOOL)boolVal;

// property getter: Encoding
- (NSString *)Encoding;

// property setter: Encoding
- (void)setEncoding: (NSString *)input;

// property getter: LastErrorHtml
- (NSString *)LastErrorHtml;

// property getter: LastErrorText
- (NSString *)LastErrorText;

// property getter: LastErrorXml
- (NSString *)LastErrorXml;

// property getter: NumAttributes
- (NSNumber *)NumAttributes;

// property getter: NumChildren
- (NSNumber *)NumChildren;

// property getter: SortCaseInsensitive
- (BOOL)SortCaseInsensitive;

// property setter: SortCaseInsensitive
- (void)setSortCaseInsensitive: (BOOL)boolVal;

// property getter: Standalone
- (BOOL)Standalone;

// property setter: Standalone
- (void)setStandalone: (BOOL)boolVal;

// property getter: Tag
- (NSString *)Tag;

// property setter: Tag
- (void)setTag: (NSString *)input;

// property getter: TreeId
- (NSNumber *)TreeId;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// method: AccumulateTagContent
- (NSString *)AccumulateTagContent: (NSString *)tag 
	skipTags: (NSString *)skipTags;

// method: AddAttribute
- (BOOL)AddAttribute: (NSString *)name 
	value: (NSString *)value;

// method: AddAttributeInt
- (BOOL)AddAttributeInt: (NSString *)name 
	value: (NSNumber *)value;

// method: AddChildTree
- (BOOL)AddChildTree: (CkoXml *)tree;

// method: AddOrUpdateAttribute
- (void)AddOrUpdateAttribute: (NSString *)name 
	value: (NSString *)value;

// method: AddOrUpdateAttributeI
- (void)AddOrUpdateAttributeI: (NSString *)name 
	value: (NSNumber *)value;

// method: AddStyleSheet
- (void)AddStyleSheet: (NSString *)styleSheet;

// method: AddToAttribute
- (void)AddToAttribute: (NSString *)name 
	amount: (NSNumber *)amount;

// method: AddToChildContent
- (void)AddToChildContent: (NSString *)tag 
	amount: (NSNumber *)amount;

// method: AddToContent
- (void)AddToContent: (NSNumber *)amount;

// method: AppendToContent
- (BOOL)AppendToContent: (NSString *)str;

// method: BEncodeContent
- (BOOL)BEncodeContent: (NSString *)charset 
	db: (NSData *)db;

// method: ChildContentMatches
- (BOOL)ChildContentMatches: (NSString *)tag 
	pattern: (NSString *)pattern 
	caseSensitive: (BOOL)caseSensitive;

// method: ChilkatPath
- (NSString *)ChilkatPath: (NSString *)cmd;

// method: Clear
- (BOOL)Clear;

// method: ContentMatches
- (BOOL)ContentMatches: (NSString *)pattern 
	caseSensitive: (BOOL)caseSensitive;

// method: Copy
- (void)Copy: (CkoXml *)node;

// method: CopyRef
- (void)CopyRef: (CkoXml *)node;

// method: DecodeContent
- (NSData *)DecodeContent;

// method: DecodeEntities
- (NSString *)DecodeEntities: (NSString *)str;

// method: DecryptContent
- (BOOL)DecryptContent: (NSString *)password;

// method: EncryptContent
- (BOOL)EncryptContent: (NSString *)password;

// method: ExtractChildByIndex
- (CkoXml *)ExtractChildByIndex: (NSNumber *)index;

// method: ExtractChildByName
- (CkoXml *)ExtractChildByName: (NSString *)tag 
	attrName: (NSString *)attrName 
	attrValue: (NSString *)attrValue;

// method: FindChild
- (CkoXml *)FindChild: (NSString *)tag;

// method: FindChild2
- (BOOL)FindChild2: (NSString *)tag;

// method: FindNextRecord
- (CkoXml *)FindNextRecord: (NSString *)tag 
	contentPattern: (NSString *)contentPattern;

// method: FindOrAddNewChild
- (CkoXml *)FindOrAddNewChild: (NSString *)tag;

// method: FirstChild
- (CkoXml *)FirstChild;

// method: FirstChild2
- (BOOL)FirstChild2;

// method: GetAttrValue
- (NSString *)GetAttrValue: (NSString *)name;

// method: GetAttrValueInt
- (NSNumber *)GetAttrValueInt: (NSString *)name;

// method: GetAttributeName
- (NSString *)GetAttributeName: (NSNumber *)index;

// method: GetAttributeValue
- (NSString *)GetAttributeValue: (NSNumber *)index;

// method: GetAttributeValueInt
- (NSNumber *)GetAttributeValueInt: (NSNumber *)index;

// method: GetBinaryContent
- (NSData *)GetBinaryContent: (BOOL)unzipFlag 
	decryptFlag: (BOOL)decryptFlag 
	password: (NSString *)password;

// method: GetChild
- (CkoXml *)GetChild: (NSNumber *)index;

// method: GetChild2
- (BOOL)GetChild2: (NSNumber *)index;

// method: GetChildBoolValue
- (BOOL)GetChildBoolValue: (NSString *)tag;

// method: GetChildContent
- (NSString *)GetChildContent: (NSString *)tag;

// method: GetChildContentByIndex
- (NSString *)GetChildContentByIndex: (NSNumber *)index;

// method: GetChildExact
- (CkoXml *)GetChildExact: (NSString *)tag 
	content: (NSString *)content;

// method: GetChildIntValue
- (NSNumber *)GetChildIntValue: (NSString *)tag;

// method: GetChildTag
- (NSString *)GetChildTag: (NSNumber *)index;

// method: GetChildTagByIndex
- (NSString *)GetChildTagByIndex: (NSNumber *)index;

// method: GetChildWithAttr
- (CkoXml *)GetChildWithAttr: (NSString *)tag 
	attrName: (NSString *)attrName 
	attrValue: (NSString *)attrValue;

// method: GetChildWithContent
- (CkoXml *)GetChildWithContent: (NSString *)content;

// method: GetChildWithTag
- (CkoXml *)GetChildWithTag: (NSString *)tag;

// method: GetNthChildWithTag
- (CkoXml *)GetNthChildWithTag: (NSString *)tag 
	n: (NSNumber *)n;

// method: GetNthChildWithTag2
- (BOOL)GetNthChildWithTag2: (NSString *)tag 
	n: (NSNumber *)n;

// method: GetParent
- (CkoXml *)GetParent;

// method: GetParent2
- (BOOL)GetParent2;

// method: GetRoot
- (CkoXml *)GetRoot;

// method: GetRoot2
- (void)GetRoot2;

// method: GetSelf
- (CkoXml *)GetSelf;

// method: GetXml
- (NSString *)GetXml;

// method: HasAttrWithValue
- (BOOL)HasAttrWithValue: (NSString *)name 
	value: (NSString *)value;

// method: HasAttribute
- (BOOL)HasAttribute: (NSString *)name;

// method: HasChildWithContent
- (BOOL)HasChildWithContent: (NSString *)content;

// method: HasChildWithTag
- (BOOL)HasChildWithTag: (NSString *)tag;

// method: HasChildWithTagAndContent
- (BOOL)HasChildWithTagAndContent: (NSString *)tag 
	content: (NSString *)content;

// method: InsertChildTreeAfter
- (BOOL)InsertChildTreeAfter: (NSNumber *)index 
	tree: (CkoXml *)tree;

// method: InsertChildTreeBefore
- (BOOL)InsertChildTreeBefore: (NSNumber *)index 
	tree: (CkoXml *)tree;

// method: LastChild
- (CkoXml *)LastChild;

// method: LastChild2
- (BOOL)LastChild2;

// method: LoadXml
- (BOOL)LoadXml: (NSString *)xmlData;

// method: LoadXml2
- (BOOL)LoadXml2: (NSString *)xmlData 
	autoTrim: (BOOL)autoTrim;

// method: LoadXmlFile
- (BOOL)LoadXmlFile: (NSString *)path;

// method: LoadXmlFile2
- (BOOL)LoadXmlFile2: (NSString *)path 
	autoTrim: (BOOL)autoTrim;

// method: NewChild
- (CkoXml *)NewChild: (NSString *)tag 
	content: (NSString *)content;

// method: NewChild2
- (void)NewChild2: (NSString *)tag 
	content: (NSString *)content;

// method: NewChildAfter
- (CkoXml *)NewChildAfter: (NSNumber *)index 
	tag: (NSString *)tag 
	content: (NSString *)content;

// method: NewChildBefore
- (CkoXml *)NewChildBefore: (NSNumber *)index 
	tag: (NSString *)tag 
	content: (NSString *)content;

// method: NewChildInt2
- (void)NewChildInt2: (NSString *)tag 
	value: (NSNumber *)value;

// method: NextSibling
- (CkoXml *)NextSibling;

// method: NextSibling2
- (BOOL)NextSibling2;

// method: NumChildrenHavingTag
- (NSNumber *)NumChildrenHavingTag: (NSString *)tag;

// method: PreviousSibling
- (CkoXml *)PreviousSibling;

// method: PreviousSibling2
- (BOOL)PreviousSibling2;

// method: QEncodeContent
- (BOOL)QEncodeContent: (NSString *)charset 
	db: (NSData *)db;

// method: RemoveAllAttributes
- (BOOL)RemoveAllAttributes;

// method: RemoveAllChildren
- (void)RemoveAllChildren;

// method: RemoveAttribute
- (BOOL)RemoveAttribute: (NSString *)name;

// method: RemoveChild
- (void)RemoveChild: (NSString *)tag;

// method: RemoveChildByIndex
- (void)RemoveChildByIndex: (NSNumber *)index;

// method: RemoveChildWithContent
- (void)RemoveChildWithContent: (NSString *)content;

// method: RemoveFromTree
- (void)RemoveFromTree;

// method: SaveBinaryContent
- (BOOL)SaveBinaryContent: (NSString *)path 
	unzipFlag: (BOOL)unzipFlag 
	decryptFlag: (BOOL)decryptFlag 
	password: (NSString *)password;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: SaveXml
- (BOOL)SaveXml: (NSString *)path;

// method: SearchAllForContent
- (CkoXml *)SearchAllForContent: (CkoXml *)after 
	contentPattern: (NSString *)contentPattern;

// method: SearchAllForContent2
- (BOOL)SearchAllForContent2: (CkoXml *)after 
	contentPattern: (NSString *)contentPattern;

// method: SearchForAttribute
- (CkoXml *)SearchForAttribute: (CkoXml *)after 
	tag: (NSString *)tag 
	attr: (NSString *)attr 
	valuePattern: (NSString *)valuePattern;

// method: SearchForAttribute2
- (BOOL)SearchForAttribute2: (CkoXml *)after 
	tag: (NSString *)tag 
	attr: (NSString *)attr 
	valuePattern: (NSString *)valuePattern;

// method: SearchForContent
- (CkoXml *)SearchForContent: (CkoXml *)after 
	tag: (NSString *)tag 
	contentPattern: (NSString *)contentPattern;

// method: SearchForContent2
- (BOOL)SearchForContent2: (CkoXml *)after 
	tag: (NSString *)tag 
	contentPattern: (NSString *)contentPattern;

// method: SearchForTag
- (CkoXml *)SearchForTag: (CkoXml *)after 
	tag: (NSString *)tag;

// method: SearchForTag2
- (BOOL)SearchForTag2: (CkoXml *)after 
	tag: (NSString *)tag;

// method: SetBinaryContent
- (BOOL)SetBinaryContent: (NSData *)data 
	zipFlag: (BOOL)zipFlag 
	encryptFlag: (BOOL)encryptFlag 
	password: (NSString *)password;

// method: SetBinaryContent2
- (BOOL)SetBinaryContent2: (NSData *)pByteData 
	szByteData: (NSNumber *)szByteData 
	zipFlag: (BOOL)zipFlag 
	encryptFlag: (BOOL)encryptFlag 
	password: (NSString *)password;

// method: SetBinaryContentFromFile
- (BOOL)SetBinaryContentFromFile: (NSString *)path 
	zipFlag: (BOOL)zipFlag 
	encryptFlag: (BOOL)encryptFlag 
	password: (NSString *)password;

// method: SortByAttribute
- (void)SortByAttribute: (NSString *)attrName 
	ascending: (BOOL)ascending;

// method: SortByAttributeInt
- (void)SortByAttributeInt: (NSString *)attrName 
	ascending: (BOOL)ascending;

// method: SortByContent
- (void)SortByContent: (BOOL)ascending;

// method: SortByTag
- (void)SortByTag: (BOOL)ascending;

// method: SortRecordsByAttribute
- (void)SortRecordsByAttribute: (NSString *)sortTag 
	attrName: (NSString *)attrName 
	ascending: (BOOL)ascending;

// method: SortRecordsByContent
- (void)SortRecordsByContent: (NSString *)sortTag 
	ascending: (BOOL)ascending;

// method: SortRecordsByContentInt
- (void)SortRecordsByContentInt: (NSString *)sortTag 
	ascending: (BOOL)ascending;

// method: SwapNode
- (BOOL)SwapNode: (CkoXml *)node;

// method: SwapTree
- (BOOL)SwapTree: (CkoXml *)tree;

// method: TagContent
- (NSString *)TagContent: (NSString *)tag;

// method: TagEquals
- (BOOL)TagEquals: (NSString *)tag;

// method: UnzipContent
- (BOOL)UnzipContent;

// method: UnzipTree
- (BOOL)UnzipTree;

// method: UpdateAttribute
- (BOOL)UpdateAttribute: (NSString *)attrName 
	attrValue: (NSString *)attrValue;

// method: UpdateAttributeInt
- (BOOL)UpdateAttributeInt: (NSString *)attrName 
	value: (NSNumber *)value;

// method: UpdateChildContent
- (void)UpdateChildContent: (NSString *)tag 
	value: (NSString *)value;

// method: UpdateChildContentInt
- (void)UpdateChildContentInt: (NSString *)tag 
	value: (NSNumber *)value;

// method: ZipContent
- (BOOL)ZipContent;

// method: ZipTree
- (BOOL)ZipTree;


@end

// Chilkat Objective-C header.
// Generic/internal class name =  Cache
// Wrapped Chilkat C++ class name =  CkCache

@class CkoDateTime;


@interface CkoCache : NSObject {

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

// property getter: LastEtagFetched
- (NSString *)LastEtagFetched;

// property getter: LastExpirationFetched
- (NSDate *)LastExpirationFetched;

// property getter: LastExpirationFetchedStr
- (NSString *)LastExpirationFetchedStr;

// property getter: LastHitExpired
- (BOOL)LastHitExpired;

// property getter: LastKeyFetched
- (NSString *)LastKeyFetched;

// property getter: Level
- (NSNumber *)Level;

// property setter: Level
- (void)setLevel: (NSNumber *)intVal;

// property getter: NumRoots
- (NSNumber *)NumRoots;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// method: AddRoot
- (void)AddRoot: (NSString *)path;

// method: DeleteAll
- (NSNumber *)DeleteAll;

// method: DeleteAllExpired
- (NSNumber *)DeleteAllExpired;

// method: DeleteFromCache
- (BOOL)DeleteFromCache: (NSString *)key;

// method: DeleteOlder
- (NSNumber *)DeleteOlder: (NSDate *)dt;

// method: DeleteOlderDt
- (NSNumber *)DeleteOlderDt: (CkoDateTime *)dt;

// method: DeleteOlderStr
- (NSNumber *)DeleteOlderStr: (NSString *)dateTimeStr;

// method: FetchFromCache
- (NSData *)FetchFromCache: (NSString *)key;

// method: FetchText
- (NSString *)FetchText: (NSString *)key;

// method: GetEtag
- (NSString *)GetEtag: (NSString *)key;

// method: GetExpiration
- (NSDate *)GetExpiration: (NSString *)key;

// method: GetExpirationDt
- (CkoDateTime *)GetExpirationDt: (NSString *)key;

// method: GetExpirationStr
- (NSString *)GetExpirationStr: (NSString *)url;

// method: GetFilename
- (NSString *)GetFilename: (NSString *)key;

// method: GetRoot
- (NSString *)GetRoot: (NSNumber *)index;

// method: IsCached
- (BOOL)IsCached: (NSString *)key;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: SaveText
- (BOOL)SaveText: (NSString *)key 
	expire: (NSDate *)expire 
	eTag: (NSString *)eTag 
	strData: (NSString *)strData;

// method: SaveTextDt
- (BOOL)SaveTextDt: (NSString *)key 
	expire: (CkoDateTime *)expire 
	eTag: (NSString *)eTag 
	strData: (NSString *)strData;

// method: SaveTextNoExpire
- (BOOL)SaveTextNoExpire: (NSString *)key 
	eTag: (NSString *)eTag 
	strData: (NSString *)strData;

// method: SaveTextStr
- (BOOL)SaveTextStr: (NSString *)key 
	expireDateTimeStr: (NSString *)expireDateTimeStr 
	eTag: (NSString *)eTag 
	strData: (NSString *)strData;

// method: SaveToCache
- (BOOL)SaveToCache: (NSString *)key 
	expire: (NSDate *)expire 
	eTag: (NSString *)eTag 
	data: (NSData *)data;

// method: SaveToCacheDt
- (BOOL)SaveToCacheDt: (NSString *)key 
	expire: (CkoDateTime *)expire 
	eTag: (NSString *)eTag 
	data: (NSData *)data;

// method: SaveToCacheNoExpire
- (BOOL)SaveToCacheNoExpire: (NSString *)key 
	eTag: (NSString *)eTag 
	data: (NSData *)data;

// method: SaveToCacheStr
- (BOOL)SaveToCacheStr: (NSString *)url 
	expireDateTimeStr: (NSString *)expireDateTimeStr 
	eTag: (NSString *)eTag 
	data: (NSData *)data;

// method: UpdateExpiration
- (BOOL)UpdateExpiration: (NSString *)key 
	dt: (NSDate *)dt;

// method: UpdateExpirationDt
- (BOOL)UpdateExpirationDt: (NSString *)key 
	dt: (CkoDateTime *)dt;

// method: UpdateExpirationStr
- (BOOL)UpdateExpirationStr: (NSString *)url 
	dateTimeStr: (NSString *)dateTimeStr;


@end

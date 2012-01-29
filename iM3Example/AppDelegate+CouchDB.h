@class CouchDatabase;

@interface AppDelegate(CouchDB)

/*
 * Initialize Couchbase instance.
 */
-(void) initCouchbase;

/*
 * The Couchbase instance could not be started successfully.
 */
-(void)couchbaseMobile:(CouchbaseMobile*)couchbase failedToStart:(NSError*)error;

/*
 * The Couchbase instance started successfully.
 */
-(void)couchbaseMobile:(CouchbaseMobile*)couchbase didStart:(NSURL*)serverURL;

/*
 * Return an instance 
 */
-(CouchDatabase*) couchdb;

@end

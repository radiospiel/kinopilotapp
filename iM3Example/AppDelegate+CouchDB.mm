// #import "C

#import "CouchCocoa/CouchCocoa.h"

extern "C" void driver_interrupt(int this_port, int ino)
  {}

static CouchDatabase* couchdb;

@implementation AppDelegate(CouchDB)

-(void)couchbaseMobile:(CouchbaseMobile*)couchbase didStart:(NSURL*)serverURL {
  rlog(2) << "*** Couchbase is Ready, go! " << serverURL;
  
  CouchServer *server = [[CouchServer alloc] initWithURL: serverURL];
  couchdb = [server databaseNamed: @"kinopilot"];
  RESTOperation* op = [couchdb create];
  if (![op wait] && op.httpStatus != 412) {
    // failed to contact the server or create the database
    // (a 412 status is OK; it just indicates the db already exists.)
  }
  
  // NSString* dbName = serverURL;
  // 
  // couchdb = [CouchDatabase databaseWithURL:serverURL];
  // 
  // 
  NSURL* sourceURL = [NSURL URLWithString: @"http://10.0.1.20:5984/kinopilotupdates2"];

  CouchReplication* replication = 
    [couchdb pullFromDatabaseAtURL: sourceURL
                           options:kCouchReplicationCreateTarget];
                    

  rlog(2) << "*** Started replication from " << sourceURL;
}

-(void)couchbaseMobile:(CouchbaseMobile*)couchbase failedToStart:(NSError*)error {
  _.raise(_.join(@"Couchbase failed to initialize: ", error));
}


-(void) initCouchbase;
{
  CouchbaseMobile* cb = [[CouchbaseMobile alloc] init];
  cb.delegate = self;
  if(![cb start]) {
    rlog(1) << @"*** Couchbase didn't start! Error =" << cb.error;
  }
}

@end

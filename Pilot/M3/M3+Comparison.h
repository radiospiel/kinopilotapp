@interface M3(Compare)
/** @name Ordering objects */

/*!

@param value one value to compare
@param other value to compare value with.
@return one of NSOrderedAscending, NSOrderedSame, or 
  NSOrderedDescending.

@discussion 

This method implements a sort order between objects from different 
classes. The sort order is similar to the sort order used by CouchDB.

- It sorts special values before all other types: nil, false, true
- followed by numbers: 1, 2, 3.0, 4
- text: "a", "A", "aa", "b", "B", "ba", "bb"
- arrays: compared element by element until different:
- dictionaries: compared element by element until different, in key 
  order. Only NString's are allowed as dictionary keys. Note: CouchDB
  compares objects by each key value in the list until different. 
  This needs a stable member order in an object - something that 
  NSDictionaries don't guarantee.
  {a:1},{a:2},{b:1},{b:2},{b:2, a:1},{b:2, c:2}

*/

+ (NSComparisonResult) compare: (id) value 
                          with: (id) other;

@end

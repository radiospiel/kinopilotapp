#import "M3.h"

@interface M3(Enumeration)

/** @name Enumeration methods */


/*!

Iterates over a list.

Iterates over an array or a dictionary, yielding each entry to an 
iterator function. The iterator function will be invoked with two 
objects: (value, key). 
 
This method treats arrays as dictionaries: arrays yield the iterator 
block with NSNumber objects as keys, starting at 0 and counting up.
 
    id list = [NSArray arrayWithObjects: @"Nicola", @"Margherita", nil];
    [M3 each: list 
       with: ^(id value, id key){ NSLog(@"%@: %@", key, value); }
   ];

@param list the array or dictionary to iterate over
@param iterator the iterator function.
@return the list parameter.

*/

+ (id) each: (id) list with: (void (^)(id value, id key)) iterator;

/*!

Iterates over a list.

Iterates over an array, yielding each entry to an iterator function. 
The iterator function will be invoked with two objects: (value, key). 
 
In contrast to each:with: this method does not convert the 
array's indices into NSNumbers.
 
    id list = [NSArray arrayWithObjects: @"Nicola", @"Margherita", nil];
    [M3 each: list
                withIndex: ^(id value, NSUInteger key){ NSLog(@"%ld: %@", key, value); }
   ];

@param list the array or dictionary to iterate over
@param iterator the iterator function.
@return the list parameter.

*/

+ (id) each: (id) list withIndex: (void (^)(id value, NSUInteger index)) iterator;

/*!

@param list the array or dictionary to iterate over
@param memo the initial state of the reduction
@param iterator the iterator function.
@return the reduced value.

Also known as 'reduce' and 'foldl', inject boils down a list of values into
a single value. memo is the initial state of the reduction, and each 
successive step of it should be returned by iterator. 

Note that underscore.js's corresponding method is called 'reduce', and takes 
the parameters in a different order. 

*/

+ (id) inject: (id) list 
         memo: (id) memo
         with: (id (^)(id memo, id value, id key))iterator;

/*!

@param list the array or dictionary to iterate over
@param iterator the iterator function.
@return the reduced value.

This is a shortcut for inject:memo:with: with the memo parameter
set to nil.

*/

+ (id) inject: (id) list 
         with: (id (^)(id memo, id value, id key))iterator;


/*!

@param list the array or dictionary to iterate over
@param memo the initial state of the reduction
@param iterator the iterator function.
@return the reduced value.

Also known as 'reduce' and 'foldl', inject boils down a list
of values into a single value. memo is the initial state of the reduction, 
and each successive step of it should be returned by iterator. 

Note that underscore.js's corresponding method is called 'reduce', and 
takes the parameters in a different order. 

*/

+ (id) inject: (id) list 
         memo: (id) memo
    withIndex: (id (^)(id memo, id value, NSUInteger key))iterator;

/*!

@param list the array or dictionary to iterate over
@param iterator the iterator function.
@return the reduced value.

This is a shortcut for inject:memo:withIndex: with the memo 
parameter set to nil.

*/

+ (id) inject: (id) list 
    withIndex: (id (^)(id memo, id value, NSUInteger key))iterator;

/*!

@param list the array or dictionary to iterate over
@param iterator the iterator function.
@return the newly produced array.

Produces a new array of values by mapping each value in an array or 
dictionary through a transformation function (iterator). The iterator's 
arguments will be (value, key).

<pre>
  id list = [NSArray arrayWithObjects: @"Nicola", @"Margherita", nil];
  [M3 map: list
      with: ^(id value, id key){ 
        return [NSString stringWithFormat: @"%@-%@", key, value]; }
 ];
</pre>
*/

+ (NSMutableArray*) map: (id) list 
                   with: (id (^)(id value, id key))iterator;

/*!

@param list the array or dictionary to iterate over
@param iterator the iterator function.
@return the newly produced array.

Produces a new array of values by mapping each value in list through 
a transformation function (iterator). 

*/

+ (NSMutableArray*) map: (id) list 
              withIndex: (id (^)(id value, NSUInteger idx))iterator;


/*!

@param list the array or dictionary to iterate over
@param iterator the iterator function.
@return the newly produced array.

Looks through each value in the list, returning the first one that passes
a truth test (iterator). The function returns as soon as it finds an 
acceptable element, and doesn't traverse the entire list.

*/

+ (id) detect: (id) list 
         with: (BOOL (^)(id value, id key))iterator;

/*!

@param list the array or dictionary to iterate over
@param iterator the iterator function.
@return the newly produced array.

Looks through each value in the list, returning the first one that passes
a truth test (iterator). The function returns as soon as it finds an 
acceptable element, and doesn't traverse the entire list.

*/
  
+ (id) detect: (id) list 
    withIndex: (BOOL (^)(id value, NSUInteger key))iterator;

/*!

@param list the array or dictionary to iterate over
@param iterator the iterator function.
@return the newly produced array.

Looks through each value in the list, returning an array of all 
the values that pass a truth test (iterator). 

*/

+ (NSMutableArray*) select: (id) list 
                      with: (BOOL (^)(id value, id key))iterator;

/*!

@param list the array or dictionary to iterate over
@param iterator the iterator function.
@return the newly produced array.

Looks through each value in the list, returning an array of all 
the values that pass a truth test (iterator). 

*/

+ (NSMutableArray*) select: (id) list 
                 withIndex: (BOOL (^)(id value, NSUInteger key))iterator;


/*!

@param list the array or dictionary to iterate over
@param iterator the iterator function.
@return the newly produced array.

Looks through each value in the list, returning an array of all 
the values that fail a truth test (iterator). 

*/

+ (NSMutableArray*) reject: (id) list 
                      with: (BOOL (^)(id value, id key))iterator;

/*!

@param list the array or dictionary to iterate over
@param iterator the iterator function.
@return the newly produced array.

Looks through each value in the list, returning an array of all 
the values that fail a truth test (iterator). 

*/

+ (NSMutableArray*) reject: (id) list 
                 withIndex: (BOOL (^)(id value, NSUInteger key))iterator;

/*!

@param list the array or dictionary to iterate over
@param iterator the iterator function.
@return return true if all of the values in the list pass 
  the iterator truth test. 
*/

+ (BOOL) all: (id) list 
        with: (BOOL (^)(id value, id key))iterator;

/*!

@param list the array or dictionary to iterate over
@param iterator the iterator function.
@return return true if all of the values in the list pass 
  the iterator truth test. 
*/

+ (BOOL) all: (id) list 
   withIndex: (BOOL (^)(id value, NSUInteger key))iterator;

/*!

@param list the array or dictionary to iterate over
@param iterator the iterator function.
@return return true if any of the values in the list pass 
  the iterator truth test. Short-circuits and stops traversing the 
  list if a true element is found. 
*/

+ (BOOL) any: (id) list 
        with: (BOOL (^)(id value, id key))iterator;

/*!

@param list the array or dictionary to iterate over
@param iterator the iterator function.
@return return true if any of the values in the list pass 
  the iterator truth test. Short-circuits and stops traversing the 
  list if a true element is found. 
*/

+ (BOOL) any: (id) list 
   withIndex: (BOOL (^)(id value, NSUInteger key))iterator;

/*!

@param list the array or dictionary to iterate over
@param value the value to check for.
@return true if the value is present in the list, using 
  [NSObject isEqual: ] to test equality. 
*/

+ (BOOL) include: (id) list 
           value: (id) value;

/*!

@param list the array or dictionary to iterate over
@param propertyName the propertyName to extract from the entries.
@return an array of properties. 

@discussion 

A convenient version of what is perhaps the most common use-case for 
map: extracting a list of property values.

<pre>
    var stooges = [{name : 'moe', age : 40}, {name : 'larry', age : 50}, {name : 'curly', age : 60}];
    [M3 pluck: stooges withPropertyName: @"name"];
    // => [@"moe", @"larry", @"curly"]
</pre>
*/

+ (NSMutableArray*) pluck: (id) list 
                     name: (NSString*) propertyName;


/*!

@param list the list to iterate
@return the maximum value in list. 

The list's values will be compared using compare:with: 

*/

+ (id) max: (id) list;

/*!

@param list the list to iterate
@param iterator the function to generate the criterion by which each 
 value is ranked.
@return the maximum value in list. 

This method uses iterator on each value to generate the criterion 
by which the value is ranked. The returned objects will be compared 
using compare:with: 

*/

+ (id) max: (id) list 
      with: (id (^)(id value, id key))iterator;

/*!

@param list the list to iterate
@param iterator the function to generate the criterion by which each value is ranked.
@return the maximum value in list. 


This method uses iterator on each value to generate the criterion 
by which the value is ranked. The returned objects will be compared 
using compare:with: 

*/
+ (id) max: (id) list 
  withIndex: (id (^)(id value, NSUInteger idx))iterator;

/*!

@param list the list to iterate
@return the minimum value in list. 

The list's values will be compared using compare:with: 

*/

+ (id) min: (id) list;

/*!

@param list the list to iterate
@param iterator the function to generate the criterion by which each 
 value is ranked.
@return the minimum value in list. 

This method uses iterator on each value to generate the criterion 
by which the value is ranked. The returned objects will be compared 
using compare:with: 

*/

+ (id) min: (id) list 
      with: (id (^)(id value, id key))iterator;

/*!

@param list the list to iterate
@param iterator the function to generate the criterion by which each 
 value is ranked.
@return the minimum value in list. 


This method uses iterator on each value to generate the criterion 
by which the value is ranked. The returned objects will be compared 
using compare:with: 

*/
+ (id) min: (id) list 
  withIndex: (id (^)(id value, NSUInteger idx))iterator;

/**

 Splits a collection into sets, grouped by the result of running each 
 value through iterator.
 
    [M3 group: _.array(2.1, 1.3, 2.4)
                    by: ^(id value){ return Math.floor([value doubleValue ]); }
   ];
    // => {1: [1.3], 2: [2.1, 2.4]}

*/

+ (id) group: (id) list 
          by: (id (^)(id value))iterator;


@end

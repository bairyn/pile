# Pile #

Pile is a library that provides classes for manipulating tables of data in
the form of CSV files with a header.

## Sample CSV file ##

The following code snippets can work on the this CSV example with 2 records:

```csv
Identity,Name,Address Line
1,Alice,123 1st St
2,Bob,234 2nd St
```

## Classes ##

A List object contains the header (in this case,
```ruby ['Identity', 'Name', 'Address Line']```) and all of the records
(```ruby [[1, 'Alice', '123 1st St'], [2, 'Bob', '234 2nd St']]```).
The header, of class Header (see below), can be accessed with the "header"
attribute of that object, and its array of Records can be accessed with the
"records" attribute.

Assuming the above example is saved in a file called "persons.csv", we can load
the file into a List object through List's from_string function, and assign the
result to "persons", as follows:

```ruby
persons = List.from_string File.read 'persons.csv'
```

A Header object describes the first row in such a formatted CSV file.  We can
access the columns through +to_a+ or +indices+:

```ruby
columns = persons.header.indices
```

columns is now set to "['Identity', 'Name', 'Address Line']".

Each record, which in our example contains information for Alice and Bob, can
be accessed with either "list.each …", "list.to_a", which uses "list.records".
For example, Bob's information can be accessed, for now, like this:

```ruby
bob = persons[1]
```

bob is now assigned to the first Record that the list contains.  Each Record
contains the array of values, coupled with some other data that makes
manipulating the records more convenient.  We can access the values by position
and by column name:

```ruby
bob['name'] = 'Bob Smith'
bob[2] += "\nSan Francisco, CA" unless bob[2] ~= /\bCA\b/
```

(The case_sensitive attribute of the header, which defaults to false, can be
set as desired.)

A Header can also contain aliases for each column.  In our example, typing out
'Address Line' every time we want to access the address can be cumbersome.
We can set our list's aliases for this column (the aliases attribute belongs to
the header, but the List object, as well as each Record object, conveniently
forwards unhandled messages to the header):

```ruby
list.aliases['Address Line'] = ['address']
```

Now we can update Bob's address with the index 'address':

```ruby
bob['address'] = '234 2nd St'
```

We hadn't initialized the aliases attribute; it was initialized to an empty
hash when the object was created.  List's from_string also allows us to set the
aliases at runtime; this time, we'll also take advantage of the ability to
assign multiple aliases:

```ruby
persons = List.from_string File.read('persons.csv'),
                           {'identity' => 'id', 'address line' => ['address', 'location']
```

The List class also contains some utility methods for conveniently
manipulating records, such as "map_records", which operates like "map" and
passes the block each record.

Once we have finished manipulating our 'list', we can write the csv file, by
invoking "csv_string" to generate a string that we can write to a file:

```ruby
File.write 'persons_updated.csv', list.csv_string
```

List also defines methods such as "render_rows" and "render_matrix" to generate
matrices of strings, which may be a more convenient format for applications
such as GUIs.

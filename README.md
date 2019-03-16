# OCaml SQLite notes

* [Installation](#installation)
* [basic usage](#basic-usage)
* [Create a database](#create-a-database)
* [Create a table](#create-a-table)
* [Query a database and list the tables](#query-a-database-and-list-the-tables)
* [Tutorial](#tutorial)

## Installation

```
opam install sqlite3
```

* Use it in a file:

```ocaml
open Sqlite3
```

* Use it in utop:

```ocaml
#require "sqlite3"
#open Sqlite3
```

## Basic usage
Create a database, a table and do a basic query. The full code can be found in
*samples/sample_1.ml*.

### Create a database
```ocaml
let mydb = db_open "test.db"
```

### Create a table

* the table structure
```
_________________________________
[Contacts                        ]
----------------------------------
| contact_id INTEGER PRIMARY KEY |
| first_name TEXT NOT NULL       |
| last_name  TEXT NOT NULL       |
| email      TEST NOT NULL UNIQUE|
| phone      TEST NOT NULL UNIQUE|
|________________________________|
```

* the query to create the table

```ocaml
let create_table_sql = "CREATE TABLE contacts ( \
                          contact_id INTEGER PRIMARY KEY, \
                          first_name TEXT NOT NULL, \
                          last_name TEXT NOT NULL, \
                          email text NOT NULL UNIQUE, \
                          phone text NOT NULL UNIQUE \
                        );"

let db = db_open "test.db"

let () =
  match exec db create_table_sql with
  | Rc.OK -> print_endline "Ok"
  | r -> prerr_endline (Rc.to_string r); prerr_endline (errmsg db)
```

With the command line client of sqlite, we can verify the good execution of our
code with:

```
sqlite3 test.db
sqlite> SELECT name FROM sqlite_master WHERE type='table';
contacts
sqlite> PRAGMA table_info(contacts);
0|contact_id|INTEGER|0||1
1|first_name|TEXT|1||0
2|last_name|TEXT|1||0
3|email|text|1||0
4|phone|text|1||0
```

### Query a database and list the tables

* first create a callback that will display gathered information

```ocaml
let cb row header = match row.(0) with
| Some a -> print_endline a
| None -> ();;
```

* then create the query
```ocaml
let sql = "SELECT name FROM sqlite_master WHERE type='table';";;
```

* then excute the query
```ocaml
match exec db ~cb show_default_tables with
| Rc.OK -> ()
| r -> prerr_endline (Rc.to_string r); prerr_endline (errmsg db);;

```

## More usage examples

More examples can be found in [README_sqlite3_tutorial](README_sqlite3_tutorial.md)

## Using the orm module
https://github.com/mirage/orm


## References

* https://stackoverflow.com/questions/82875/how-to-list-the-tables-in-a-sqlite-database-file-that-was-opened-with-attach
* https://www.tutorialspoint.com/sqlite
* http://www.sqlitetutorial.net/
* https://mmottl.github.io/sqlite3-ocaml/
* http://mmottl.github.io/sqlite3-ocaml/api/sqlite3/Sqlite3/index.html

# OCaml SQLite notes

This is the notes I gathered while I was trying to do the tutorial http://www.sqlitetutorial.net/ with OCaml-sqlite.


## Introduction
I follow the www.sqlitetutorial.net to test the OCaml Sqlite3 library. The sample used for the queries can be found at this address: http://www.sqlitetutorial.net/sqlite-sample-database/

### Installation

```
opam install sqlite3
```

Use it in utop:

```ocaml
#require "sqlite3"
#open Sqlite3
```

### TL;DR: create a database, a table and do a basic query

#### Create a database
```ocaml
let mydb = db_open "test.db";;

```

#### Create a table:

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


```ocaml
let create_table_sql = "CREATE TABLE contacts (
 contact_id INTEGER PRIMARY KEY,
 first_name TEXT NOT NULL,
 last_name TEXT NOT NULL,
 email text NOT NULL UNIQUE,
 phone text NOT NULL UNIQUE
);" in
match exec db create_tabel_sql with
| Rc.OK -> print_endline "Ok"
| r -> prerr_endline (Rc.to_string r); prerr_endline (errmsg db);;
```

#### Query a database: List the tables

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

## Tutorial
in utop: `let db = db_open "./chinook.db";;`

### SQLite Select

## Using the orm module
https://github.com/mirage/orm


## References

* https://stackoverflow.com/questions/82875/how-to-list-the-tables-in-a-sqlite-database-file-that-was-opened-with-attach
* https://www.tutorialspoint.com/sqlite
* http://www.sqlitetutorial.net/
* https://mmottl.github.io/sqlite3-ocaml/
* http://mmottl.github.io/sqlite3-ocaml/api/sqlite3/Sqlite3/index.html

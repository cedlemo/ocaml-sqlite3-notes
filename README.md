# OCaml SQLite notes

This is the notes I gathered while I was trying to do the tutorial http://www.sqlitetutorial.net/ with OCaml-sqlite.


## Installation

```
opam install sqlite3
```

Use it in utop:

```
#require "sqlite3"
#open Sqlite3
```

## Create database and tables

```
let mydb = db_open "test";;

```

Create a table:

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

```
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

List tables
* https://stackoverflow.com/questions/82875/how-to-list-the-tables-in-a-sqlite-database-file-that-was-opened-with-attach
```
let show_default_tables = "SELECT name FROM sqlite_master WHERE type='table';";;
match exec db ~cb show_default_tables with
| Rc.OK -> ()
| r -> prerr_endline (Rc.to_string r); prerr_endline (errmsg db);;

```

# Using the orm module
https://github.com/mirage/orm


# OCaml SQLite notes

* [Installation](#installation)
* [basic usage](#basic-usage)
  * [Create a database](#create-a-database)
  * [Create a table](#create-a-table)
  * [Handle basic error on request](#handle-basic-error-on-request)
  * [Query a database](#query-a-database)
* [User defined functions](#user-defined-functions)
* [Statements](#statements)
* [sqlexpr](#sqlexpr)
* [orm](#orm)

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

### Handle basic error request

When opening a database with the *ocaml-sqlite3* lib, the function
`Sqlite3.db_open` returns a `Sqlite3.db` database handle. This handle stores the
error code of the last operation.

The `Sqlite3.exec` function returns a [`Sqlite3.Rc.t` type](http://mmottl.github.io/sqlite3-ocaml/api/sqlite3/Sqlite3/Rc/index.html#type-t). In this variant there is one particular tag : *OK*
that is returned when the query is successful. All the other cases can be considered
like an error. A string corresponding to this type can be obtained with the
function `val to_string : Rc.t ‑> string`, it can be useful to display the kind
of error you are facing.

Furthermore, when you have one of this error, its possible to ask for an error
message from the database handle with the function: `Sqlite3.errmsg`.

In the *sample_2*, there is a query on a database that does not exits.

```ocaml
(** Build with ocamlbuild -pkg sqlite3 sample_2.native or use make sample_2 *)

open Sqlite3

let mydb = db_open "test.db"

let create_table_sql = "SELECT first_name FROM bad_table_name;"

let db = db_open "test.db"

let () =
  match exec db create_table_sql with
  | Rc.OK -> print_endline "Ok"
  | r -> prerr_endline (Rc.to_string r); prerr_endline (errmsg db)
```

When executed, this sample display the following information:

```
ERROR
no such table: bad_table_name
```

### Query a database

In the following example (*samples/sample_3.ml*), there will be multiples queries.

```
(** Build with ocamlbuild -pkg sqlite3 sample_3.native or use make sample_3 *)

open Sqlite3

let db = db_open "test.db"

let gracefully_exist error message =
  let () = prerr_endline (Rc.to_string error) in
  let () = prerr_endline (errmsg db) in
  let () = prerr_endline message in
  let _closed = db_close db in
  let () = prerr_endline "Exiting ..." in
  exit 1

let create_contacts_table () =
  let create_table_sql = "CREATE TABLE contacts ( \
                          contact_id INTEGER PRIMARY KEY, \
                          first_name TEXT NOT NULL, \
                          last_name TEXT NOT NULL, \
                          email text NOT NULL UNIQUE, \
                          phone text NOT NULL UNIQUE \
                          );"
  in match exec db create_table_sql with
  | Rc.OK -> ()
  | r ->
    let message = "Unable to create table contacts." in
    gracefully_exist r message

(* Query that should returns a result if a table contacts exists *)
let check_table_sql =
  "SELECT COUNT(name) FROM sqlite_master WHERE type='table' AND name='contacts'"

(* Callback that checks if there is already a table contacts and if not creates
   it *)
let check_table_cb row = match row.(0) with
  | Some a ->
    if a = "0" then begin
      let () = print_endline "Creating the table Contacts" in
      create_contacts_table ()
    end else print_endline "The table Contacts already exists"
  | None -> ()

let ensure_table_contacts_exists () =
  match exec_no_headers db ~cb:check_table_cb check_table_sql with
  | Rc.OK -> ()
  | r ->
    let message =  "Unable to check if the table Contacts exists." in
    gracefully_exist r message

(* Lets add some data in our table *)
let data = [
  ("NULL", "Jean", "Pignon", "jean@pignon.fr", "123456789");
  ("NULL", "Marcelle", "Michue", "marcelle@michue.fr", "987654321");
]

let clean_table () =
  let sql = "DELETE FROM Contacts" in
  match exec db sql with
  | Rc.OK -> ()
  | r ->
    let message =  "Unable to clean the table Contacts." in
    gracefully_exist r message

let add_data () =
  let rec _add = function
    | [] -> print_endline "Insertion finished"
    | (id, fn, ln, mail, phone) :: t ->
      let sql =
        Printf.sprintf "INSERT INTO Contacts VALUES(%s,'%s','%s','%s','%s')"
          id fn ln mail phone
      in
      let () = begin match exec db sql with
        | Rc.OK ->
          let id = Sqlite3.last_insert_rowid db in
          Printf.printf "Row inserted with id %Ld\n" id
        | r -> prerr_endline (Rc.to_string r); prerr_endline (errmsg db)
      end
      in _add t
  in _add data

let () =
  let () = ensure_table_contacts_exists () in
  let () = clean_table () in
  add_data ()
```

## User defined functions

## Statements

## sqlexpr
## sequoia

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

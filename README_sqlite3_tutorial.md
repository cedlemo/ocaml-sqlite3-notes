# OCaml SQLite notes

This is the notes I gathered while I was trying to do the tutorial http://www.sqlitetutorial.net/ with OCaml-sqlite.

* [Introduction](#introduction)
  * [Installation](#installation)
  * [TL;DR](#tl;dr)
    * [Create a database](#create-a-database)
    * [Create a table](#create-a-table)
    * [Query a database and list the tables](#query-a-database-and-list-the-tables)
* [Tutorial](#tutorial)
  * [SQLite Simple query](#sqlite-simple-query)
  * [SQLite Sorting rows](#sqlite-sorting-rows)
  * [SQLite Filtering data](#sqlite-filtering-data)
    * [Distinct](#distinct)
    * [Where](#where)
    * [Limit](#limit)
    * [Between](#between)
  * [Joining Tables](#joining-tables)
* [Using the orm module](#using-the-orm-module)
* [references](#references)

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

### TL;DR
Create a database, a table and do a basic query

#### Create a database
```ocaml
let mydb = db_open "test.db";;
```

#### Create a table
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

#### Query a database and list the tables

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

in utop open the sample database: `let db = db_open "./chinook.db";;`

and create the following callback that will be used to display the results of the query:

```ocaml
let cb row headers =
  let n = Array.length row - 1 in
  let () = for i = 0 to n do
    let value = match row.(i) with | Some s -> s | None -> "Null" in
    Printf.printf "| %s: %s |" headers.(i) value
    done
  in print_endline "";
```

### SQLite Simple query
* Simple SELECT statements

```ocaml
exec db ~cb "SELECT 1 + 1";;
| 1 + 1: 2 |
(* Rc.t = Sqlite3.Rc.OK *)
exec db ~cb "SELECT 10 / 5, 2 * 4";;
| 10 / 5: 2 || 2 * 4: 8 |
(* Rc.t = Sqlite3.Rc.OK *)
```

* Querying data using SELECT

Define the sql query we want to use:

```ocaml
let sql = "SELECT trackid, name, composer, unitprice FROM tracks";;
```

Execute the query:
```ocaml
exec db ~cb sql;;
(* other rows omitted *)
| TrackId: 3501 || Name: L'orfeo, Act 3, Sinfonia (Orchestra) || Composer: Claudio Monteverdi || UnitPrice: 0.99 |
| TrackId: 3502 || Name: Quintet for Horn, Violin, 2 Violas, and Cello in E Flat Major, K. 407/386c: III. Allegro || Composer: Wolfgang Amadeus Mozart || UnitPrice: 0.99 |
| TrackId: 3503 || Name: Koyaanisqatsi || Composer: Philip Glass || UnitPrice: 0.99 |
(* Rc.t = Sqlite3.Rc.OK *)
```

* SELECT with the infamous '*'

```ocaml
let sql = "SELECT * FROM tracks";;
```

```ocaml
exec db ~cb sql;;
(* other rows omitted *)
| TrackId: 3503 || Name: Koyaanisqatsi || AlbumId: 347 || MediaTypeId: 2 || GenreId: 10 || Composer: Philip Glass || Milliseconds: 206005 || Bytes: 3305164 || UnitPrice: 0.99 |
(* Rc.t = Sqlite3.Rc.OK *)
```

### SQLite Sorting rows
From a basic request `let sql = "SELECT name,milliseconds,albumid FROM tracks";;`, if we wanted to order the rows based albumid (ascending) and on the length on the songs (descending), the new request is:

```ocaml
let sql = "SELECT name,milliseconds,albumid FROM tracks ORDER BY albumid ASC, milliseconds DESC";;
```

The output will be:

```ocaml
exec db ~cb sql;;
(* other rows omitted *)
| Name: Amy Amy Amy (Outro) || Milliseconds: 663426 || AlbumId: 322 |
| Name: You Sent Me Flying / Cherry || Milliseconds: 409906 || AlbumId: 322 |
| Name: In My Bed || Milliseconds: 315960 || AlbumId: 322 |
| Name: Help Yourself || Milliseconds: 300884 || AlbumId: 322 |
| Name: Intro / Stronger Than Me || Milliseconds: 234200 || AlbumId: 322 |
| Name: What Is It About Men || Milliseconds: 209573 || AlbumId: 322 |
| Name: October Song || Milliseconds: 204846 || AlbumId: 322 |
| Name: F**k Me Pumps || Milliseconds: 200253 || AlbumId: 322 |
| Name: Take the Box || Milliseconds: 199160 || AlbumId: 322 |
| Name: (There Is) No Greater Love (Teo Licks) || Milliseconds: 167933 || AlbumId: 322 |
| Name: I Heard Love Is Blind || Milliseconds: 129666 || AlbumId: 322 |
| Name: Slowness || Milliseconds: 215386 || AlbumId: 323 |
| Name: Prometheus Overture, Op. 43 || Milliseconds: 339567 || AlbumId: 324 |
(* other rows omitted *)
(* Rc.t = Sqlite3.Rc.OK *)
```

If we wanted to order the rows based on the columns milliseconds and albumid in an ascending order (by default) it is possible to use number.

```ocaml
let sql = "SELECT name,milliseconds,albumid FROM tracks ORDER BY 2,3";;
```

```ocaml
exec db ~cb sql;;
(* other rows omitted *)
| Name: Battlestar Galactica, Pt. 3 || Milliseconds: 2927802 || AlbumId: 253 |
| Name: Murder On the Rising Star || Milliseconds: 2935894 || AlbumId: 253 |
| Name: Battlestar Galactica, Pt. 1 || Milliseconds: 2952702 || AlbumId: 253 |
| Name: Battlestar Galactica, Pt. 2 || Milliseconds: 2956081 || AlbumId: 253 |
| Name: The Man With Nine Lives || Milliseconds: 2956998 || AlbumId: 253 |
| Name: Greetings from Earth, Pt. 1 || Milliseconds: 2960293 || AlbumId: 253 |
| Name: Through a Looking Glass || Milliseconds: 5088838 || AlbumId: 229 |
| Name: Occupation / Precipice || Milliseconds: 5286953 || AlbumId: 227 |
- : Rc.t = Sqlite3.Rc.OK
```

### SQLite Filtering data

#### Distinct

with `let sql = "SELECT city FROM customers;";;`, we can see that there are some
rows with the same cities:

```ocaml
match exec db ~cb sql with
| Rc.OK -> ()
| r -> prerr_endline (Rc.to_string r); prerr_endline (errmsg db);;
| City: São José dos Campos |
| City: Stuttgart |
| City: Montréal |
| City: Oslo |
| City: Prague |
| City: Prague |
| City: Vienne |
| City: Brussels |
| City: Copenhagen |
| City: São Paulo |
| City: São Paulo |
```

This can be solved using `DISTINCT`:

```ocaml
val sql : string = "SELECT DISTINCT city FROM customers;"
match exec db ~cb sql with
| Rc.OK -> ()
| r -> prerr_endline (Rc.to_string r); prerr_endline (errmsg db);;
| City: São José dos Campos |
| City: Stuttgart |
| City: Montréal |
| City: Oslo |
| City: Prague |
| City: Vienne |
| City: Brussels |
| City: Copenhagen |
| City: São Paulo |
| City: Rio de Janeiro |
```

Note:
the `SELECT DISTINCT` clause will apply to all the columns of the SQL statement:

```
SELECT city, country FROM customers ORDER BY country;
```

#### Where

* Where with equality operator:

```ocaml
let sql = "SELECT name FROM tracks WHERE albumid = 1;";;
match exec db ~cb sql with
| Rc.OK -> ()
| r -> prerr_endline (Rc.to_string r); prerr_endline (errmsg db);;
| Name: For Those About To Rock (We Salute You) |
| Name: Put The Finger On You |
| Name: Let's Get It Up |
| Name: Inject The Venom |
| Name: Snowballed |
| Name: Evil Walks |
| Name: C.O.D. |
| Name: Breaking The Rules |
| Name: Night Of The Long Knives |
| Name: Spellbound
```

* Where with logical operator to combine expressions

``` ocaml
let sql = "SELECT name FROM tracks WHERE albumid = 1 AND milliseconds > 250000;";;
match exec db ~cb sql with
| Rc.OK -> ()
| r -> prerr_endline (Rc.to_string r); prerr_endline (errmsg db);;
| Name: For Those About To Rock (We Salute You) |
| Name: Evil Walks |
| Name: Breaking The Rules |
| Name: Spellbound |
```

* Where with `LIKE` operator:
```ocaml
let sql = "SELECT name, composer FROM tracks WHERE composer LIKE '%Smith%';";;
match exec db ~cb sql with
| Rc.OK -> ()
| r -> prerr_endline (Rc.to_string r); prerr_endline (errmsg db);;
| Name: Restless and Wild || Composer: F. Baltes, R.A. Smith-Diesel, S. Kaufman, U. Dirkscneider & W. Hoffman |
| Name: Princess of the Dawn || Composer: Deaffy & R.A. Smith-Diesel |
| Name: Killing Floor || Composer: Adrian Smith |
| Name: Machine Men || Composer: Adrian Smith |
| Name: 2 Minutes To Midnight || Composer: Adrian Smith/Bruce Dickinson |
| Name: Can I Play With Madness || Composer: Adrian Smith/Bruce Dickinson/Steve Harris |
| Name: The Evil That Men Do || Composer: Adrian Smith/Bruce Dickinson/Steve Harris |
| Name: The Wicker Man || Composer: Adrian Smith/Bruce Dickinson/Steve Harris |
(* ... *)
```

* Where with `IN` operator:
```ocaml
let sql = "SELECT name, MediaTypeId FROM tracks WHERE mediatypeid IN (2,3);";;
match exec db ~cb sql with
| Rc.OK -> ()
| r -> prerr_endline (Rc.to_string r); prerr_endline (errmsg db);;
| Name: Balls to the Wall || MediaTypeId: 2 |
| Name: Fast As a Shark || MediaTypeId: 2 |
| Name: Restless and Wild || MediaTypeId: 2 |
| Name: Princess of the Dawn || MediaTypeId: 2 |
```

#### Limit

The `LIMIT` clause, constrain the number of rows returned by a query.

```ocaml
let sql = "SELECT trackid, name FROM tracks LIMIT 10;";;
match exec db ~cb sql with
| Rc.OK -> ()
| r -> prerr_endline (Rc.to_string r); prerr_endline (errmsg db);;
| TrackId: 1 || Name: For Those About To Rock (We Salute You) |
| TrackId: 2 || Name: Balls to the Wall |
| TrackId: 3 || Name: Fast As a Shark |
| TrackId: 4 || Name: Restless and Wild |
| TrackId: 5 || Name: Princess of the Dawn |
| TrackId: 6 || Name: Put The Finger On You |
| TrackId: 7 || Name: Let's Get It Up |
| TrackId: 8 || Name: Inject The Venom |
| TrackId: 9 || Name: Snowballed |
| TrackId: 10 || Name: Evil Walks |
```

The `LIMIT` clause accepts an offset:
```ocaml
let sql = "SELECT trackid, name FROM tracks LIMIT 10 OFFSET 2;";;
match exec db ~cb sql with
| Rc.OK -> ()
| r -> prerr_endline (Rc.to_string r); prerr_endline (errmsg db);;
| TrackId: 3 || Name: Fast As a Shark |
| TrackId: 4 || Name: Restless and Wild |
| TrackId: 5 || Name: Princess of the Dawn |
| TrackId: 6 || Name: Put The Finger On You |
| TrackId: 7 || Name: Let's Get It Up |
| TrackId: 8 || Name: Inject The Venom |
| TrackId: 9 || Name: Snowballed |
| TrackId: 10 || Name: Evil Walks |
| TrackId: 11 || Name: C.O.D. |
| TrackId: 12 || Name: Breaking The Rules |
```

which is equivalent to :
```ocaml
let sql = "SELECT trackid, name FROM tracks LIMIT 2, 10;";;
match exec db ~cb sql with
| Rc.OK -> ()
| r -> prerr_endline (Rc.to_string r); prerr_endline (errmsg db);;
| TrackId: 3 || Name: Fast As a Shark |
| TrackId: 4 || Name: Restless and Wild |
| TrackId: 5 || Name: Princess of the Dawn |
| TrackId: 6 || Name: Put The Finger On You |
| TrackId: 7 || Name: Let's Get It Up |
| TrackId: 8 || Name: Inject The Venom |
| TrackId: 9 || Name: Snowballed |
| TrackId: 10 || Name: Evil Walks |
| TrackId: 11 || Name: C.O.D. |
| TrackId: 12 || Name: Breaking The Rules |
```

Notes:
* `OFFSET` is often used for paginating result sets in web applications.
* `ORDER BY` is used before `LIMIT` : `SELECT ... FROM ... ORDER BY ... LIMIT ...`
* the combinaison of `ORDER BY` and `LIMIT OFFSET` are commonly used to get the nth
highest or lowest value: `SELECT ... FROM ... ORDER BY ... DESC LIMIT 1 OFFSET 1` or
`SELECT ... FROM ... ORDER BY ... DESC LIMIT 1 OFFSET 1`.

#### Between
Can be used with `SELECT`, `DELETE`, `UPDATE`, `REPLACE` in the `WHERE` clause.

```ocaml
let sql = "SELECT invoiceid, BillingAddress, Total FROM invoices WHERE Total BETWEEN 14.91 AND 18.86 ORDER BY
total;";;
match exec db ~cb sql with
| Rc.OK -> ()
| r -> prerr_endline (Rc.to_string r); prerr_endline (errmsg db);;
| InvoiceId: 193 || BillingAddress: Berger Straße 10 || Total: 14.91 |
| InvoiceId: 103 || BillingAddress: 162 E Superior Street || Total: 15.86 |
| InvoiceId: 208 || BillingAddress: Ullevålsveien 14 || Total: 15.86 |
| InvoiceId: 306 || BillingAddress: Klanova 9/506 || Total: 16.86 |
| InvoiceId: 313 || BillingAddress: 68, Rue Jouvence || Total: 16.86 |
| InvoiceId: 88 || BillingAddress: Calle Lira, 198 || Total: 17.91 |
| InvoiceId: 89 || BillingAddress: Rotenturmstraße 4, 1010 Innere Stadt || Total: 18.86 |
| InvoiceId: 201 || BillingAddress: 319 N. Frances Street || Total: 18.86 |
```
* `NOT BETWEEN`

```ocaml
let sql = "SELECT invoiceid, BillingAddress, Total FROM invoices WHERE Total NOT BETWEEN 1 AND 20 ORDER BY tot
al;";;
match exec db ~cb sql with
| Rc.OK -> ()
| r -> prerr_endline (Rc.to_string r); prerr_endline (errmsg db);;
| InvoiceId: 6 || BillingAddress: Berger Straße 10 || Total: 0.99 |
| InvoiceId: 13 || BillingAddress: 1600 Amphitheatre Parkway || Total: 0.99 |
| InvoiceId: 20 || BillingAddress: 110 Raeburn Pl || Total: 0.99 |
| InvoiceId: 27 || BillingAddress: 5112 48 Street || Total: 0.99 |
| InvoiceId: 34 || BillingAddress: Praça Pio X, 119 || Total: 0.99 |
| InvoiceId: 41 || BillingAddress: C/ San Bernardo 85 || Total: 0.99 |
| InvoiceId: 48 || BillingAddress: 796 Dundas Street West || Total: 0.99 |
(* ... *)
```

* `BETWEEN` dates

```ocaml
let sql = "SELECT invoiceid, BillingAddress, InvoiceDate, Total FROM invoices WHERE invoicedate BETWEEN '2010-01-01' AND '2010-01-31';";;
match exec db ~cb sql with
| Rc.OK -> () | r -> prerr_endline (Rc.to_string r); prerr_endline (errmsg db);;
| InvoiceId: 84 || BillingAddress: 68, Rue Jouvence || InvoiceDate: 2010-01-08 00:00:00 || Total: 1.98 |
| InvoiceId: 85 || BillingAddress: Erzsébet krt. 58. || InvoiceDate: 2010-01-08 00:00:00 || Total: 1.98 |
| InvoiceId: 86 || BillingAddress: Via Degli Scipioni, 43 || InvoiceDate: 2010-01-09 00:00:00 || Total: 3.96 |
| InvoiceId: 87 || BillingAddress: Celsiusg. 9 || InvoiceDate: 2010-01-10 00:00:00 || Total: 6.94 |
| InvoiceId: 88 || BillingAddress: Calle Lira, 198 || InvoiceDate: 2010-01-13 00:00:00 || Total: 17.91 |
| InvoiceId: 89 || BillingAddress: Rotenturmstraße 4, 1010 Innere Stadt || InvoiceDate: 2010-01-18 00:00:00 || Total: 18.86 |
| InvoiceId: 90 || BillingAddress: 801 W 4th Street || InvoiceDate: 2010-01-26 00:00:00 || Total: 0.99 |

```

### Joining Tables
SQLite supports :
* inner join: if there are no match for a value of table A in table B, the row will not be in the result of the query. The result number of rows will be <= to the number of rows of A.
* left join: if there are no match for the pivot value of table A in table B, the rows will be in the result of the query and the missing values of B will be filled with NULL. The number of rows of the result of the query will be equal to the number of rows of A.
* cross join: this is the Cartesion product, so the number of rows of the result of the query will be equal to n rows of A x n rows of B.
* self join: this is used to join a table on itself.
* full outer join: this is a combinaison of `LEFT JOIN` and `RIGHT JOIN` (which do not exist in SQLite).

```ocaml
let sql = "SELECT trackid, name, title FROM tracks INNER JOIN albums ON albums.albumid = tracks.albumid;";;
```

## Using the orm module
https://github.com/mirage/orm


## References

* https://stackoverflow.com/questions/82875/how-to-list-the-tables-in-a-sqlite-database-file-that-was-opened-with-attach
* https://www.tutorialspoint.com/sqlite
* http://www.sqlitetutorial.net/
* https://mmottl.github.io/sqlite3-ocaml/
* http://mmottl.github.io/sqlite3-ocaml/api/sqlite3/Sqlite3/index.html

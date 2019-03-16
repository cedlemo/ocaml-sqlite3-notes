(** Build with ocamlbuild -pkg sqlite3 sample_1.native *)

open Sqlite3

let mydb = db_open "test.db"

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

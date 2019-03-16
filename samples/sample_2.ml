(** Build with ocamlbuild -pkg sqlite3 sample_2.native or use make sample_2 *)

open Sqlite3

let mydb = db_open "test.db"

let create_table_sql = "SELECT first_name FROM bad_table_name;"

let db = db_open "test.db"

let () =
  match exec db create_table_sql with
  | Rc.OK -> print_endline "Ok"
  | r -> prerr_endline (Rc.to_string r); prerr_endline (errmsg db)

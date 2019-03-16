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

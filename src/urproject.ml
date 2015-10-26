(* This software purpose an easy UrProject builder 
   with SQLITE3 (and builded with a Makefile)
*)

let default_port = "9999"

(* Project description *)
type project = {
  name : string
; database : string option
; port : string option
}

let project name database port = {
  name = name
; database = database
; port = port
}

let s_option = function
  | None -> "none"
  | Some x -> x

let print record =
  let _ = print_endline record.name in
  let _ = print_endline (s_option record.database) in
  print_endline (s_option record.port) 

let name = ref None
let database = ref None
let port = ref None

let database_name p =
  match p.database with
  | None -> p.name
  | Some x -> x

let display_port p =
  match p.port with
  | None -> default_port
  | Some x -> x

let record_name n = name := Some n
let record_db db  = database := Some db
let record_port p = port := Some (string_of_int p)

let dir_exists dir =
  Sys.(file_exists dir && is_directory dir)

let create_dir project =
  if not (dir_exists project.name)
  then Unix.mkdir project.name 0o777

let openp =
  open_out_gen
    [
      Open_wronly;
      Open_creat;
      Open_trunc;
      Open_text
    ]
    0o664

let extend p = Printf.sprintf "%s/%s.%s" p.name p.name

let create_urp project =
  let chan = openp (extend project "urp") in
  let _ =
    Printf.fprintf
      chan
      "database dbname=%s\nsql %s.sql\n\n%s\n"
      (database_name project)
      project.name
      project.name
  in close_out chan
    
let create_urs project =
  let chan = openp (extend project "urs") in
  let _ = output_string chan "val main : unit -> transaction page"
  in close_out chan

let create_ur project =
  let chan = openp (extend project "ur") in
  let _ =
    Printf.fprintf
      chan
      "fun main () = return <xml>\n\t%s\n\t<body>\n\t\t%s\n\t</body>\n</xml>\n"
      ("<head><title>"^project.name^"</title></head>")
      ("<h1>Hello from "^project.name^"</h1>")
  in close_out chan

let create_makefile project =
  let chan = openp (project.name ^ "/Makefile") in
  let tape = ".PHONY: clean build\n"
             ^ "all: run\n\nclean:\n"
             ^ "\trm -rf *~\n\trm -rf \\#*\n\n"
             ^ "distclean: clean\n"
             ^ "\trm -rf " ^ project.name ^ ".exe\n\n"
             ^ project.name ^ ".exe:\n"
             ^ "\turweb -dbms sqlite " ^ project.name ^ "\n\n"
             ^ "init_sql:\n\trm -rf "^(database_name project)^"\n\tsqlite3 "
             ^ (database_name project)
             ^ "<" ^ project.name ^ ".sql\n\n"
             ^ "build: " ^ project.name ^ ".exe init_sql\n\n"
             ^ "run: " ^ project.name ^ ".exe\n"
             ^ "\t./"^project.name^".exe -p " ^ (display_port project)
             ^ "\n\n"
  in 
  let _ = output_string chan tape
  in close_out chan
      
let make project =
  let _ = Printf.printf "create [%s]:\n" project.name in
  let _ = create_dir project in
  let _ = Printf.printf "\t-create %s\n" (extend project "urp") in
  let _ = create_urp project in
  let _ = Printf.printf "\t-create %s\n" (extend project "urs") in
  let _ = create_urs project in
  let _ = Printf.printf "\t-create %s\n" (extend project "ur") in
  let _ = create_ur project in
  let _ = Printf.printf "\t-create Makefile\n" in
  create_makefile project

let () =
  let _ =
    Arg.parse
      [
        ("-db", Arg.String (record_db), "The database's name");
        ("-port", Arg.Int (record_port), "The virtual server port name")
      ]
      record_name
      "urproject.native project_name [-db database_name] [-port port]"
  in
  match !name with
  | None -> print_endline "minimal usage : ./urproject.native project_name"
  | Some rec_name ->
    if Sys.file_exists rec_name then
      Printf.printf "[%s] already exists !\n" rec_name
    else 
      let _ = make (project rec_name !database !port) in
      Printf.printf "[%s] seems to be correctly builded !\n" rec_name
    

open Sys
open Unix

type riemann_connection = {
  host : string;
  port : int;
  sock : Unix.file_descr;
  inc : in_channel;
  outc : out_channel;
}

type riemann_connection_options = {
  riemann_conn_use_nagal : bool;
  riemann_conn_so_timeout : int;
  riemann_conn_connect_timeout : int;
}

let riemann_connection_defaults =
  {
    riemann_conn_use_nagal = false;
    riemann_conn_so_timeout = 1000;
    riemann_conn_connect_timeout = 1000;
  }

let set_nagle fd newval =
  try Unix.setsockopt fd Unix.TCP_NODELAY newval
  with Unix.Unix_error (e, _, _) ->
    print_endline ("Error setting TCP_NODELAY" ^ (Unix.error_message e))

let riemann_connect options hostname portnum =
   let server_addr =
    try (gethostbyname hostname).h_addr_list.(0)
    with Not_found ->
      prerr_endline (hostname ^ ": Host not found");
      exit 2 in
  let riemannsocket = socket PF_INET SOCK_STREAM 0 in
    set_nagle riemannsocket options.riemann_conn_use_nagal;
    connect riemannsocket (ADDR_INET(server_addr, portnum));
    let cout = out_channel_of_descr riemannsocket in
    let cin  = in_channel_of_descr riemannsocket in
    let conn =  {
      host=hostname;
      port=portnum;
      sock=riemannsocket;
      inc=cin;
      outc=cout;
    } in
    conn

let riemann_connect_with_defaults hostname port =
  riemann_connect riemann_connection_defaults hostname port

let riemann_disconnect conn =
  close conn.sock


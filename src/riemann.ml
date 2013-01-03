open Sys
open Unix

exception RiemannException of string * int

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

let send_msg (conn:riemann_connection) (req:Piqirun.OBuf.t) =
  let reqlen = Piqirun.OBuf.size req + 1 in
  output_binary_int conn.outc reqlen;
  Piqirun.to_channel conn.outc req;
  flush conn.outc

let recv_msg (conn:riemann_connection) =
  let resplength = input_binary_int conn.inc in
    match resplength with
      | 0 -> raise (RiemannException ("Unknown response from server",-1))
      | _ ->
          let buf = String.create (resplength-1) in
            really_input conn.inc buf 0 (resplength-1);
            Piqirun.init_from_string(buf)

let send_pb_message (conn:riemann_connection) (req:Piqirun.OBuf.t) =
  send_msg conn req;
  recv_msg conn


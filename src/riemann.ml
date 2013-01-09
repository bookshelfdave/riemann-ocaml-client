open Sys
open Unix
open Riemann_piqi

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

let new_riemann_state () =
  {
    State.time = None;
    State.state = None;
    State.service = None;
    State.host = None;
    State.description = None;
    State.once = None;
    State.tags = [];
    State.ttl = None;
  }

let new_riemann_event () =
  {
    Event.time = None;
    Event.state = None;
    Event.service = None;
    Event.host = None;
    Event.description = None;
    Event.tags = [];
    Event.ttl = None;
    Event.metric_sint64 = None;
    Event.metric_d = None;
    Event.metric_f = None;
  }

let new_riemann_events_msg events =
  {
    Msg.ok = None;
    Msg.error = None;
    Msg.states = [];
    Msg.query = None;
    Msg.events = events;
  }

let new_riemann_states_msg states =
  {
    Msg.ok = None;
    Msg.error = None;
    Msg.states = states;
    Msg.query = None;
    Msg.events = [];
  }

type riemann_event =
  | Event_time of int64
  | Event_state of string
  | Event_service of string
  | Event_host of string
  | Event_description of string
  | Event_tags of string list
  | Event_ttl of float
  | Event_metric_sint64 of int64
  | Event_metric_f of float
  | Event_metric_d of float


type riemann_state =
  | State_time of int64
  | State_state of string
  | State_service of string
  | State_host of string
  | State_description of string
  | State_once of bool
  | State_tags of string list
  | State_ttl of float

let rec process_event opts req =
  match opts with
    | [] -> req
    | (o::os) ->
        match o with
          | Event_time v -> process_event os {req with Event.time = Some v}
          | Event_state v -> process_event os {req with Event.state = Some v}
          | Event_service v -> process_event os {req with Event.service = Some v}
          | Event_host v -> process_event os {req with Event.host = Some v}
          | Event_description v -> process_event os {req with Event.description = Some v}
          | Event_tags v -> process_event os {req with Event.tags = v}
          | Event_ttl v -> process_event os {req with Event.ttl = Some v}
          | Event_metric_sint64 v -> process_event os {req with Event.metric_sint64 = Some v}
          | Event_metric_f v -> process_event os {req with Event.metric_f = Some v}
          | Event_metric_d v -> process_event os {req with Event.metric_d = Some v}

let rec process_state opts req =
  match opts with
    | [] -> req
    | (o::os) ->
        match o with
          | State_time v -> process_state os {req with State.time = Some v}
          | State_state v -> process_state os {req with State.state = Some v}
          | State_service v -> process_state os {req with State.service = Some v}
          | State_host v -> process_state os {req with State.host = Some v}
          | State_description v -> process_state os {req with State.description = Some v}
          | State_once v -> process_state os {req with State.once = Some v}
          | State_tags v -> process_state os {req with State.tags = v}
          | State_ttl v -> process_state os {req with State.ttl = Some v}

let riemann_event opts =
  process_event opts (new_riemann_event())

let riemann_state opts =
  process_state opts (new_riemann_state())

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

let riemann_udp (s, portaddr) (msg:Piqirun.OBuf.t) =
  let rawmsg = (Piqirun.OBuf.to_string(msg)) in
    sendto s rawmsg (String.length rawmsg) 0 [] portaddr

let riemann_udp_socket hostname portnum =
  let portaddr = Unix.ADDR_INET (Unix.inet_addr_of_string hostname, portnum) in
  let s = socket Unix.PF_INET Unix.SOCK_DGRAM 0 in
    (s, portaddr)

let rec testit2 sock n =
  match n with
    | 0 -> print_endline "Done!"
    | n ->
       testit2 sock (n-1)

let _ =
  (*let udp_socket = riemann_udp_socket "127.0.0.1" 5555 in*)
  let state = riemann_state [State_state "critical";
                             State_service "system";
                             State_host "localhost";
                             State_description "FOO";
                             State_once false;
                             State_ttl 100000.0;
                          ] in
  let msg = new_riemann_states_msg [state] in
  (*riemann_udp udp_socket (gen_msg msg);*)
  let conn = riemann_connect_with_defaults "127.0.0.1" 5555 in
    send_msg conn (gen_msg msg);
    print_endline "Done!"


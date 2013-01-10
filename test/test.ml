open Riemann
open Riemann_piqi
open Sys
open Unix
open OUnit

let testservice() =
  let i = int_of_float(Unix.time()) in
    Random.init i;
    let num = Random.int 999999999 in
    let tb = ("testservice_" ^ string_of_int(num)) in
      tb;;

let test_ip() =
  try
    Sys.getenv("RIEMANN_OCAML_TEST_IP")
  with Not_found ->
    "127.0.0.1"

let test_port() =
  try
    int_of_string(Sys.getenv("RIEMANN_OCAML_TEST_PORT"))
  with Not_found ->
    5555

let test_case_event_udp _ =
  let udp_socket = riemann_udp_socket (test_ip()) (test_port()) in
  let event =
    riemann_event [
      Event_host "www1";
      Event_service (testservice());
      Event_metric_f 2.53;
      Event_state "critical";
      Event_description  "Request took 2.53 seconds";
      Event_tags  ["http"] ] in
  let event_msg = new_riemann_events_msg [event] in
  let _ = send_msg_udp udp_socket event_msg in
    sleep(1);
    let msg = new_riemann_query_msg "tagged \"http\"" in
    let conn = riemann_connect_with_defaults "127.0.0.1" 5555 in
      send_msg_tcp conn msg;
      let resp = recv_msg_tcp conn in
        match resp.Msg.ok with
          | Some _ ->
              print_endline(string_of_int(List.length(resp.Msg.events)));
              print_endline(string_of_int(List.length(resp.Msg.states)))
          | None -> print_endline ":-("


let suite = "Riemann" >:::
            [
              "test_case_event_udp" >:: (test_case_event_udp);
            ]

let _ = run_test_tt_main suite


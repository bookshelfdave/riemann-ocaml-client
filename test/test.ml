open Riemann
open Riemann_piqi
open Sys
open Unix
open OUnit

let test_desc() =
  (* sleep to guarantee a unique service name *)
  sleep(1);
  let i = int_of_float(Unix.time()) in
    Random.init i;
    let num = Random.int 999999999 in
    let tb = ("testservice" ^ string_of_int(num)) in
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
  let desc = test_desc() in
  let ip = test_ip() in
  let port = test_port() in
  let udp_socket = riemann_udp_socket ip port in
  let event =
    riemann_event [
      Event_host "www1";
      Event_service "testservice";
      Event_metric_f 2.53;
      Event_state "critical";
      Event_description desc;
      Event_tags  ["http"] ] in
  let event_msg = new_riemann_events_msg [event] in
  let _ = send_msg_udp udp_socket event_msg in
    let q = ("service = \"testservice\" and description=\"" ^ desc ^ "\"") in
      print_endline ("Query: " ^ q);
    let msg = new_riemann_query_msg q in
      let conn = riemann_connect_with_defaults ip port in
        let resp = send_msg_tcp conn msg in
          match resp.Msg.ok with
            | Some _ ->
                assert_bool "Check for a single event" (1 == List.length(resp.Msg.events))
            | None -> assert_bool "No events" (1 == 2)

let test_case_state_udp _ =
  let desc = test_desc() in
  let ip = test_ip() in
  let port = test_port() in
  let udp_socket = riemann_udp_socket ip port in
  let state =
    riemann_state [
      State_host "www1";
      State_service "testservice";
      State_state "critical";
      State_description desc;
      State_tags  ["http"] ] in
  let state_msg = new_riemann_states_msg [state] in
  let _ = send_msg_udp udp_socket state_msg in
    ()

let test_case_event_tcp _ =
  let desc = test_desc() in
  let ip = test_ip() in
  let port = test_port() in
  let event =
    riemann_event [
      Event_host "www1";
      Event_service "testservice";
      Event_metric_f 2.53;
      Event_state "critical";
      Event_description desc;
      Event_tags  ["http"] ] in
  let event_msg = new_riemann_events_msg [event] in
  let conn = riemann_connect_with_defaults ip port in
  let _resp = send_msg_tcp conn event_msg in
    let q = ("service = \"testservice\" and description=\"" ^ desc ^ "\"") in
      print_endline ("Query: " ^ q);
    let msg = new_riemann_query_msg q in
    let resp = send_msg_tcp conn msg in
          match resp.Msg.ok with
            | Some _ ->
                assert_bool "Check for a single event" (1 == List.length(resp.Msg.events))
            | None -> assert_bool "No events" (1 == 2)

let suite = "Riemann" >:::
            [
              "test_case_event_udp" >:: (test_case_event_udp);
              "test_case_state_udp" >:: (test_case_state_udp);
              "test_case_event_tcp" >:: (test_case_event_tcp);
            ]

let _ = run_test_tt_main suite


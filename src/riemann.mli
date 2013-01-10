(*
-------------------------------------------------------------------

riemann.mli: Riemann OCaml Client

 Copyright (c) 2013 Dave Parfitt
 All Rights Reserved.

 This file is provided to you under the Apache License,
 Version 2.0 (the "License"); you may not use this file
 except in compliance with the License.  You may obtain
 a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the Licese is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
-------------------------------------------------------------------
*)

(* scroll to the bottom for relevant functions *)

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

val riemann_connection_defaults : riemann_connection_options

type riemann_event =
    Event_time of int64
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
    State_time of int64
  | State_state of string
  | State_service of string
  | State_host of string
  | State_description of string
  | State_once of bool
  | State_tags of string list
  | State_ttl of float

(* internal function *)

val new_riemann_state : unit -> Riemann_piqi.State.t

val new_riemann_event : unit -> Riemann_piqi.Event.t

val new_riemann_query : string option -> Riemann_piqi.Query.t

val new_riemann_events_msg :
  Riemann_piqi.Riemann_piqi.event list -> Riemann_piqi.Msg.t

val new_riemann_states_msg :
  Riemann_piqi.Riemann_piqi.state list -> Riemann_piqi.Msg.t

val new_riemann_query_msg : string -> Riemann_piqi.Msg.t

val process_event :
  riemann_event list -> Riemann_piqi.Event.t -> Riemann_piqi.Event.t

val process_state :
  riemann_state list -> Riemann_piqi.State.t -> Riemann_piqi.State.t

val set_nagle : Unix.file_descr -> bool -> unit

(* public functions - these are the ones you want to use *)
val riemann_connect :
  riemann_connection_options -> string -> int -> riemann_connection

val riemann_connect_with_defaults : string -> int -> riemann_connection

val riemann_disconnect : riemann_connection -> unit

val send_msg_tcp : riemann_connection -> Riemann_piqi.Msg.t -> Riemann_piqi.Msg.t

(*val recv_msg_tcp : riemann_connection -> Riemann_piqi.Msg.t*)

val send_msg_udp :
  Unix.file_descr * Unix.sockaddr -> Riemann_piqi.Msg.t -> int

val riemann_udp_socket : string -> int -> Unix.file_descr * Unix.sockaddr

val riemann_event : riemann_event list -> Riemann_piqi.Event.t

val riemann_state : riemann_state list -> Riemann_piqi.State.t

val riemann_query : string -> Riemann_piqi.Msg.t


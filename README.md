riemann-ocaml-client
====================

© 2013 Dave Parfitt

riemann-ocaml-client is a [Riemann](http://riemann.io) client for OCaml.

Super fancy docs [here](http://metadave.github.com/riemann-ocaml-client).

## Dependencies

* [ocamlfind](http://projects.camlcity.org/projects/findlib.html)
* [Piqi](http://piqi.org/) 
* [Protobuffs](http://code.google.com/p/protobuf/)
   * On OSX, `brew install protobuf` if you are using Homebrew
* [OUnit](http://ounit.forge.ocamlcore.org/)

## Building from source

```
./configure
make
make install
```

## Documentation


### TCP Connections


The following functions allow you to communicate via TCP to Riemann:


	val riemann_connect_with_defaults : string -> int -> riemann_connection
		
	val riemann_connect : riemann_connection_options -> string -> int -> riemann_connection

	val riemann_disconnect : riemann_connection -> unit

The first string parameter of the connect functions is the IP/hostname, and the second parameter is the port # of Riemann.


### UDP Sockets

The following function allows you to open a UDP socket to Riemann. Note the tuple return type.

	val riemann_udp_socket : string -> int -> Unix.file_descr * Unix.sockaddr


### Generating Events

Since most of the fields of the Riemann Event message are optional, you can use the `riemann_event` function to pass a list of desired parameters without manually populating the entire record. If you want more control of the Event record, you can simply instantiate a `Riemann_piqi.Event.t`. Note that ultimately, these event messages must be added to a `Msg` record to be passed to Riemann.

```
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

val riemann_event : riemann_event list -> Riemann_piqi.Event.t
```

### Generating States

Since most of the fields of the Riemann State message are optional, you can use the `riemann_state` function to pass a list of desired parameters without manually populating the entire record. If you want more control of the State record, you can simply instantiate a `Riemann_piqi.State.t`. Note that ultimately, these event messages must be added to a `Msg` record to be passed to Riemann.


```
type riemann_state =
    State_time of int64
  | State_state of string
  | State_service of string
  | State_host of string
  | State_description of string
  | State_once of bool
  | State_tags of string list
  | State_ttl of float


val riemann_state : riemann_state list -> Riemann_piqi.State.t
```

### Generating Queries

Since the Riemann Query has only a single string parameter, the `riemann_query` returns a `Riemann_piqi.Msg.t` with the query populated instead of a `Riemann_piqi.Query.t`. Feel free to roll your own `Riemann_piqi.Query.t` if you need it.

```
val riemann_query : string -> Riemann_piqi.Msg.t
```

### Generating Protobuffs Messages w/ Events, States and Queries

Once you have a list of Events, list of States, or Query, you can build a protocol buffers message using the following convenience functions:

	val new_riemann_events_msg : Riemann_piqi.Riemann_piqi.event list -> Riemann_piqi.Msg.t

	val new_riemann_states_msg : Riemann_piqi.Riemann_piqi.state list -> Riemann_piqi.Msg.t

	val new_riemann_query_msg : string -> Riemann_piqi.Msg.t

`Riemann_piqi.Msg.t` records can then be sent to Riemann using `send_msg_tcp` or `send_msg_udp`.

*Note*: since your Query is probably already a `Riemann_piqi.Msg.t`, you probably won't find much use for `new_riemann_query_msg`.

### Sending and Receiving Protobuffs Messages

`Riemann_piqi.Msg.t` records can then be sent to Riemann using `send_msg_tcp` or `send_msg_udp`.


	val send_msg_tcp : riemann_connection -> Riemann_piqi.Msg.t -> Riemann_piqi.Msg.t

	val send_msg_udp : Unix.file_descr * Unix.sockaddr -> Riemann_piqi.Msg.t -> int


## Examples

#### Events

```
  let udp_socket = riemann_udp_socket ip port in
  let event =
    riemann_event [
      Event_host "www1";
      Event_service "testservice";
      Event_metric_f 2.53;
      Event_state "critical";
      Event_description "my description";
      Event_tags  ["http"] ] in
  let event_msg = new_riemann_events_msg [event] in
  let _ = send_msg_udp udp_socket event_msg in
  	()
```

#### States

```
  let udp_socket = riemann_udp_socket ip port in
  let state =
    riemann_state [
      State_host "www1";
      State_service "testservice";
      State_state "critical";
      State_description "my description";
      State_tags  ["http"] ] in
  let state_msg = new_riemann_states_msg [state] in
  let _ = send_msg_udp udp_socket state_msg in
    ()
```

#### Queries


```
let conn = riemann_connect_with_defaults ip port in
let q = ("service = \"testservice\"") in
let msg = new_riemann_query_msg q in
let resp = send_msg_tcp conn msg in
match resp.Msg.ok with
	| Some true -> (* your code here *)
    | Some false -> (* your code here *)
    | None -> (* your code here *)
```

and you'll probably want a `riemann_disconnect` in there somewhere as well.

## Tests

To run the tests, you'll need to run `make test`, and then the `test.byte` executable against a running Riemann instance. To change the IP/Port that the tests connect to, you can use the following environment variables:

	RIEMANN_OCAML_TEST_IP

	RIEMANN_OCAML_TEST_PORT

## TODO

- LWT support if anyone asks about it
- OPAM module once Piqi is released in OPAM

## License & Copyright

Copyright © 2013 Dave Parfitt

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.


riemann-ocaml-client
====================

© 2013 Dave Parfitt

riemann-ocaml-client is a Riemann client for OCaml 3.12.1.

## TODO

- finish documentation
- minor code cleanup
- OPAM module once Piqi is released in OPAM

##Dependencies

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

***work in progress***

In the meantime, checkout the interface:

- src/riemann.mli

Until I write some tests (shame on me), there's some crappy code at the bottom of this file that can serve as an example:

- src/riemann.ml


### TCP Connections

```
val riemann_connect :
  riemann_connection_options -> string -> int -> riemann_connection

val riemann_connect_with_defaults : string -> int -> riemann_connection

val riemann_disconnect : riemann_connection -> unit

val send_msg_tcp : riemann_connection -> Riemann_piqi.Msg.t -> Riemann_piqi.Msg.t
```


### UDP Sockets

```
val send_msg_udp :
  Unix.file_descr * Unix.sockaddr -> Riemann_piqi.Msg.t -> int

val riemann_udp_socket : string -> int -> Unix.file_descr * Unix.sockaddr
```


### Generating Events

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

```
val riemann_query : string -> Riemann_piqi.Msg.t
```

### Generating Protobuffs Messages w/ Events, States and Queries

```
val new_riemann_events_msg :
  Riemann_piqi.Riemann_piqi.event list -> Riemann_piqi.Msg.t

val new_riemann_states_msg :
  Riemann_piqi.Riemann_piqi.state list -> Riemann_piqi.Msg.t

val new_riemann_query_msg : string -> Riemann_piqi.Msg.t
```

## Examples

TODO

## License & Copyright

Copyright © 2013 Dave Parfitt

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.


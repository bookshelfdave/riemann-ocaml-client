riemann-ocaml-client
====================

© 2013 Dave Parfitt

riemann-ocaml-client is a Riemann client for OCaml 3.12.1.

** This code is currently untested, use at your own risk! **

## TODO

- testing
- documentation
- minor code cleanup
- OPAM module

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

## Documentation?

- TODO

In the meantime, checkout the interface:

- [https://github.com/metadave/riemann-ocaml-client/blob/master/src/riemann.mli](riemann.mli)

Until I write some tests (shame on me), there's some crappy code at the bottom of this file that can serve as an example:

- [https://github.com/metadave/riemann-ocaml-client/blob/master/src/riemann.ml](riemann.ml)


## License & Copyright

Copyright © 2013 Dave Parfitt

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.


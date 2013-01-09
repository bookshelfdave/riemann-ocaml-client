riemann-ocaml-client
====================

© 2013 Dave Parfitt

riemann-ocaml-client is a Riemann client for OCaml 3.12.1. 

## TODO

- testing
- documentation
- minor code cleanup

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
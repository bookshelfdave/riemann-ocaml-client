piqi:
	piqi of-proto -I ./src/ ./src/proto.proto -o ./src/riemann.piqi
	piqic ocaml-ext --pp ./src/riemann.piqi -C ./src

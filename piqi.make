piqi:
	piqi of-proto -I ./src/ ./src/riemann.proto -o ./src/riemann.piqi
	piqic ocaml-ext --pp ./src/riemann.piqi
	mv riemann_piqi.ml ./src
	mv riemann_piqi_ext.ml ./src

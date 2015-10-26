all: urproject

urproject:
	ocamlbuild -libs unix src/urproject.native

clean:
	rm -rf *~
	rm -rf */*~
	rm -rf \#*
	rm -rf */\#*
	ocamlbuild -clean

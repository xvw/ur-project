# ur-project
A tiny piece of code for build a Ur/Web project


## Dependancies

*   OCaml <= 4.02 (and OCamlbuild)
*   Urweb
*   (make of course)

## Installation

```bash
git clone https://github.com/xvw/ur-project
cd ur-project
make
# After, you could make an alias
```

## Usage

```bash
./urproject project_name [-db database_name] [-port selected_port]
```

If no Database's name are gived, the Database has the project's name.
If no port are gived, the server is launched on 9999

### Generation
The precedent command line generate a sample project into the the folder
"project_name". This project embed a Makefile :

*   `make build` : initialize the SQL of the project (must be launched at every SQL changement, but it's empty the SQL records)
*   `make distclean` : clean the current build
*   `make run` : launch the virtual server
*   `make [project_name].exe` : recompile the application

# AI Collaboration Notes

Fecha de preparacion local: 2026-07-06

## Repositorio local

- Ruta local: `/Users/administrador/Documents/Codex/2026-07-06/me/copenet_enterprise`
- Remoto: `https://github.com/tmatanza/copenet_enterprise.git`
- Rama local de trabajo: `trabajo-local`
- Rama remota base: `origin/master`
- `origin/master` y `origin/feature/visual-base` apuntan al mismo commit: `0378245 final domingo la mera verga`
- `origin/main` esta atras de `origin/master` por 5 commits y solo llega a `c247b6d Add Codex project instructions`

## Decision de rama base

Trabajar desde `trabajo-local`, creada desde `origin/master`, porque contiene el avance funcional que no existe en `main`: dashboard, usuarios, roles, permisos, menus administrativos, catalogos, cotizaciones, clientes y estilos base.

Evitar trabajar directamente sobre `main` hasta decidir si se debe fusionar `master` hacia `main` o mantener `master` como rama principal real del proyecto.

## Entorno preparado

- Ruby instalado con RVM: `ruby 3.3.8`
- Rails verificado: `Rails 8.1.3`
- Bundler usado por el lockfile: `4.0.15`
- PostgreSQL local iniciado con Homebrew: `postgresql@14`
- Bases creadas/preparadas:
  - `copenet_enterprise_development`
  - `copenet_enterprise_test`

Comandos usados:

```bash
rvm install "ruby-3.3.8"
bundle install
brew services start postgresql@14
bundle exec rails db:prepare
bundle exec rails test
```

## Estado de verificacion inicial

`bundle exec rails test` no esta verde todavia.

Resultado:

```text
34 runs, 123 assertions, 1 failures, 1 errors, 0 skips
```

Problemas detectados:

- `test/integration/sesiones_test.rb:26`
  - El test espera redireccion a `/dashboard`, pero el login redirige de vuelta a `/login`.
  - Probable causa a revisar: flujo de permisos/sesion en `SesionesController` o requisitos de permisos iniciales para usuarios root.

- `test/models/permiso_test.rb:4`
  - Falla creando un permiso duplicado porque ya existe un permiso para ese rol/modulo.
  - Probable causa a revisar: `ModuloSistema` ejecuta sincronizacion automatica de permisos base al crearse, entonces el test crea manualmente un permiso que ya fue generado.

## Reglas de colaboracion

- Leer `AGENTS.md` antes de cambiar codigo.
- Mantener cambios pequenos y con proposito claro.
- Antes de modificar un archivo, revisar su contexto y sus tests relacionados.
- No cambiar Ruby, Rails, Gemfile ni configuracion de base sin documentar el motivo.
- Usar `bundle exec` para comandos Rails, tests, RuboCop y tareas del proyecto.
- Documentar cada cambio relevante en este archivo o en un documento especifico dentro de `docs/`.
- Al terminar cada bloque de trabajo, registrar:
  - Archivos cambiados.
  - Motivo del cambio.
  - Comandos ejecutados.
  - Resultado de tests/verificaciones.
  - Pendientes o riesgos.

## Bitacora de cambios

### 2026-07-06 - Base de tests en verde

Objetivo: dejar la suite `bundle exec rails test` en verde antes de construir nuevas
funciones (los dos fallos iniciales documentados arriba).

Archivos cambiados y motivo:

- `app/controllers/application_controller.rb`
  - En `ruta_segura_post_login` se agrego `return dashboard_path if current_usuario&.root?`
    como primera linea.
  - Motivo: para un usuario `root` sin `ModuloSistema` sembrados, `puede?` hace
    `return false unless modulo_sistema` y devuelve `false` antes de considerar que el
    usuario es root, por lo que la ruta caia en `login_path` y el login redirigia de vuelta
    a `/login`. El resto del diseno (`authorize_modulo!`, `permiso_efectivo`) ya trata a root
    como bypass total; esta ruta era la unica que no lo contemplaba. El dashboard es la
    landing natural de root, asi que el cambio es consistente y minimo.

- `test/models/permiso_test.rb`
  - Se reemplazo `Permiso.create!(...)` por `Permiso.find_or_create_by!(...)` con comentario.
  - Motivo: `ModuloSistema.create!` dispara `SincronizarPermisosModulo` (after_commit), que ya
    genera un `Permiso` para cada rol. El `create!` manual chocaba con la validacion de
    unicidad y lanzaba error antes de llegar a los asserts. `find_or_create_by!` respeta la
    sincronizacion automatica y mantiene la intencion del test (validar unicidad rol+modulo).

Comandos ejecutados:

```bash
source "$HOME/.rvm/scripts/rvm"; rvm use 3.3.8
bundle exec rails test
```

Nota de entorno: hay un shim de `rbenv` que intercepta `ruby`; es necesario cargar RVM y
`rvm use 3.3.8` antes de correr `bundle exec`.

Resultado de tests:

```text
34 runs, 126 assertions, 0 failures, 0 errors, 0 skips
```

Pendientes / riesgos:

- Ningun test cubre aun el caso de root que aterriza en dashboard sin modulos sembrados de
  forma explicita; el test de sesiones lo ejercita indirectamente. Podria agregarse un test
  unitario del helper si se considera necesario.

## Proximos pasos sugeridos

1. ~~Corregir o actualizar los dos tests fallidos para que reflejen el comportamiento esperado.~~ Hecho (2026-07-06).
2. Definir oficialmente si `master` debe ser la rama principal del proyecto o si se fusionara hacia `main`.
3. Revisar por que la rama `master` versiona carpetas de gems (`cache`, `gems`, `specifications`) y decidir si se mantienen o se limpian en una tarea separada.
4. Levantar la app localmente y revisar visualmente dashboard, login, usuarios, roles, permisos y cotizaciones.

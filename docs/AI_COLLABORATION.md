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

### 2026-07-06 - Dashboard alineado a referencia visual

Objetivo: revisar los cambios previos de Claude y ajustar el dashboard ejecutivo para que se
acerque a la imagen de referencia compartida por Allan, trabajando solamente sobre la rama
`allan_dev`.

Contexto de rama:

- Rama activa: `allan_dev`
- Se detectaron cambios sin commit de Claude en `DESIGN_GUIDELINES.md`,
  `app/assets/stylesheets/application.css`, `app/controllers/enterprise_controller.rb`,
  `app/helpers/enterprise_helper.rb`, `app/views/enterprise/dashboard.html.erb` y
  `app/views/shared/_kpi_card.html.erb`.
- No se hizo reset ni cambio de rama. Se trabajo encima de esos cambios.

Archivos cambiados y motivo:

- `app/views/enterprise/dashboard.html.erb`
  - Se marco el dashboard con `content_for :body_class, "dashboard-reference-shell"` para
    poder aplicar ajustes visuales especificos de la referencia sin afectar todo el sistema.

- `app/views/layouts/application.html.erb`
  - Se agrego soporte para clases de body por vista.

- `app/views/shared/_header.html.erb`
  - Se ajusto el buscador y los indicadores de notificaciones para parecerse al topbar de la
    referencia.

- `app/views/shared/_sidebar.html.erb`
  - Se agrego texto de marca fallback `Copenet` cuando no hay logo cargado.

- `app/controllers/application_controller.rb`
  - El item de dashboard usa icono `home`, como en la referencia.

- `app/helpers/enterprise_helper.rb`
  - Se agrego icono `home` y se conservaron los helpers SVG de graficas agregados por Claude.

- `app/assets/stylesheets/application.css`
  - Se agregaron overrides de `.dashboard-reference-shell` para sidebar compacto, topbar,
    KPIs, paneles, graficas, pendientes, estado de cartera, tendencia y accesos rapidos.
  - Se oculto el flash dentro del dashboard para que no rompa la composicion visual de la
    primera pantalla.

Comandos/verificaciones ejecutadas:

```bash
bundle exec rails runner 'puts "Rails boot OK #{Rails.version}"'
bundle exec rails test
```

Resultado:

```text
Rails boot OK 8.1.3
34 runs, 126 assertions, 0 failures, 0 errors, 0 skips
```

Verificacion visual:

- Se reviso en navegador local con viewport amplio.
- La composicion final muestra topbar, sidebar azul compacto, cinco KPIs, graficas, pendientes,
  estado de cartera, tendencia y dos filas de accesos rapidos dentro del primer viewport.

Pendientes / riesgos:

- La referencia es una imagen estatica; el resultado se ajusto visualmente por CSS y captura,
  pero puede requerir una pasada fina adicional si Allan exige coincidencia pixel-perfect.
- El puerto `3000` ya estaba ocupado por un servidor previo. Para revision visual se uso un
  servidor disponible en `localhost:3001`.

### 2026-07-06 - Pasada fina dashboard y switch claro/oscuro

Objetivo: hacer una pasada final de ajuste visual contra la referencia y corregir el switch de
tema claro/oscuro en el dashboard.

Archivos cambiados y motivo:

- `app/assets/stylesheets/application.css`
  - Se ajusto el control `.theme-toggle-button` para que tenga track y knob animado.
  - Se agregaron estilos `html.theme-dark .dashboard-reference-shell ...` para que el
    dashboard realmente cambie a modo oscuro y no se quede con colores fijos de la referencia
    clara.
  - Se refinaron proporciones del primer viewport: graficas, paneles y accesos rapidos.

Verificacion visual:

- Se probo el click del switch en navegador local.
- Estado observado: `theme-dark` cambia de `false` a `true` al activar y vuelve a `false` al
  desactivar.
- Se capturo el dashboard en modo claro y oscuro desde `localhost:3001/dashboard`.

Pendientes / riesgos:

- La UI queda alineada a la composicion de la imagen de referencia. Una coincidencia
  pixel-perfect absoluta dependeria de fuente/renderizado/browser exacto y de medir contra el
  archivo fuente en un flujo de comparacion visual dedicado.

### 2026-07-06 - Correccion de tamano util de graficas

Objetivo: corregir las graficas del dashboard porque la de tendencia quedaba demasiado pequena
dentro del panel y desaprovechaba el espacio disponible.

Archivos cambiados y motivo:

- `app/helpers/enterprise_helper.rb`
  - Se ampliaron los `viewBox` y coordenadas internas de `dashboard_barline_chart` y
    `dashboard_trend_chart`.
  - Motivo: el SVG de tendencia tenia un `viewBox` angosto (`620x200`) dentro de un panel muy
    ancho; al conservar proporcion, el navegador lo renderizaba como una grafica pequena
    centrada. El nuevo viewBox ancho permite que la grafica ocupe el panel.

- `app/assets/stylesheets/application.css`
  - Se aumento la altura util de `.chart-body`, `.dash-chart-bars` y `.dash-chart-trend`.
  - Se mantuvo verificado el modo claro/oscuro despues del cambio.

Verificacion visual:

- La grafica mensual quedo en aproximadamente `767x198`.
- La grafica de tendencia quedo en aproximadamente `999x126`.
- El switch de tema siguio funcionando (`false -> true -> false`) despues del ajuste.

### 2026-07-06 - Restauracion de menu lateral/header

Objetivo: corregir un alcance indebido del rediseño del dashboard que habia alterado el menu
lateral y el header global. El requerimiento era ajustar solo el dashboard, no cambiar la
navegacion principal.

Archivos cambiados y motivo:

- `app/views/shared/_header.html.erb`
  - Se restauro el buscador, notificacion y boton de mensajes al markup anterior.

- `app/views/shared/_sidebar.html.erb`
  - Se elimino el texto fallback agregado en la marca del sidebar.

- `app/controllers/application_controller.rb`
  - El item de Dashboard volvio a usar el icono `dashboard`.

- `app/assets/stylesheets/application.css`
  - Se removieron los overrides de `.dashboard-reference-shell` que tocaban `sidebar`,
    `topbar`, `icon-button`, `search`, `user-menu` y `theme-toggle-button`.
  - Los estilos del dashboard quedan limitados al contenido: KPIs, paneles, graficas,
    pendientes, cartera, tendencia y accesos rapidos.

Verificacion visual/funcional:

- Toggle del sidebar: ancho `278 -> 101 -> 278`, labels `block -> none -> block`.
- Toggle de seccion lateral: `aria-expanded false -> true`, subnav `display: flex`.

### 2026-07-06 - Ajustes finales de dashboard

Objetivo: refinar solamente el contenido del dashboard, sin tocar el menu lateral ni el
header global.

Cambios aplicados:

- `app/controllers/enterprise_controller.rb`
  - El titulo principal quedo como `Dashboard`.
  - Se retiro la descripcion secundaria del encabezado.
  - Los montos visibles del dashboard se cambiaron de dolares a quetzales (`Q`).
  - Se corrigio `Cobros aplicadas` a `Cobros aplicados`.

- `app/views/enterprise/dashboard.html.erb`
  - Las etiquetas de `Facturacion`, `Cobros` y `Utilidad` se subieron al encabezado de
    `Tendencia de facturacion`.
  - El titulo `Accesos rapidos` quedo dentro de una barra blanca/panel para integrarse
    con el resto del diseno.

- `app/views/shared/_kpi_card.html.erb`
  - El valor numerico de las KPI dejo de renderizarse como `<strong>`.

- `app/assets/stylesheets/application.css`
  - Las KPI superiores se centraron visualmente y sus valores bajaron de peso tipografico.
  - La grafica de tendencia aumento su altura util y mantiene soporte para modo oscuro.
  - Se agrego estilo oscuro para la nueva barra de `Accesos rapidos`.

- `app/helpers/enterprise_helper.rb`
  - Las escalas de las graficas financieras ahora muestran `Q`.
  - La grafica de tendencia aumento su `viewBox` vertical para verse mas grande.

### 2026-07-06 - Proporcion cartera y tendencia

Objetivo: ajustar las dos secciones inferiores del dashboard para que los graficos no se
vieran pequenos dentro de tarjetas grandes.

Cambios aplicados:

- `app/assets/stylesheets/application.css`
  - El donut de `Estado de cartera` aumento de tamano y la leyenda se compacto para
    darle mas espacio visual a la grafica.
  - La grafica de `Tendencia de facturacion` aumento ligeramente su altura util.

- `app/helpers/enterprise_helper.rb`
  - El `viewBox` horizontal de `dashboard_trend_chart` se amplio para que la grafica
    de lineas ocupe mejor el ancho de esquina a esquina dentro de su panel.

Verificacion visual:

- En `http://localhost:3001/dashboard`, el donut de cartera renderiza a `146x146`.
- La leyenda de cartera queda compacta a `360px` de ancho.
- La grafica de tendencia usa `1217px` de ancho y `188px` de alto dentro de su tarjeta.

### 2026-07-06 - Refuerzo visual del donut de cartera

Objetivo: mejorar aun mas la proporcion de `Estado de cartera`, ya que el donut todavia
se percibia pequeno dentro del panel.

Cambios aplicados:

- `app/assets/stylesheets/application.css`
  - El donut de cartera subio a `176x176`.
  - La leyenda se compacto a `314px` y se redujo ligeramente la tipografia de filas.

- `app/helpers/enterprise_helper.rb`
  - El anillo del donut se engroso (`stroke-width: 24`) para que tenga mas presencia.

Verificacion visual:

- En `http://localhost:3001/dashboard`, el panel de cartera mide `615x275`, el cuerpo
  `563x192`, el donut `176x176` y la leyenda `314x105`.

### 2026-07-06 - Alineacion de colores y porcentajes de cartera

Objetivo: corregir la sensacion de colores desfasados en `Estado de cartera`.

Cambios aplicados:

- `app/controllers/enterprise_controller.rb`
  - Se actualizaron los porcentajes para que coincidan con los montos usados por el
    donut: `41.3%`, `30.9%`, `27.8%`.
  - El total de cartera se ajusto a `Q233,200`, suma real de los tres segmentos.

Verificacion visual:

- En `http://localhost:3001/dashboard`, los colores del donut coinciden con la leyenda:
  verde `Cobro vigente`, azul `En gestion`, naranja `Vencida`.
  Los tres porcentajes ahora suman `100%`.

### 2026-07-06 - Logo e iconos del sidebar

Objetivo: reemplazar el isotipo generico del menu lateral por el logotipo de Copenet,
mostrar solo la `C` cuando el menu se colapsa y mejorar los iconos del menu.

Cambios aplicados:

- `app/assets/images/copenet-logo.png`
  - Se agrego el logo transparente de Copenet usado en el sidebar abierto.

- `app/views/shared/_sidebar.html.erb`
  - El header del sidebar ahora usa el logo Copenet dentro de una base blanca con bordes
    redondos.
  - Se agrego un monograma SVG `C` para el estado colapsado.
  - Los iconos de secciones usan `sidebar_icon(...)`.

- `app/views/shared/_sidebar_item.html.erb`
  - Los items del menu usan `sidebar_icon(...)`.

- `app/helpers/enterprise_helper.rb`
  - Se agrego `sidebar_icon`, un set de SVG lineales para navegacion.

- `app/assets/stylesheets/application.css`
  - El sidebar abierto muestra solo el logo completo.
  - El sidebar colapsado muestra solo la `C`.
  - El ancho colapsado subio a `104px` y los iconos del menu quedan a `24x24`.

Verificacion visual:

- En `http://localhost:3001/dashboard`, abierto: logo completo visible `170x45`, `C`
  oculta.
- Colapsado: logo completo oculto, `C` visible `44x44`, iconos SVG `24x24`.

### 2026-07-06 - Donut de cartera sin colores superpuestos

Objetivo: corregir el artefacto visual del donut de `Estado de cartera`, donde se veia
un color colado en la union superior por usar circulos SVG superpuestos.

Cambios aplicados:

- `app/helpers/enterprise_helper.rb`
  - `dashboard_donut_chart` dejo de renderizar segmentos como circulos con
    `stroke-dasharray`.
  - Ahora cada segmento se renderiza como un arco SVG independiente (`path`) con una
    separacion fina entre colores.

Verificacion visual:

- En `http://localhost:3001/dashboard`, el donut renderiza `3` paths independientes,
  `0` circles, stroke `24px`, y mantiene tamano `176x176`.

### 2026-07-06 - Alineacion de KPI superiores

Objetivo: mantener el icono de cada KPI superior a la izquierda, pero centrar el texto
y la informacion dentro del espacio restante de la tarjeta.

Cambios aplicados:

- `app/assets/stylesheets/application.css`
  - `.kpi-card-v2` cambio a grid de dos columnas: icono fijo `68px` y contenido flexible.
  - `.kpi-body` conserva texto centrado dentro de su propia columna.

Verificacion visual:

- En `http://localhost:3001/dashboard`, primera KPI: icono `68x68` a la izquierda,
  cuerpo de texto centrado en una columna de `229px`.

### 2026-07-06 - Logo sidebar sin fondo blanco

Objetivo: ajustar el comportamiento del logo del sidebar para que no use fondo blanco ni
cambie a monograma al colapsar; debe conservar el mismo logotipo y solo reducir tamano.

Cambios aplicados:

- `app/views/shared/_sidebar.html.erb`
  - Se elimino el monograma SVG `C`; el sidebar usa solamente `copenet-logo.png`.

- `app/assets/stylesheets/application.css`
  - El contenedor del logo quedo transparente, sin fondo blanco ni sombra.
  - En estado abierto el logo renderiza grande.
  - En estado colapsado el mismo logo se reduce.

Verificacion visual:

- En `http://localhost:3001/dashboard`, abierto: logo transparente `170x45`.
- Colapsado: mismo logo transparente `76x20`; no existe `.sidebar-brand-cmark`.

### 2026-07-06 - Auto-colapso del sidebar

Objetivo: hacer que el menu lateral se reduzca automaticamente cuando el usuario navega,
hace click fuera del menu o toca el logo.

Cambios aplicados:

- `app/javascript/controllers/shell_controller.js`
  - Se agrego escucha global de clicks durante `connect` y limpieza en `disconnect`.
  - En escritorio, el sidebar se colapsa y guarda `copenet-sidebar=collapsed` cuando:
    - El usuario hace click fuera del sidebar.
    - El usuario hace click en el logo.
    - El usuario hace click en un link de navegacion del sidebar.
  - En mobile, la misma logica cierra el sidebar flotante.
  - El boton de toggle queda excluido para no auto-cancelar su propio comportamiento.

Verificacion funcional:

- En `http://localhost:3001/dashboard`, click fuera del sidebar: `sidebar-collapsed=true`.
- Click en logo: `sidebar-collapsed=true`.
- Click en link `Dashboard`: `sidebar-collapsed=true` y URL permanece `/dashboard`.

### 2026-07-06 - Animacion de cierre del sidebar

Objetivo: suavizar el cambio visual al colapsar el menu lateral para que no se vea de
golpe.

Cambios aplicados:

- `app/assets/stylesheets/application.css`
  - Se aumento la transicion del sidebar a `260ms` con `cubic-bezier(0.4, 0, 0.2, 1)`.
  - Se agregaron transiciones al logo, labels, chevron, iconos, padding, gap y radios de
    los items.
  - Los labels ya no desaparecen con `display:none`; ahora se cierran con `opacity`,
    `max-width` y `transform`.

Verificacion funcional:

- En `http://localhost:3001/dashboard`, el sidebar conserva transiciones CSS `0.26s`.
- Estado abierto: sidebar `278px`, logo `170px`, label visible.
- Estado colapsado: sidebar `104px`, logo `76px`, label oculto con `opacity: 0`.

### 2026-07-06 - Suavizado adicional del cierre del sidebar

Objetivo: hacer que el cierre del sidebar no se perciba brusco aun despues de la primera
animacion.

Cambios aplicados:

- `app/assets/stylesheets/application.css`
  - La duracion principal subio a `420ms`.
  - Se cambio el easing a `cubic-bezier(0.22, 1, 0.36, 1)`.
  - El sidebar ahora usa `overflow: hidden` y `will-change` para ancho/flex-basis.
  - El footer ya no se oculta con `display:none`; ahora usa `opacity`, `max-height`,
    `padding` y `transform`.

Verificacion funcional:

- En `http://localhost:3001/dashboard`, el sidebar reporta transiciones `0.42s`.
- Footer queda `display:flex` y transiciona con `0.24s/0.42s`.
- Labels quedan `display:block` y transicionan con `0.24s/0.42s`.

Verificacion:

- `git diff --check` paso correctamente.
- Sintaxis Ruby OK en `EnterpriseController` y `EnterpriseHelper`.
- No hay cambios en `app/views/shared/_header.html.erb`,
  `app/views/shared/_sidebar.html.erb` ni `app/controllers/application_controller.rb`.
- La suite Rails no pudo ejecutarse en este entorno porque las gems nativas versionadas
  (`pg`, `puma`, `nokogiri`, entre otras) no tienen extensiones compiladas para Ruby 3.3.8.

### 2026-07-06 - Logo compacto y favicon Copenet

Objetivo: usar el nuevo icono cuadrado de Copenet cuando el sidebar esta colapsado y
como favicon del navegador.

Cambios aplicados:

- Se agrego `app/assets/images/copenet-icon.png` desde el PNG entregado por Allan.
- Se actualizo `public/icon.png` con el mismo PNG para favicon/PWA.
- `app/views/shared/_sidebar.html.erb` ahora renderiza logo completo y logo compacto.
- `app/assets/stylesheets/application.css` alterna ambos logos con opacidad durante el
  colapso del sidebar.
- `app/views/layouts/application.html.erb` apunta el favicon a `/icon.png?v=20260706`
  y ya no referencia el SVG anterior.

Verificacion funcional:

- En `http://localhost:3001/dashboard`, estado colapsado muestra
  `/assets/copenet-icon-*.png` con opacidad `1`.
- El logo completo queda con opacidad `0` en estado colapsado.
- El favicon activo reporta `/icon.png?v=20260706`.

### 2026-07-06 - Icono compacto transparente

Objetivo: reemplazar el icono compacto anterior por una version sin fondo, dejando solamente
la letra `C` blanca y el trazo azul sobre transparencia.

Cambios aplicados:

- `app/assets/images/copenet-icon.png` se regenero como PNG transparente.
- `public/icon.png` se actualizo con el mismo PNG transparente para favicon.
- `app/views/layouts/application.html.erb` actualiza el cache-buster del favicon a
  `/icon.png?v=20260706-transparent`.

Verificacion visual:

- El PNG ya no incluye cuadro oscuro de fondo.
- La marca visible queda compuesta por `C` blanca y trazo azul sobre fondo transparente.

### 2026-07-06 - Cierre de submenus al colapsar sidebar

Objetivo: al cerrar el menu lateral, cualquier submenu abierto debe cerrarse tambien para que
el sidebar colapsado muestre solo iconos de opciones principales.

Cambios aplicados:

- `app/javascript/controllers/shell_controller.js`
  - Se agrego `closeSidebarSections()` para remover `is-open` y actualizar
    `aria-expanded="false"`.
  - `toggleSidebar()`, `closeSidebar()` y `collapseSidebar()` cierran submenus al colapsar.
  - `toggleSection()` ignora aperturas cuando el sidebar ya esta colapsado.
- `app/assets/stylesheets/application.css`
  - `.app-body.sidebar-collapsed .sidebar-subnav` queda en `display: none` como respaldo visual.

Verificacion funcional:

- Antes de colapsar: `openSections: 1`, `visibleSubnavs: 1`.
- Despues de colapsar: `openSections: 0`, `expandedTriggers: 0`, `visibleSubnavs: 0`.
- Al tocar un trigger de submenu con sidebar colapsado: permanece en `0`.

### 2026-07-06 - Reescritura de guia visual

Objetivo: actualizar `DESIGN_GUIDELINES.md` para que el dashboard actual sea la referencia
visual oficial de toda la plataforma.

Cambios aplicados:

- Se reescribio el documento completo como guia de plataforma.
- Se documentaron patrones globales: layout, paleta, tipografia, sidebar, header, KPIs,
  graficas, badges, accesos rapidos, tablas, formularios, responsive y modo oscuro.
- Se aclaro que el dashboard actual es el patron base para futuras pantallas.
- Se incluyeron reglas concretas derivadas de los cambios recientes: montos en `Q`, graficas
  grandes, sidebar colapsado solo con iconos principales, logo compacto transparente y header
  global sin rediseños accidentales por pantalla.

Verificacion:

- `DESIGN_GUIDELINES.md` queda en 542 lineas.
- `git diff --check` paso correctamente.

### 2026-07-06 - Apertura de submenus desde sidebar colapsado

Objetivo: cuando el usuario presiona un modulo padre del sidebar que tiene submenu
(`Administracion`, por ejemplo) estando el sidebar colapsado, el sidebar debe expandirse y
mostrar ese submenu abierto.

Cambios aplicados:

- `app/javascript/controllers/shell_controller.js`
  - Se agrego `expandSidebar()` para abrir el sidebar en desktop y mostrarlo en mobile.
  - `toggleSection()` ahora, si el sidebar esta colapsado, expande el sidebar, cierra otros
    submenus y abre el submenu del modulo presionado.

Verificacion funcional:

- En `http://localhost:3001/companies`, al tocar un trigger de submenu con sidebar colapsado:
  `collapsed: false`, `sidebarWidth: 278px`, `openSections: 1`, `visibleSubnavs: 1`.

### 2026-07-06 - Logo del sidebar navega al dashboard

Objetivo: permitir que el usuario vuelva al dashboard presionando el logo de Copenet en el
sidebar.

Cambios aplicados:

- `app/views/shared/_sidebar.html.erb`
  - El logo ahora es `link_to dashboard_path` conservando la clase `.sidebar-brand-logo`.
- `app/assets/stylesheets/application.css`
  - `.sidebar-brand-logo` mantiene `color: inherit` y `text-decoration: none` para no mostrar
    estilos visuales de enlace.

Verificacion funcional:

- En `http://localhost:3001/companies`, `.sidebar-brand-logo` renderiza como `<a href="/dashboard">`.
- Al hacer click en el logo, navega a `http://localhost:3001/dashboard`.

### 2026-07-06 - Iconos SVG para acciones de tabla

Objetivo: reemplazar acciones compactas de tabla con texto (`Ver`, `Editar`, `Configurar`,
`Eliminar`) por iconos SVG consistentes en toda la plataforma.

Cambios aplicados:

- `app/helpers/enterprise_helper.rb`
  - Se agregaron iconos `eye`, `pencil` y `trash`.
  - Se agregaron helpers `table_action_link` y `table_action_button`.
- Vistas de tablas actualizadas:
  - Empresas, monedas, roles, modulos del sistema, clientes, usuarios, productos/servicios y
    cotizaciones.
- `app/assets/stylesheets/application.css`
  - Se agrego estilo compacto `.table-action-icon` con fondo pastel, hover y color semantico.

Verificacion funcional:

- En `http://localhost:3001/companies`, la primera fila muestra 4 acciones SVG con
  `aria-label`: `Ver`, `Editar`, `Configurar`, `Eliminar`, sin texto visible.
- En `http://localhost:3001/monedas`, el boton de eliminar sigue renderizando como `<button>`
  con `_method=delete`.

Actualizacion:

- La accion compacta `Expediente` en la tabla de clientes ahora usa icono SVG de carpeta.
- En `http://localhost:3001/clientes`, `.table-action-expediente` renderiza sin texto visible,
  con `aria-label="Expediente"` y `fill: none`.

### 2026-07-06 - Rediseño del primer paso del wizard de empresa

Objetivo: cambiar unicamente el formulario del primer paso del wizard de crear/editar empresa
para acercarlo a la referencia visual entregada, sin rediseñar el resto de la pantalla ni las
otras pestañas.

Resguardo previo:

- Antes de editar el wizard se creo el commit `da9b43e` (`Ajusta navegacion lateral e iconos de acciones`).
  Ese commit funciona como punto de retorno si se necesita deshacer esta intervencion.

Cambios aplicados:

- `app/views/companies/_form_tabs.html.erb`
  - El panel `general` ahora usa una composicion por tarjetas: Datos Generales, Contacto,
    Identidad Visual, Direccion, Estado y Logo Corporativo.
  - Se conservaron los campos existentes del modelo dentro del primer paso.
- `app/assets/stylesheets/application.css`
  - Se agregaron estilos acotados a `.company-general-wizard` para cards blancas, bordes suaves,
    inputs altos, select con flecha, controles visuales de color y dropzone de logo.
  - Se agregaron reglas responsive para que el formulario no se comprima en anchos menores.
- `app/helpers/enterprise_helper.rb`
  - Se agregaron iconos SVG `map-pin`, `bar-chart`, `image` y `upload` para las nuevas tarjetas.

Verificacion:

- `ruby -c app/helpers/enterprise_helper.rb` paso correctamente.
- `git diff --check` paso correctamente.
- La sintaxis ERB de `app/views/companies/_form_tabs.html.erb` compilo correctamente.
- El servidor local responde en `/companies/new` con redireccion `302`; la conexion del navegador
  interno quedo intermitente y no permitio completar una captura visual automatizada en esta pasada.

Actualizacion:

- El boton `Personalizar` de cada color ahora abre un selector nativo de color.
- Al elegir un color o escribir un HEX valido, se actualizan en vivo la barra, el swatch y el campo
  enviado al backend.
- Si el HEX escrito no es valido, el input queda marcado visualmente sin alterar el ultimo color valido.
- La tuerca del boton se cambio por un SVG outline mas limpio y consistente con las acciones de tabla.
- La barra de color se hizo mas delgada y ahora funciona como slider: al arrastrar el circulo
  interior hacia los extremos se genera una variante mas clara u oscura del color base.
- El circulo del slider tambien responde con teclado usando flechas; `Shift` acelera el movimiento.
- Se retiro la tarjeta `Estado` del primer paso: al crear una empresa siempre se fuerza como
  `Activa`.
- En edicion, el control de estado se movio al encabezado `Informacion General` como checkbox
  `Inactiva`, alineado al extremo derecho.
- Al marcar `Inactiva`, la empresa guarda `active=false`, `status="Inactiva"` y sus productos o
  servicios asociados pasan a `activo=false`, `estado_catalogo="Inactivo"`.
- El formulario de productos/servicios ahora solo ofrece empresas activas para nuevas asociaciones.
- Al crear o actualizar una empresa, el sistema redirige al listado de empresas (`companies_path`)
  para volver directamente a la tabla de registros.
- La accion `Ver` del listado de empresas mantiene su destino a `company_path`, pero la pantalla de
  detalle se rediseño como vista de registro: encabezado ejecutivo, acciones con iconos, resumen de
  datos clave y pestañas de detalle con estilo consistente.
- Se retiro el resumen de cards del detalle de empresa porque duplicaba informacion ya disponible en
  las pestañas del registro.
- El bloque `Logo Corporativo` se amplio para ocupar el espacio que antes usaba `Estado`.
- La pantalla de edicion de empresa se limpio para dejar solo el titulo principal `Editar empresa`.
- Se removieron el texto descriptivo superior, el boton `Ver detalle`, el badge `Edicion` y la
  descripcion del panel `Configuracion de la empresa`.
- Los botones `Guardar` y `Cancelar` se movieron al encabezado del panel de configuracion.
- Se amplio el encabezado de `Configuracion de la empresa` para que los botones no se sobrepongan
  con la fila de pestañas.
- La pestaña `Fel / Infile` ahora tiene mayor separacion bajo el encabezado, mas aire entre filas
  y campos ligeramente mas altos para evitar que el formulario se vea amontonado.
- El encabezado de `Fel / Infile` se alineo al patron visual de las demas pestañas, usando tarjeta
  blanca, icono, titulo y descripcion con tipografia consistente.
- La pestaña `Branding y contacto comercial` se rediseño en bloques: contacto comercial, estilo de
  cotizacion, texto inferior del PDF y logo para cotizacion.
- El titulo y descripcion de `Branding y contacto comercial` quedaron dentro del primer bloque blanco
  para mantener consistencia visual con el resto del wizard.
- Los colores de cotizacion ahora reutilizan la misma estructura visual del bloque `Identidad
  visual` en `Informacion general`, con slider, HEX, swatch y boton `Personalizar`.
- En cotizacion, los dos controles de color se distribuyen de lado a lado con mayor separacion
  horizontal para ocupar mejor toda la seccion.
- Se hizo mas especifico el grid de colores de cotizacion para evitar que herede la distribucion
  de tres columnas del bloque general.
- El logo para cotizacion ahora usa la misma estructura visual del logo corporativo, con preview,
  reglas de archivo y boton `Subir logo`.
- La pestaña `Plantilla del documento comercial` se rediseño en tres bloques: identidad del
  documento, contenido del documento y firma comercial, eliminando la vista previa de colores que
  no correspondia al flujo de esta pestaña.
- El titulo y descripcion de `Plantilla del documento comercial` quedaron dentro del primer bloque
  blanco para mantener consistencia con las demas pestañas del wizard.
- El texto visible del wizard de empresa se normalizo a estilo oracion para reducir carga visual.
- El formulario de empresa ahora fuerza `multipart` para que los logos se adjunten correctamente.
- Se agrego preview inmediato para `Logo corporativo` y `Logo para cotizacion` al seleccionar imagen.
- Se retiro el aviso automatico de login `Debes iniciar sesion para continuar` para mantener la
  pantalla inicial limpia; los errores reales de credenciales invalidas se conservan.
- Se optimizo la autorizacion global para usuarios no root: los modulos activos se cachean por
  request, los permisos efectivos se memoizan por usuario/modulo/accion y las asociaciones de
  permisos se precargan una sola vez cuando hacen falta.
- Se redujeron consultas extra en listados: `Roles` usa la asociacion precargada para el conteo de
  usuarios, `Usuarios` evita `limit` por fila sobre roles y `Cotizaciones` precarga la moneda del
  producto asociado.
- Prueba local autenticada en desarrollo despues de calentamiento: dashboard, companias, clientes,
  monedas, productos/servicios, cotizaciones, usuarios y roles respondieron entre 27 ms y 46 ms
  aproximadamente en `localhost:3001`.
- La grafica `Resumen financiero mensual` del dashboard ya no depende de datos hardcodeados:
  consulta `cotizaciones` y `cotizacion_detalles` para ingresos, costos y utilidad. Los botones
  `Mes actual`, `6 meses` y `12 meses` consumen `/dashboard/finance` bajo demanda y redibujan la
  grafica en el navegador sin recargar la pantalla.

## Proximos pasos sugeridos

1. ~~Corregir o actualizar los dos tests fallidos para que reflejen el comportamiento esperado.~~ Hecho (2026-07-06).
2. Definir oficialmente si `master` debe ser la rama principal del proyecto o si se fusionara hacia `main`.
3. Revisar por que la rama `master` versiona carpetas de gems (`cache`, `gems`, `specifications`) y decidir si se mantienen o se limpian en una tarea separada.
4. Levantar la app localmente y revisar visualmente dashboard, login, usuarios, roles, permisos y cotizaciones.

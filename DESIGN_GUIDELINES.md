# Copenet Enterprise
## Guia visual oficial de plataforma

Ultima actualizacion: 2026-07-10

Este documento es la referencia obligatoria para cualquier IA, programador o disenador que modifique la interfaz de Copenet Enterprise. Antes de tocar una pantalla, se debe revisar este archivo y comparar el resultado contra los patrones ya aplicados en Dashboard, Companias, Usuarios, Roles y permisos, Monedas, Clientes, Parametros y Generar cotizacion.

La plataforma debe sentirse como un SaaS financiero y operativo: clara, ejecutiva, compacta, confiable y consistente. No se aceptan pantallas con estilo Bootstrap generico, formularios interminables, tablas antiguas, acciones en texto plano, iconos mezclados ni composiciones que parezcan de otro producto.

---

# Principios base

1. La informacion manda.
   La UI debe ayudar a leer, comparar, decidir y actuar rapido.

2. Consistencia antes que inventar.
   Si ya existe un patron en Companias, Usuarios, Roles, Monedas, Clientes, Parametros o Cotizacion, se reutiliza.

3. Densidad operativa.
   El sistema es una herramienta de trabajo. Debe aprovechar el ancho disponible sin verse saturado.

4. Pantallas limpias.
   Evitar subtitulos largos, textos duplicados, etiquetas innecesarias y secciones que no aporten al flujo actual.

5. Acciones claras.
   Las acciones principales van visibles arriba o en la linea del titulo de la seccion, no escondidas al final.

6. Un lenguaje visual.
   Sidebar, header, tablas, formularios, wizards, badges, iconos y botones deben verse como parte del mismo sistema.

---

# Estructura global

La plataforma tiene tres zonas fijas:

1. Sidebar izquierdo.
   Navy profundo, iconos SVG, logo Copenet y comportamiento colapsable.

2. Header superior.
   Claro, compacto, con boton de menu, buscador global, acciones rapidas, switch claro/oscuro y menu de usuario.

3. Area de contenido.
   Fondo gris azulado muy claro, paneles blancos, bordes tenues y grillas compactas.

El contenido debe iniciar cerca del header. No usar heroes, banners decorativos ni bloques grandes vacios.

---

# Paleta y color

## Fondos

- App: gris azulado muy claro.
- Paneles y cards: blanco o casi blanco.
- Bordes: azul/gris tenue.
- Sidebar: navy profundo con gradiente sutil.

## Color principal

Azul Copenet / royal blue.

Usos:

- Botones primarios.
- Links destacados.
- Foco de inputs.
- Serie principal de graficas.
- Estados informativos.
- Elementos activos.

## Colores semanticos

- Verde: exito, activo, cobros, crecimiento, revision aprobada.
- Naranja: atencion, por vencer, advertencia.
- Rojo: alerta, vencido, critico, inactivar.
- Morado: utilidad o metricas secundarias.
- Gris/azul grisaceo: informacion secundaria, divisores y ejes.

Los fondos semanticos deben ser pastel. El color intenso se usa en texto, icono o linea.

## Selectores de color

Todo campo de color editable debe usar el patron de Companias y Parametros:

- Barra horizontal delgada con gradiente del color seleccionado.
- Handle circular movible.
- Swatch cuadrado.
- Input hexadecimal.
- Boton `Personalizar` con icono SVG.
- Input nativo `type=color` oculto para abrir selector del sistema.

No usar campos de color como simples inputs sueltos cuando forman parte de una configuracion visual.

---

# Tipografia

La familia tipografica actual es `Montserrat`. Mantenerla en toda la plataforma salvo migracion global deliberada.

Reglas:

- Titulos de pantalla: mismo tamano y peso en todos los modulos.
- Titulos de tablas/listados: mismo tamano que Companias.
- Titulos internos de card: compactos, oscuros y con peso medio-alto.
- Labels: pequenos, claros, color azul/gris.
- Texto ingresado en campos: peso normal, no negrita.
- No usar todo en mayusculas para secciones completas.
- Solo mayuscula inicial en frases y parrafos.
- No poner todo en negrita; usar peso visual con moderacion.

Los textos auxiliares deben ser breves. Si un subtitulo duplica el titulo o explica algo obvio, se elimina.

---

# Iconografia

Usar iconos SVG lineales con `currentColor`.

No usar:

- Emojis.
- Iconos rasterizados para acciones.
- Fuentes de iconos.
- Iconos Bootstrap mezclados con otro estilo.
- Acciones en texto plano cuando existe icono.

Acciones oficiales:

- Ver: ojo.
- Editar: lapiz.
- Configurar: tuerca, solo donde realmente aplique.
- Expediente: carpeta.
- Eliminar: no se usa en entidades operativas; preferir inactivar.
- Inactivar: checkbox o accion confirmada segun flujo.

Los iconos en cards, tabs y listas viven dentro de un circulo/chip pastel cuando el patron lo requiera.

---

# Sidebar

El sidebar es global y no debe alterarse desde pantallas internas.

## Abierto

- Logo Copenet horizontal.
- Items con icono SVG y texto.
- Submenus solo en estado abierto.
- Espaciado compacto y legible.

## Colapsado

- Solo iconos principales.
- Logo reducido.
- Submenus cerrados automaticamente.
- No mostrar flechas de submenu.
- No compactar iconos hasta que se vean apretados.

## Comportamiento

- Debe sentirse rapido.
- No usar animaciones lentas.
- Al navegar a otra pantalla o tocar fuera, puede colapsar segun la logica global.
- Al colapsar, cerrar submenus y dejar `aria-expanded="false"`.
- El logo debe llevar al Dashboard.

---

# Header y busqueda global

El header debe ser constante en toda la plataforma.

Elementos:

- Boton de menu.
- Buscador global.
- Notificaciones y mensajes con badge.
- Switch claro/oscuro funcional.
- Perfil de usuario con avatar, nombre, correo y chevron.

La busqueda superior debe permitir encontrar modulos como Empresas, Companias, Usuarios, Clientes, Monedas, Roles, Cobros, Costos, Facturacion, Contratos, Parametros, etc. Al presionar Enter debe navegar a la seleccion cuando exista coincidencia.

No convertir el header en hero ni cambiarlo desde modulos internos.

---

# Layout de pantalla

Las pantallas de administracion deben seguir esta estructura:

1. No usar titulo grande externo cuando el listado o formulario ya tiene encabezado propio.
2. El panel principal contiene titulo de seccion y acciones alineadas a la derecha.
3. Filtros van dentro de un panel blanco compacto.
4. La tabla/listado va en un panel blanco con borde tenue.
5. Paginacion abajo a la derecha.

No usar etiquetas de conteo tipo `1 registro` si no aportan. No usar encabezados como `Administracion` encima de cada pantalla.

---

# Tablas y listados

La referencia visual es Companias, Usuarios y Roles.

Toda tabla/listado debe incluir cuando aplique:

- Buscador.
- Filtros compactos.
- Tabla blanca con borde tenue.
- Encabezados pequenos y claros.
- Filas respirables pero no enormes.
- Badges de estado.
- Acciones con iconos SVG.
- Paginacion con 10 resultados por defecto y selector 20, 50, 100.
- Navegacion entre paginas.

Reglas:

- Los botones y campos deben tener el mismo diseno que Companias.
- Las columnas deben alinear encabezado y contenido.
- No usar acciones en texto plano como `Ver Editar Eliminar`.
- No usar boton Exportar salvo que sea necesario y aprobado para esa pantalla.
- No usar eliminar en entidades operativas; se inactiva desde editar con confirmacion cuando aplique.
- Paginacion y selector de cantidad van a la derecha, junto a la navegacion.

---

# Pantallas de detalle

La referencia es el detalle de Compania.

Estructura:

- Hero/panel superior con avatar/logo o iniciales a la izquierda.
- Nombre principal alineado verticalmente con la imagen.
- Badges en la misma linea del nombre cuando el espacio lo permite.
- Acciones arriba a la derecha en orden: Volver, Editar.
- No mostrar boton Configurar si duplica editar.
- No mostrar texto `Registro de compania` u otros labels redundantes.
- Informacion en cards compactas, alineadas y sin montarse.

Las cards duplicadas que repiten informacion visible en el detalle principal deben eliminarse.

---

# Formularios crear/editar

Los formularios no deben ser listas verticales largas. Deben usar el patron de wizard/tabs aplicado en Companias, Parametros y Generar cotizacion.

## Patron obligatorio

1. Formulario con `data-controller="tabs"` cuando tiene varias secciones.
2. Panel superior `product-tabs-panel` con:
   - Titulo del flujo.
   - Botones Guardar y Cancelar a la derecha.
   - Cards/tabs de navegacion.
3. Cada seccion es un `module-tab-panel`.
4. Solo una seccion visible a la vez.
5. Campos agrupados en `company-wizard-card`.
6. Cards con icono, titulo y descripcion corta.

## Botones

- Crear: boton principal puede decir `Guardar`, `Crear` o nombre de accion especifica.
- Editar: boton principal debe decir `Guardar`.
- Cancelar siempre regresa al listado de registros, salvo flujo especial justificado.
- Evitar botones duplicados arriba y abajo.

## Texto

- Quitar textos como `Edicion`, `Completa el registro...` si agregan ruido.
- No repetir el titulo de la pantalla dentro del formulario.
- No usar mayusculas completas para labels o secciones.

---

# Wizards y tabs de seccion

Los wizards son el patron oficial para formularios largos.

Ejemplos actuales:

- Companias: General, Fel / Infile, Cotizacion, Documento.
- Parametros: Identidad, Login, PDF, Colores, Logos, Vista previa.
- Generar cotizacion: Cliente, Condiciones, Items, Notas, Resumen economico.
- Usuarios/Roles: permisos por pestanas de modulo.

Reglas:

- Las tabs son cards compactas con icono, titulo y descripcion corta.
- La tab activa tiene fondo azul pastel y borde resaltado.
- No usar tabs Bootstrap tradicionales.
- No mostrar contenido de secciones inactivas debajo del wizard.
- Si hay un resumen, debe ser la ultima pestana, no un bloque lateral fijo.
- El contenido que sirva solo para consulta debe mostrarse en modo ver, no durante crear/editar.

---

# Permisos por modulo

Usuarios y Roles deben manejar permisos por pestanas de modulo:

- Administracion.
- General.
- Cobros.
- Costos.
- Facturacion.
- Contratos.
- Reportes.
- Otros modulos existentes.

Cada pestana contiene su tabla de permisos y un checkbox `Todos` para marcar/desmarcar acciones del modulo.

Reglas:

- El rol Root tiene todos los permisos por defecto.
- Root no necesita otorgamiento manual de permisos.
- En usuarios, seleccionar un rol debe cargar los permisos parametrizados en Roles y permisos.
- Los permisos no se guardan hasta presionar Guardar.

---

# Logos e imagenes

El patron oficial de carga de imagenes es el de Companias y Parametros:

- Dropzone con borde punteado tenue.
- Preview a la izquierda.
- Texto de restricciones a la derecha.
- Boton `Subir logo` con icono upload.
- Vista previa inmediata al seleccionar archivo.
- Checkbox de eliminar solo si ya existe imagen.

No usar file inputs crudos visibles.

---

# Dashboard

El dashboard es referencia visual para metricas y graficas, pero no debe tener elementos innecesarios.

Estado actual deseado:

- Sin titulo externo innecesario si el contenido ya inicia con informacion.
- Sin selector de mes ni boton de actualizar si no se requiere.
- Sin accesos rapidos si la busqueda global ya cumple esa funcion.
- KPIs arriba.
- Resumen financiero.
- Pendientes criticos.
- Estado de cartera.
- Tendencia de facturacion.

## KPIs

- Icono a la izquierda dentro de circulo pastel.
- Informacion centrada visualmente en el resto de la card.
- Valores monetarios en quetzales (`Q254,900`).
- Valores no excesivamente negritos.
- Delta con color semantico.

## Graficas

- Grandes, legibles y proporcionadas.
- No usar graficas pequenas dentro de paneles grandes.
- Leyendas cerca del titulo.
- Resumenes de serie como chips pastel arriba a la derecha.
- Donut con colores exactamente alineados a su leyenda.

---

# Badges y estados

Los badges son pildoras suaves:

- Fondo pastel.
- Texto en tono intenso.
- Peso medio.
- Tamano compacto.

Mapa:

- Verde: Activo, Aprobado, Revision, Completado.
- Azul: Pendiente, Informativo, Root.
- Naranja: Atencion, Por vencer.
- Rojo: Alerta, Vencido, Inactivo.
- Morado: Secundario o utilidad.

---

# Modales de confirmacion

Usar modal cuando una accion tenga impacto operativo:

- Inactivar compania.
- Inactivar usuario.
- Cambios irreversibles o sensibles.

No usar `confirm()` del navegador para flujos principales si ya existe patron de modal.

La eliminacion fisica no debe exponerse en UI para registros operativos salvo una decision explicita de producto.

---

# Modo claro y oscuro

Toda pantalla debe respetar ambos modos.

Reglas:

- Evitar colores hardcodeados sin equivalente oscuro.
- Usar variables globales cuando existan.
- Mantener contraste.
- Inputs, tablas, tabs, badges y graficas deben verse legibles.
- El switch claro/oscuro debe funcionar y animar.

---

# Responsive

Desktop:

- Usar grillas amplias.
- Tablas completas.
- Cards en 2, 3, 4 o 5 columnas segun contenido.

Tablet:

- Reducir columnas.
- Mantener tabs utilizables.
- Sidebar puede colapsar.

Mobile:

- Una columna.
- Botones pueden envolver sin montarse.
- Paginacion debe seguir usable.
- Inputs y cards no deben desbordarse.

---

# Animacion e interaccion

El sistema debe sentirse rapido.

Usar transiciones discretas para:

- Hover de cards y botones.
- Cambio de tabs.
- Switch claro/oscuro.
- Menus pequenos.

Evitar:

- Animaciones lentas en sidebar.
- Cambios bruscos de layout.
- Transiciones llamativas o decorativas.

---

# Componentes que se deben reutilizar

Antes de crear clases nuevas revisar:

- `module-tabs`
- `module-tab`
- `module-tab-panel`
- `product-tabs-panel`
- `company-general-wizard`
- `company-wizard-card`
- `company-card-heading`
- `company-color-control`
- `company-logo-dropzone`
- `data-controller="tabs"`
- `data-controller="company-color"`
- `data-controller="company-logo"`
- `table_action_link`
- `table_action_button`
- `badge`
- `ui-button`

Crear un componente nuevo solo si el patron existente no resuelve el caso.

---

# Checklist antes de entregar

- La pantalla parece parte de Copenet Enterprise.
- Usa el mismo tamano de titulos que Companias/Usuarios/Roles.
- No hay titulo externo duplicado.
- No hay textos innecesarios o subtitulos largos.
- Los botones estan en la ubicacion estandar.
- Las acciones son iconos SVG.
- No hay eliminar cuando debe ser inactivar.
- Los formularios largos usan wizard/tabs.
- Solo una seccion del wizard esta visible a la vez.
- Colores editables usan el selector oficial.
- Logos usan dropzone con vista previa.
- Tablas tienen filtros y paginacion cuando aplica.
- Paginacion esta a la derecha.
- Modo oscuro no se rompe.
- Mobile no monta textos ni botones.
- `git diff --check` no reporta errores.

Si una IA o programador no puede justificar por que se aparto de estas reglas, el cambio debe corregirse antes de aceptarse.

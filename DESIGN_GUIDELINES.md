# Copenet Enterprise
## Guia Visual Oficial de Plataforma

---

# Objetivo

Copenet Enterprise debe sentirse como una plataforma SaaS financiera moderna: ejecutiva,
clara, densa y confiable. El dashboard actual es la referencia visual principal para el resto
del sistema.

Cada pantalla nueva o modificada debe parecer parte del mismo producto:

- Sidebar azul marino oscuro.
- Header claro, compacto y funcional.
- Contenido sobre fondo gris azulado muy claro.
- Cards blancas con borde tenue.
- Iconos SVG lineales.
- Graficas grandes, legibles y bien proporcionadas.
- Informacion densa pero respirable.

No se debe volver a estilos tipo Bootstrap basico, tablas antiguas, formularios verticales
interminables, colores saturados ni espacios vacios sin proposito.

---

# Principios Visuales

1. La informacion manda.
   La pantalla debe permitir leer, comparar y actuar rapidamente.

2. Densidad alta, no saturacion.
   Usar el espacio disponible de forma eficiente, con gutters consistentes y bloques bien
   proporcionados.

3. Diseño ejecutivo.
   La UI debe verse sobria, financiera y comercial, no como landing page ni como maqueta
   decorativa.

4. Componentes consistentes.
   Reutilizar patrones del dashboard: KPIs, paneles, badges, graficas, listas y accesos
   rapidos.

5. Nada debe parecer improvisado.
   Si una pantalla se ve diferente al dashboard sin una razon funcional clara, debe ajustarse.

---

# Layout General

La plataforma usa siempre tres zonas:

1. Sidebar lateral izquierdo.
   Azul marino oscuro, colapsable, con iconos principales y logo de Copenet.

2. Header superior.
   Claro, compacto, con buscador, acciones rapidas, switch claro/oscuro y usuario.

3. Area de contenido.
   Fondo gris claro, ancho completo disponible y composicion en grillas de cards.

El contenido debe iniciar cerca del header, sin separaciones exageradas. Las pantallas deben
aprovechar el ancho completo de trabajo.

---

# Paleta

Usar una paleta clara, financiera y poco saturada.

## Fondos

- Fondo de app: gris azulado muy claro.
- Cards y paneles: blanco puro o casi blanco.
- Bordes: azul/gris muy tenue.
- Sidebar: navy profundo con gradiente sutil.

## Color Primario

Azul Copenet / royal blue.

Usos:

- Acciones principales.
- Links destacados.
- Serie principal de graficas.
- Estados informativos.
- Item activo o resaltado.

## Colores Semanticos

- Verde: cobros, exito, positivo, crecimiento.
- Naranja/ambar: advertencia, atencion, cartera vencida.
- Rojo: alerta, critico, vencido, variacion negativa.
- Morado: utilidad, metricas secundarias, apoyo visual.
- Gris/azul grisaceo: texto secundario, ejes, divisores y elementos neutros.

Todos los tonos semanticos deben usarse en version pastel para fondos y en color intenso solo
para texto, icono o linea.

---

# Tipografia

La plataforma usa una sola familia tipografica. Actualmente el layout carga `Montserrat`; toda
pantalla debe respetar esa familia salvo que se haga una migracion global deliberada.

Jerarquia:

- H1 de pantalla: grande, oscuro, peso alto.
- H2/H3 de card: compacto, oscuro, peso alto.
- Labels: pequeños, peso medio, color azul/gris.
- Valores KPI: grandes, legibles, peso medio-alto, no excesivamente pesados.
- Texto auxiliar: pequeño, color gris/azul.

Reglas:

- No usar textos enormes dentro de cards compactas.
- No poner todo en negrita.
- Los numeros importantes deben verse claros, pero no pesados ni agresivos.
- Descripciones largas solo cuando aporten valor. En dashboard se prefiere titulo limpio sin
  subtitulo innecesario.

---

# Iconografia

Usar iconos SVG lineales, consistentes y con `currentColor`.

No usar:

- Emojis.
- Fuentes de iconos.
- Iconos rasterizados para acciones o modulos.
- Iconografia Bootstrap si rompe el estilo lineal.

Usos esperados:

- Sidebar.
- Header.
- KPIs.
- Accesos rapidos.
- Listas de pendientes.
- Botones.
- Tabs.
- Estados y badges cuando aplique.

En KPIs, accesos rapidos y listas, el icono debe vivir dentro de un circulo o chip pastel del
tono correspondiente.

---

# Sidebar

El sidebar es un elemento global del producto y no debe rediseñarse desde pantallas internas.

## Estado abierto

- Fondo navy profundo.
- Logo horizontal de Copenet arriba.
- Items con icono SVG a la izquierda y texto a la derecha.
- Submenus permitidos solo en estado abierto.
- Espaciado vertical compacto pero legible.

## Estado colapsado

- Ancho reducido.
- Solo iconos principales visibles.
- Logo compacto transparente de Copenet arriba.
- Submenus cerrados automaticamente.
- Si se intenta tocar un item con submenu mientras esta colapsado, no debe abrir children.

## Comportamiento

- El cierre debe ser suave, no brusco.
- Al hacer click fuera del sidebar, en el logo o al navegar a otra pantalla, el sidebar puede
  colapsarse segun la logica actual.
- Al colapsar, cualquier submenu abierto debe cerrarse y dejar `aria-expanded="false"`.
- En mobile, el sidebar funciona como panel/hamburguesa.

---

# Header

El header debe ser claro, compacto y constante en toda la plataforma.

Elementos esperados:

1. Boton de menu/sidebar.
2. Buscador ancho con icono.
3. Notificaciones con badge.
4. Mensajes con badge.
5. Accesos rapidos o grid.
6. Switch claro/oscuro con animacion.
7. Usuario con avatar, nombre, correo y chevron.

Reglas:

- No ocupar demasiada altura.
- No convertirlo en hero ni en bloque decorativo.
- El switch claro/oscuro debe funcionar y animarse.
- Mantener el header global fuera de cambios especificos de una pantalla.

---

# Encabezado de Pantalla

Cada pantalla inicia con una fila superior clara:

- Titulo principal a la izquierda.
- Acciones principales a la derecha.
- Subtitulo solo si realmente ayuda a entender la pantalla.

En el dashboard el titulo debe ser simplemente `Dashboard`, sin descripcion secundaria.

Acciones tipicas:

- Selector de periodo.
- Actualizar datos.
- Nuevo registro.
- Exportar.
- Configurar.
- Guardar.

Las acciones principales deben estar arriba, no escondidas al final.

---

# Cards y Paneles

Las cards son la unidad base de la plataforma.

Estilo:

- Fondo blanco.
- Radio moderado, aproximadamente 8 a 12px.
- Borde tenue.
- Sombra muy suave o ninguna si el borde ya define el panel.
- Padding compacto y consistente.
- Alturas proporcionadas al contenido.

Reglas:

- No meter cards dentro de cards.
- No dejar paneles vacios o con graficas diminutas.
- El titulo de card va arriba, con controles a la derecha si aplica.
- Si un panel contiene grafica, la grafica debe ocupar la mayor parte util del panel.

---

# KPIs

Los KPIs del dashboard son el patron oficial.

Cada KPI debe contener:

1. Icono a la izquierda dentro de un circulo pastel.
2. Texto/informacion centrada visualmente dentro del resto de la card.
3. Label compacto.
4. Valor en quetzales cuando sea dinero: `Q254,900`.
5. Delta con flecha y color semantico.
6. Texto comparativo corto: `vs abril 2024`.

Reglas:

- Los valores no deben verse excesivamente negritos.
- Los iconos permanecen alineados a la izquierda.
- El texto principal se centra dentro de la zona disponible.
- Usar entre 4 y 6 KPIs por fila en desktop.
- En mobile, reacomodar a menos columnas.

---

# Graficas

Las graficas deben ser utiles, grandes y legibles. No se aceptan graficas pequeñas dentro de
paneles grandes.

Tipos oficiales:

- Barras comparativas con linea superpuesta.
- Donut con leyenda lateral.
- Lineas multiples para tendencias.

Reglas:

- Toda grafica vive en una card/panel con titulo.
- La leyenda debe estar cerca del titulo o encima de la grafica.
- Ejes y grillas en gris tenue.
- Colores consistentes: azul, verde, morado, naranja segun semantica.
- Los labels no deben chocar ni verse diminutos.
- La grafica debe ocupar de esquina a esquina el ancho util del panel cuando corresponda.
- Si hay resumenes de serie, usar chips pastel pequeños alineados a la derecha.

## Donut / Estado de Cartera

- Donut grande, no decorativo.
- Leyenda a la derecha o debajo segun responsive.
- Cada fila de leyenda: color, label, valor y porcentaje.
- Total separado con divisor tenue.
- Los segmentos deben coincidir exactamente con colores de leyenda.

## Tendencias

- Grafica ancha.
- Leyenda junto al titulo cuando el espacio lo permite.
- Resumenes de Facturacion, Cobros y Utilidad como chips arriba a la derecha.

---

# Listas de Pendientes y Alertas

Patron para `Pendientes criticos`, alertas, actividad o tareas:

- Icono circular pastel a la izquierda.
- Titulo compacto y claro.
- Descripcion breve.
- Badge de estado a la derecha.
- Divisores tenues o separacion sutil.

No usar listas planas sin jerarquia visual.

---

# Badges

Los badges son pildoras suaves, no botones pesados.

Mapa:

- Rojo: Alerta, Vencido, Critico.
- Naranja: Atencion, Por vencer.
- Azul: Pendiente, Informativo.
- Verde: Revision, Aprobado, Completado.
- Morado: Secundario, Utilidad.

Reglas:

- Fondo pastel.
- Texto del mismo tono en version intensa.
- Peso medio-alto, nunca exagerado.
- Tamaño compacto.

---

# Accesos Rapidos

El bloque de accesos rapidos debe verse integrado al resto del dashboard.

Patron:

- Titulo dentro de una barra/panel blanco de lado a lado.
- Cards de modulo en grilla.
- Icono circular pastel a la izquierda.
- Texto del modulo claro y compacto.
- Card completa clickeable.

Ejemplos:

- Empresas.
- Cuentas.
- Productos y Servicios.
- Costos.
- Cobros.
- Facturacion.
- Contratos.
- Reportes.
- Configuracion.

---

# Tablas

Las tablas deben verse como herramientas de trabajo modernas.

Obligatorio cuando aplique:

- Buscador.
- Filtros.
- Ordenamiento.
- Badges de estado.
- Acciones por fila.
- Paginacion.
- Hover suave.

No usar tablas Bootstrap basicas ni encabezados pesados.

Las tablas viven dentro de paneles blancos con borde tenue.

---

# Formularios

Los formularios deben organizar informacion, no producir listas largas.

Reglas:

- Agrupar campos por secciones.
- Usar cards/paneles por bloque logico.
- Usar columnas cuando el ancho lo permita.
- Poner acciones principales visibles arriba o en footer fijo del formulario si el flujo lo
  requiere.
- Labels pequeños y claros.
- Inputs con borde tenue y foco azul.

Ejemplos de secciones:

- Informacion General.
- Configuracion Comercial.
- Configuracion Financiera.
- Operacion.
- Facturacion.
- Contabilidad.
- Documentos.

---

# Tabs y Controles Segmentados

No usar tabs Bootstrap tradicionales.

Los tabs deben sentirse como controles de producto:

- Segmentados.
- Compactos.
- Con estado activo claro.
- Con icono cuando ayude.
- Bordes suaves.

Ejemplo:

`Mes actual | 6 meses | 12 meses`

---

# Dashboard como Referencia Base

La composicion actual del dashboard es el patron visual de la plataforma.

Orden:

1. Header global.
2. Titulo `Dashboard` y acciones a la derecha.
3. Fila de 5 KPIs.
4. Resumen financiero mensual + Pendientes criticos.
5. Estado de cartera + Tendencia de facturacion.
6. Accesos rapidos.

Reglas tomadas del dashboard:

- Los paneles deben estar proporcionados.
- Las graficas deben ser grandes y ocupar su espacio.
- Los iconos de KPIs quedan a la izquierda; la informacion se centra.
- Los valores monetarios usan quetzales (`Q`).
- Las leyendas de graficas se colocan cerca del titulo.
- Las cards no deben sentirse huecas ni desbalanceadas.
- El modo claro/oscuro debe conservar jerarquia y contraste.

---

# Modo Claro y Oscuro

Toda pantalla debe soportar ambos modos.

Reglas:

- No hardcodear colores sin equivalente en dark mode.
- Usar variables o overrides claros.
- Mantener contraste suficiente.
- El switch del header debe animarse y cambiar realmente el tema.
- Las graficas deben seguir legibles en dark mode.

---

# Responsive

Desktop:

- Sidebar visible/colapsable.
- Grillas amplias.
- KPIs en una fila cuando el ancho lo permite.

Tablet:

- Grillas bajan columnas.
- Sidebar tiende a colapsarse.

Mobile:

- Sidebar como menu.
- Cards en una columna.
- Graficas mantienen altura minima util.
- Botones y filtros pueden envolver, pero sin romper layout.

---

# Animaciones e Interaccion

Las animaciones deben ser suaves y discretas.

Usar transiciones para:

- Colapsar sidebar.
- Mostrar/ocultar labels.
- Switch claro/oscuro.
- Hover de cards o botones.
- Apertura/cierre de menus.

No usar animaciones llamativas ni lentas. El sistema debe sentirse rapido.

---

# Reglas de Implementacion

Antes de modificar una pantalla:

1. Compararla visualmente contra el dashboard.
2. Reutilizar clases, helpers y componentes existentes.
3. Mantener sidebar/header globales intactos salvo que el cambio sea global e intencional.
4. Usar SVG para iconos.
5. Usar cards y paneles con proporciones utiles.
6. Validar modo claro y oscuro.
7. Revisar responsive basico.
8. Documentar cambios relevantes en `docs/AI_COLLABORATION.md`.

Si un cambio mejora una pantalla pero rompe la consistencia global, no debe aceptarse.

---

# Checklist Rapido

- Se ve como Copenet Enterprise y no como Bootstrap generico.
- Usa fondo gris claro y cards blancas.
- El contenido esta alineado y proporcionado.
- No hay espacios muertos grandes.
- Las graficas son legibles.
- Los iconos son SVG lineales.
- Los colores respetan semantica.
- Los valores monetarios usan `Q`.
- El sidebar colapsado muestra solo iconos principales.
- El modo oscuro funciona.
- Mobile no rompe textos ni controles.

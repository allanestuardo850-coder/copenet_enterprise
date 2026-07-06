# COPENET ENTERPRISE
## Enterprise Design System

---

# OBJETIVO

Todo el sistema debe verse como un ERP/CRM SaaS financiero moderno.

Cada pantalla debe sentirse como un producto comercial terminado.

NO Bootstrap tradicional.

NO formularios como listas verticales largas.

NO tablas antiguas.

NO espacios desperdiciados.

NO colores saturados.

El sistema debe transmitir:

- Enterprise
- SaaS
- Fintech
- Stripe
- Notion
- Linear
- Hubspot
- Atlassian
- Odoo Enterprise

---

# PRINCIPIOS

Siempre priorizar el contenido.

El usuario debe ver la mayor cantidad de información útil posible.

Toda pantalla debe verse profesional, limpia y ordenada.

Densidad alta pero respirable: mucha información, sin sensación de saturación.

Todo se construye con cards sobre un fondo neutro claro.

Ningún bloque debe sentirse vacío.

---

# LAYOUT GENERAL

La plataforma se compone SIEMPRE de tres zonas:

1. Sidebar vertical oscuro a la izquierda (íconos).
2. Header claro superior fijo.
3. Área de contenido a la derecha, sobre fondo gris muy claro.

El contenido se organiza en una grilla de cards.

El área de trabajo ocupa todo el ancho disponible restante.

---

# COLORES

Fondo de la aplicación:

Gris muy claro, casi blanco.

Cards:

Blanco puro.

Sidebar:

Azul marino profundo (navy oscuro).

Color principal:

Azul moderno (royal blue).

Se usa en: item activo, enlaces, líneas de gráfica, botones primarios, badges informativos.

Colores secundarios (siempre en tono suave, nunca saturado):

- Verde → positivo, éxito, cobros, tendencias al alza.
- Naranja / Ámbar → atención, advertencia, cartera vencida.
- Rojo → crítico, negativo, vencido, alerta.
- Morado → utilidad, métricas secundarias.
- Grises → texto, bordes, ejes, elementos neutros.

Los íconos de las cards siempre van dentro de un círculo con fondo pastel del color correspondiente.

Bordes y divisores: gris muy tenue.

Nunca usar sombras duras ni colores planos fuertes.

---

# TIPOGRAFÍA

Utilizar Google Font:

Inter

o

Plus Jakarta Sans

Una sola familia en toda la plataforma.

Jerarquía:

Título de pantalla (H1)
Grande y en negrita.

Subtítulo de pantalla
Texto gris medio, peso normal, debajo del H1.

Título de card (H2)
Mediano, semibold.

Etiqueta de campo / label
Pequeño, gris, peso medio.

Valor / número KPI
Grande y en negrita, color oscuro.

Texto normal
Tamaño base, peso normal.

Texto secundario
Pequeño, gris.

Regla:

Solo títulos y valores llevan negrita.

Labels, descripciones, porcentajes y textos de apoyo van en peso normal.

Jamás usar fuentes grandes innecesarias fuera de títulos y valores.

---

# ICONOGRAFÍA

Utilizar únicamente:

Heroicons

o

Lucide Icons

Nunca iconografía Bootstrap.

Estilo de línea (outline), delgado y consistente.

Los íconos deben aparecer en:

Sidebar, header, cards, KPIs, listas, badges, tabs, botones, tablas, accesos rápidos, estados.

En cards y KPIs el ícono siempre va dentro de un círculo con fondo pastel.

---

# ESPACIADO

Reducir espacios muertos.

Reducir márgenes excesivos.

Reducir altura de headers.

Padding compacto y uniforme en todas las cards.

Separación consistente entre cards (gutter uniforme).

Optimizar el uso del espacio vertical.

Las pantallas nunca deben sentirse vacías.

---

# SIDEBAR

Sidebar tipo SaaS, fondo azul marino oscuro.

Modo icono: barra angosta con íconos verticales.

Logo de la plataforma arriba, dentro de un cuadro redondeado.

Ícono activo resaltado con un cuadro redondeado azul de fondo.

Íconos modernos, agrupados por módulos.

Colapsable y responsive.

Ícono de configuración anclado al fondo.

Comportamiento:

- Desktop → visible (icono o expandido).
- Tablet → colapsado.
- Mobile → menú hamburguesa.

---

# HEADER

Header claro, compacto, de poca altura.

Debe contener, de izquierda a derecha:

1. Botón hamburguesa (colapsar sidebar).
2. Buscador ancho con ícono de lupa y placeholder ("Buscar empresas, cuentas o reportes.").
3. Notificaciones con badge numérico.
4. Mensajes con badge numérico.
5. Accesos rápidos (ícono de grilla).
6. Selector Claro / Oscuro (ícono + switch).
7. Usuario: avatar con iniciales, nombre, correo y chevron.

No debe ocupar demasiada altura.

---

# ENCABEZADO DE PÁGINA

Debajo del header, cada pantalla abre con:

Título grande en negrita (ej: "Dashboard Ejecutivo").

Subtítulo gris de una línea que describe la pantalla.

Alineadas a la derecha, en la misma fila, las acciones principales:

- Filtros o selector de periodo (ej: botón "Mayo 2024" con ícono de calendario y chevron).
- Botón de acción principal (ej: "Actualizar datos" con ícono).

Las acciones principales SIEMPRE van arriba, nunca solo al final de la pantalla.

---

# BOTONES

Botón primario:

Azul, texto claro, esquinas redondeadas, con ícono cuando aplique.

Botón secundario:

Fondo blanco, borde tenue, texto oscuro o azul, con ícono.

Los botones principales SIEMPRE visibles en la parte superior.

Acciones típicas siempre accesibles:

[Nuevo] [Guardar] [Editar] [Eliminar] [Exportar] [Configurar] [Actualizar]

Nunca colocar la acción principal únicamente al final.

---

# CARDS

Todas las pantallas se componen de cards.

Cada card con:

- Bordes redondeados.
- Sombra suave.
- Borde tenue.
- Fondo blanco.
- Padding compacto.
- Espaciado uniforme entre sí.

Cuando la card tiene título, va en la parte superior (H2) con su acción o control a la derecha (toggle, badge o botón).

---

# KPIs

Fila de tarjetas de indicador en la parte superior del dashboard.

Cada tarjeta KPI contiene:

1. Ícono dentro de un círculo con fondo pastel (color según el KPI).
2. Label pequeño y gris (ej: "Ingresos del mes").
3. Valor grande en negrita (ej: "$254,900").
4. Variación (delta) con flecha de color y comparación:
   - Verde con flecha ▲ para positivo.
   - Rojo con flecha ▼ para negativo.
   - Texto de referencia gris (ej: "vs abril 2024").

Mostrar entre 4 y 6 KPIs en una sola fila.

Nunca dejar el bloque de KPIs incompleto o vacío.

---

# BADGES

Etiquetas de estado en forma de píldora.

Fondo pastel tenue + texto del mismo color.

Nunca en negrita fuerte.

Mapa de tonos:

- Rojo → Alerta / Vencido / Crítico.
- Naranja → Atención / Por vencer.
- Azul → Pendiente / Informativo.
- Verde → Revisión / Aprobado / Completado.
- Morado → Secundario / Utilidad.

Usar badges en listas, tablas, estados y encabezados de card.

---

# GRÁFICAS

Las gráficas siempre viven dentro de una card con título y controles.

Tipos a usar:

- Barras comparativas (ej: Ingresos vs Costos) con línea de tendencia superpuesta (Utilidad).
- Donut con leyenda a un costado (color, etiqueta, valor en negrita y porcentaje) y total al pie.
- Líneas múltiples para tendencias (Facturación, Cobros, Utilidad).

Controles dentro de la card:

- Selector de rango segmentado (ej: "Mes actual / 6 meses / 12 meses").
- Leyenda clara con puntos de color.
- Pequeñas píldoras de resumen con el valor de cada serie.

Ejes y grillas en gris muy tenue.

Colores de serie consistentes con la paleta (azul, verde, morado).

Nunca gráficas planas sin contexto ni sin leyenda.

---

# LISTAS

Para paneles tipo "Pendientes críticos", "Actividad reciente" o "Alertas".

Cada fila contiene:

- Ícono en círculo pastel a la izquierda.
- Título en negrita.
- Descripción secundaria en gris.
- Badge de estado alineado a la derecha.

Filas separadas por espacio uniforme, sin líneas duras.

---

# ACCESOS RÁPIDOS

Bloque inferior del dashboard con título "Accesos rápidos".

Grilla de cards de módulo.

Cada card:

- Ícono en círculo pastel.
- Nombre del módulo.
- Card clickeable completa.

Ejemplos: Empresas, Cuentas, Productos y Servicios, Costos, Cobros, Facturación, Contratos, Reportes, Configuración.

Distribuir en filas parejas que llenen el ancho.

---

# TABLAS

Las tablas son un componente principal del sistema.

Siempre incluir:

Buscar, Filtros, Ordenamiento, Badges de estado, Paginación, Acciones por fila.

Estilo limpio: encabezado tenue, filas espaciadas, hover suave.

No usar tablas Bootstrap básicas.

---

# FORMULARIOS

Los formularios nunca serán una lista vertical enorme.

Agrupar la información por bloques, cada bloque en su propia card.

Ejemplo:

Información General, Configuración Comercial, Configuración Financiera, Configuración Operativa, Configuración FEL, Configuración Contable.

Distribuir los campos en columnas cuando el espacio lo permita.

---

# TABS

No usar tabs tradicionales ni pestañas Bootstrap.

Los tabs deben verse como módulos:

[ General ] [ Comercial ] [ Financiero ] [ Operación ] [ Facturación ]

Cada tab con ícono, estado activo, bordes suaves y animación.

---

# DASHBOARD

Composición obligatoria, de arriba hacia abajo:

1. Encabezado de página (título, subtítulo, filtro de periodo, acción principal).
2. Fila de KPIs (4 a 6 tarjetas).
3. Fila principal: gráfica financiera amplia + panel de pendientes/alertas.
4. Fila secundaria: estado de cartera (donut) + tendencia (líneas).
5. Accesos rápidos (grilla de módulos).

Debe contener: KPIs, gráficas, actividad, alertas, accesos rápidos e indicadores.

Nunca dejar espacios vacíos.

---

# MODO OSCURO

Toda pantalla debe soportar Modo Claro y Modo Oscuro.

No crear dos diseños.

Usar variables de color para todo (fondos, texto, bordes, superficies).

El switch de tema vive en el header.

---

# RESPONSIVE

Todo componente debe adaptarse a Desktop, Tablet y Mobile.

En pantallas menores, las grillas de KPIs, cards y accesos rápidos se reacomodan en menos columnas.

El sidebar colapsa y pasa a hamburguesa según el dispositivo.

---

# UX

Toda pantalla debe responder rápidamente.

Incluir: hover, focus, animaciones suaves y microinteracciones.

Transiciones sutiles al cambiar de sección, abrir menús o cambiar de tema.

Sin exageraciones.

---

# ESTRUCTURA DE PANTALLAS

Cada pantalla sigue la misma estructura:

Breadcrumb (si aplica)

↓

Título

↓

Descripción

↓

Botones principales / filtros

↓

KPIs (si aplica)

↓

Contenido principal (cards, gráficas)

↓

Tablas o formularios

---

# MENÚS

Jerarquía oficial de módulos:

Dashboard, Administración, Cobros, Operación, Reportes, Configuración.

Nunca crear menús fuera de esta estructura sin autorización.

---

# DESARROLLO

Antes de crear o modificar cualquier pantalla:

1. Analizar este documento.

2. Mantener el mismo estilo y la misma paleta.

3. No reinventar el diseño.

4. Reutilizar cards, KPIs, badges, gráficas y patrones ya definidos.

5. Todo debe verse parte del mismo producto.

6. Si una pantalla rompe el estándar, corregirla antes de continuar.

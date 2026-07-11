# Copenet Enterprise
## Especificación oficial de interfaz, arquitectura visual y reglas obligatorias para Codex

**Última actualización:** 2026-07-10  
**Estado:** Obligatorio  
**Referencia visual principal:** Ynex – Advanced UI / Navbar  
**Ámbito:** Todas las pantallas nuevas y todas las pantallas existentes que sean modificadas.

---

# 1. Objetivo general

Codex debe reconstruir y mantener la interfaz de Copenet Enterprise como una plataforma SaaS financiera y operativa moderna, compacta, ejecutiva y consistente.

La referencia visual obligatoria es el tema Ynex indicado por el propietario del proyecto. La implementación debe reproducir su lenguaje visual, jerarquía, densidad, navegación interna, proporciones, espaciados, bordes, estados activos, distribución de cards y comportamiento responsive, pero utilizando los componentes, controladores, rutas, helpers y arquitectura existentes en Copenet Enterprise.

No se debe copiar código fuente, recursos licenciados, imágenes, iconos o archivos internos del tema. La referencia se utiliza para reproducir el comportamiento y la apariencia dentro del sistema actual.

La prioridad no es decorar pantallas. La prioridad es organizar correctamente la información y separar con claridad:

1. **Resumen y control arriba.**
2. **Navegación por tabs en el centro.**
3. **Ejecución operativa abajo.**

---

# 2. Regla estructural principal: Vista Controlador

Todas las pantallas de detalle, expediente, configuración, administración, creación y edición deben utilizar el patrón **Vista Controlador**.

Este patrón es obligatorio tanto para pantallas nuevas como para pantallas existentes que sean intervenidas.

## 2.1 Qué significa Vista Controlador

La pantalla debe funcionar como un centro de control del registro, proceso o módulo actual.

La composición se divide en tres niveles:

### Nivel 1. Resumen superior

En la parte superior se presenta únicamente la información necesaria para comprender el estado general del registro.

Debe incluir, según corresponda:

- Nombre o identificador principal.
- Estado actual.
- Tipo de registro.
- Empresa o compañía relacionada.
- Responsable.
- Total, saldo, avance o indicador principal.
- Fechas relevantes.
- Alertas.
- Acciones globales.

El resumen debe ser compacto. No debe convertirse en un formulario ni repetir toda la información del registro.

### Nivel 2. Navegación por tabs

Debajo del resumen debe existir una barra horizontal de tabs.

Las tabs organizan las áreas funcionales del registro y permiten cambiar entre vistas sin mostrar todo el contenido al mismo tiempo.

### Nivel 3. Área de ejecución

Debajo de las tabs se presenta el contenido operativo de la sección seleccionada.

Aquí se realizan las acciones: capturar información, editar, aprobar, cargar documentos, agregar items, ejecutar cobros, revisar historial, administrar permisos, crear tareas o completar procesos.

**Nunca colocar el área de ejecución antes del resumen.**

---

# 3. Jerarquía obligatoria de una pantalla

Toda pantalla compatible con el patrón Vista Controlador debe seguir este orden:

```text
.app-page
  .view-controller
    .view-controller__summary
    .view-controller__tabs
    .view-controller__content
```

Estructura conceptual:

```erb
<section class="view-controller" data-controller="tabs">
  <header class="view-controller__summary">
    <!-- Identidad, estado, métricas y acciones globales -->
  </header>

  <nav class="module-tabs" role="tablist">
    <!-- Tabs reales -->
  </nav>

  <div class="view-controller__content">
    <!-- Panel activo y ejecución -->
  </div>
</section>
```

No se permite alterar este orden salvo que exista una limitación técnica documentada y aprobada.

---

# 4. El resumen siempre va arriba

El resumen superior debe permitir que el usuario entienda el registro en pocos segundos.

## 4.1 Contenido del resumen

El resumen puede contener:

- Avatar, logo o icono del módulo.
- Título principal.
- Código o número de registro.
- Badges de estado.
- Métricas principales.
- Información secundaria breve.
- Botones globales.
- Menú contextual de acciones secundarias.

## 4.2 Distribución

Desktop:

- Identidad a la izquierda.
- Métricas en el centro o en una grilla inferior compacta.
- Acciones globales a la derecha.

Tablet:

- Identidad y acciones pueden ocupar dos filas.
- Las métricas pueden reorganizarse en dos columnas.

Mobile:

- Una sola columna.
- El título y estado deben aparecer primero.
- Las acciones deben permanecer visibles y utilizables.
- Las tabs deben permitir desplazamiento horizontal.

## 4.3 Prohibiciones

No colocar en el resumen:

- Formularios completos.
- Tablas extensas.
- Historiales.
- Documentos.
- Listas de tareas.
- Campos editables sin justificación.
- Textos descriptivos largos.
- Información repetida en el contenido inferior.

---

# 5. Tabs reales, no botones

Las opciones de navegación interna deben implementarse como tabs semánticas y visuales.

No deben verse como botones independientes, cards grandes o acciones primarias.

## 5.1 Estructura requerida

```erb
<div class="module-tabs" role="tablist" aria-label="Secciones del registro">
  <button
    type="button"
    class="module-tab is-active"
    role="tab"
    aria-selected="true"
    aria-controls="panel-general"
    id="tab-general"
    data-tabs-target="tab"
    data-action="click->tabs#select"
    data-tab-id="general">
    <span class="module-tab__icon"><!-- SVG --></span>
    <span class="module-tab__label">General</span>
  </button>

  <button
    type="button"
    class="module-tab"
    role="tab"
    aria-selected="false"
    aria-controls="panel-documentos"
    id="tab-documentos"
    data-tabs-target="tab"
    data-action="click->tabs#select"
    data-tab-id="documentos">
    <span class="module-tab__icon"><!-- SVG --></span>
    <span class="module-tab__label">Documentos</span>
  </button>
</div>
```

Aunque técnicamente se utilice un elemento `button` por accesibilidad y control de teclado, visualmente debe comportarse y verse como una tab, no como un botón de acción.

## 5.2 Estado activo obligatorio

La tab seleccionada debe recibir exactamente la clase:

```css
module-tab is-active
```

La clase `is-active` debe controlar:

- Color del texto.
- Color del icono.
- Indicador inferior.
- Fondo tenue opcional.
- Estado de foco.
- `aria-selected="true"`.

Las tabs inactivas no deben tener apariencia de botones secundarios.

## 5.3 Apariencia visual

Las tabs deben seguir el patrón visual Ynex:

- Barra horizontal limpia.
- Fondo general blanco o transparente.
- Separación uniforme.
- Tipografía compacta.
- Icono lineal opcional.
- Estado activo claramente visible.
- Línea inferior o borde de acento.
- Hover tenue.
- Sin sombras pesadas.
- Sin esquinas excesivamente redondeadas.
- Sin apariencia de píldora grande.
- Sin cajas independientes para cada tab.

## 5.4 Comportamiento

- Solo una tab puede estar activa.
- Solo un panel puede estar visible.
- Cambiar de tab no debe recargar la página, salvo que la arquitectura del módulo exija una ruta independiente.
- Debe conservarse el estado activo cuando sea razonable.
- Debe soportar teclado con flechas izquierda/derecha.
- Debe actualizar `aria-selected`, `tabindex` y el panel visible.
- En mobile debe usar scroll horizontal, no envolver en múltiples líneas desordenadas.

---

# 6. Controlador único de tabs

Todas las pantallas con navegación interna deben usar el controlador existente:

```html
data-controller="tabs"
```

No crear controladores duplicados como:

- `wizard-tabs`
- `profile-tabs`
- `client-tabs`
- `custom-tabs`
- `section-switcher`

La lógica debe centralizarse en el controlador `tabs`.

## 6.1 Responsabilidades del controlador

El controlador debe:

1. Detectar tabs y paneles.
2. Determinar la tab inicial.
3. Aplicar y remover `is-active`.
4. Mostrar únicamente el panel seleccionado.
5. Actualizar atributos ARIA.
6. Permitir navegación con teclado.
7. Permitir activación por parámetro, hash o valor persistido cuando corresponda.
8. Evitar que dos paneles queden visibles simultáneamente.
9. No perder datos de formularios al cambiar de tab.
10. No enviar formularios al presionar una tab.

## 6.2 Targets sugeridos

```javascript
static targets = ["tab", "panel"]
```

## 6.3 Estado visual y funcional

Al activar una tab:

```text
Tab activa:
- agrega is-active
- aria-selected = true
- tabindex = 0

Tabs inactivas:
- remueve is-active
- aria-selected = false
- tabindex = -1

Panel activo:
- agrega is-active
- hidden = false

Paneles inactivos:
- remueve is-active
- hidden = true
```

---

# 7. Paneles de contenido

Cada tab controla un panel.

## 7.1 Estructura

```erb
<section
  id="panel-general"
  class="module-tab-panel is-active"
  role="tabpanel"
  aria-labelledby="tab-general"
  data-tabs-target="panel"
  data-tab-panel-id="general">

  <!-- contenido de ejecución -->
</section>
```

Panel inactivo:

```erb
<section
  id="panel-documentos"
  class="module-tab-panel"
  role="tabpanel"
  aria-labelledby="tab-documentos"
  data-tabs-target="panel"
  data-tab-panel-id="documentos"
  hidden>

  <!-- contenido de ejecución -->
</section>
```

## 7.2 Regla estricta

No colocar todos los contenidos uno debajo del otro.

No simular tabs mediante anclas que solo hacen scroll.

No dejar paneles inactivos visibles.

No duplicar contenido entre panels.

---

# 8. Diferencia entre navegación, acciones y filtros

Codex debe distinguir tres conceptos:

## 8.1 Tabs

Cambian la sección funcional visible.

Ejemplos:

- Resumen.
- Información general.
- Proyectos.
- Contratos.
- Documentos.
- Cobros.
- Facturación.
- Historial.

## 8.2 Botones

Ejecutan una acción.

Ejemplos:

- Guardar.
- Crear.
- Aprobar.
- Enviar.
- Agregar cobro.
- Subir documento.
- Editar.
- Inactivar.

## 8.3 Filtros

Refinan la información dentro de una sección.

Ejemplos:

- Estado.
- Fecha.
- Responsable.
- Tipo.
- Búsqueda.

**No usar botones como sustituto visual de tabs.**  
**No usar tabs para acciones.**  
**No usar chips de filtro como tabs.**

---

# 9. Pantallas ya creadas y pantallas nuevas

Esta especificación aplica a ambas.

## 9.1 Pantallas nuevas

Toda pantalla nueva debe construirse directamente con:

- Vista Controlador.
- Resumen superior.
- `data-controller="tabs"`.
- `module-tabs`.
- `module-tab`.
- `module-tab-panel`.
- Clase `is-active`.
- Área de ejecución inferior.
- Componentes compartidos.

No crear primero una versión genérica para después adaptarla.

## 9.2 Pantallas existentes

Al modificar una pantalla existente:

1. Analizar su propósito.
2. Identificar información de resumen.
3. Identificar secciones funcionales.
4. Convertir las secciones en tabs.
5. Mover toda acción operativa al panel correspondiente.
6. Eliminar duplicados.
7. Mantener rutas, permisos, validaciones y lógica de negocio.
8. Reutilizar partials y helpers existentes.
9. Verificar que no se rompan formularios ni Turbo.
10. Alinear la pantalla al patrón visual nuevo.

No se acepta “parchear” una pantalla antigua agregando solamente una barra de tabs encima. La composición completa debe reorganizarse.

---

# 10. Tema visual obligatorio

La plataforma debe adoptar de forma integral el lenguaje visual de la referencia Ynex.

## 10.1 Características obligatorias

- Interfaz limpia y compacta.
- Header fijo y discreto.
- Sidebar profesional.
- Cards blancas con borde tenue.
- Sombras muy suaves.
- Radios moderados.
- Separaciones consistentes.
- Tipografía clara.
- Iconos lineales.
- Estados activos visibles.
- Tablas modernas.
- Formularios compactos.
- Buen uso del espacio horizontal.
- Diseño compatible con modo claro y oscuro.

## 10.2 No mezclar estilos

No conservar fragmentos visuales Bootstrap genéricos dentro de una pantalla nueva.

No mezclar:

- Tabs Ynex con cards antiguas.
- Botones modernos con inputs sin estilo.
- Iconos SVG con iconos de fuente.
- Bordes modernos con tablas antiguas.
- Nuevas métricas con encabezados heredados duplicados.

Cuando se interviene una pantalla, debe quedar visualmente completa.

---

# 11. Variables y tokens de diseño

Codex debe centralizar el estilo mediante variables.

Ejemplo:

```css
:root {
  --ui-primary: #5b5fc7;
  --ui-primary-rgb: 91, 95, 199;
  --ui-bg: #f7f8fb;
  --ui-surface: #ffffff;
  --ui-surface-soft: #f8f9fc;
  --ui-border: #e7e9f1;
  --ui-text: #1f2430;
  --ui-text-muted: #7b8190;
  --ui-success: #22a06b;
  --ui-warning: #e59b25;
  --ui-danger: #dc4c64;
  --ui-info: #3b82f6;
  --ui-radius-sm: 0.375rem;
  --ui-radius-md: 0.625rem;
  --ui-radius-lg: 0.875rem;
  --ui-shadow-sm: 0 1px 2px rgba(20, 25, 38, 0.04);
  --ui-shadow-md: 0 4px 16px rgba(20, 25, 38, 0.06);
}
```

Los valores concretos deben integrarse con las variables actuales del proyecto. No duplicar sistemas de color si ya existe uno.

---

# 12. Sidebar y header global

El sidebar y el header son estructuras globales.

## Sidebar

Debe incluir:

- Logo Copenet.
- Navegación principal.
- Iconos SVG consistentes.
- Estado activo.
- Submenús ordenados.
- Modo expandido y colapsado.
- Tooltips al estar colapsado.
- Scroll interno cuando sea necesario.

No permitir que cada módulo modifique el sidebar.

## Header

Debe incluir:

- Control de sidebar.
- Breadcrumb compacto o contexto actual.
- Búsqueda global.
- Acciones rápidas justificadas.
- Notificaciones.
- Modo claro/oscuro.
- Perfil del usuario.

No usar el header como banner decorativo.

---

# 13. Títulos y encabezados

No duplicar títulos.

Estructura recomendada:

```text
Breadcrumb pequeño, cuando aporte contexto.
Resumen Vista Controlador.
Tabs.
Contenido.
```

No usar:

```text
Título externo grande.
Otro título dentro del panel.
Otro título dentro del formulario.
```

El nombre principal debe aparecer una sola vez como elemento dominante.

---

# 14. Cards de resumen

Las métricas del resumen deben presentarse en cards compactas.

Cada card puede incluir:

- Label.
- Valor.
- Icono.
- Variación.
- Indicador.
- Texto auxiliar corto.

Reglas:

- No usar cards gigantes para un solo número.
- No usar íconos decorativos sin significado.
- No aplicar colores saturados a toda la card.
- Usar fondos neutros y acentos semánticos.
- Mantener alturas consistentes.

---

# 15. Formularios

Los formularios forman parte del área de ejecución.

## 15.1 Organización

Agrupar campos por contexto:

- Identificación.
- Contacto.
- Configuración.
- Condiciones.
- Facturación.
- Seguridad.
- Documentación.

Cada grupo debe usar un panel compacto con encabezado breve.

## 15.2 Acciones

Las acciones del formulario deben permanecer visibles y consistentes.

Orden recomendado:

- Cancelar.
- Guardar.

En flujos con múltiples tabs:

- El botón Guardar puede estar en el encabezado del contenido o en una barra sticky.
- No duplicarlo innecesariamente en cada panel.
- No cambiar de tab automáticamente si existen errores.
- Al fallar validación, activar la tab que contiene el primer error.

## 15.3 Prohibiciones

- Formulario interminable de una columna.
- Labels excesivamente largos.
- Texto de ayuda redundante.
- Inputs crudos.
- Selectores incompatibles entre módulos.
- Botones de guardar repetidos arriba y abajo sin necesidad.

---

# 16. Tablas y listados

Las tablas deben seguir el mismo lenguaje visual del nuevo tema.

Deben incluir cuando corresponda:

- Encabezado de sección.
- Búsqueda.
- Filtros compactos.
- Acciones alineadas.
- Estados con badges.
- Paginación.
- Selector de cantidad.
- Empty state.
- Loading state.
- Error state.

Las acciones de fila deben usar iconos SVG con tooltip.

No usar texto plano:

```text
Ver | Editar | Eliminar
```

Usar:

- Ver.
- Editar.
- Inactivar.
- Más opciones.

La eliminación física no debe exponerse en registros operativos salvo aprobación expresa.

---

# 17. Estados vacíos, carga y errores

Cada panel debe soportar:

## Vacío

- Icono simple.
- Mensaje claro.
- Acción principal cuando corresponda.

## Cargando

- Skeleton o loader consistente.
- No mover bruscamente el layout.

## Error

- Mensaje comprensible.
- Acción para reintentar cuando corresponda.
- No mostrar errores técnicos sin tratamiento.

---

# 18. Responsive

## Desktop

- Resumen horizontal.
- Tabs completas.
- Contenido con grillas amplias.
- Tablas completas.

## Tablet

- Resumen en dos filas.
- Tabs desplazables.
- Cards en dos columnas.
- Acciones agrupadas.

## Mobile

- Resumen en una columna.
- Tabs con scroll horizontal.
- Área de ejecución a una columna.
- Botones con ancho adecuado.
- Tablas con estrategia responsive.
- Sin desbordamientos.
- Sin textos montados.
- Sin botones fuera de pantalla.

Las tabs no deben convertirse automáticamente en cards o botones grandes en mobile.

---

# 19. Accesibilidad

Toda implementación debe incluir:

- `role="tablist"`.
- `role="tab"`.
- `role="tabpanel"`.
- `aria-selected`.
- `aria-controls`.
- `aria-labelledby`.
- `tabindex`.
- Navegación con teclado.
- Foco visible.
- Contraste suficiente.
- Labels asociados a inputs.
- Tooltips accesibles para acciones con icono.

No depender exclusivamente del color para indicar estado.

---

# 20. Modo oscuro

Todos los componentes nuevos deben funcionar en modo oscuro.

Verificar:

- Fondo general.
- Superficies.
- Bordes.
- Inputs.
- Texto.
- Tabs.
- Tab activa.
- Tablas.
- Badges.
- Dropdowns.
- Modales.
- Tooltips.
- Skeletons.
- Gráficas.

No usar colores hardcodeados que produzcan bajo contraste.

---

# 21. Componentes compartidos obligatorios

Antes de crear nuevas clases o partials, revisar y reutilizar:

- `view-controller`
- `view-controller__summary`
- `view-controller__tabs`
- `view-controller__content`
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

Si `view-controller` no existe todavía, crearlo como componente base reutilizable y migrar gradualmente las pantallas.

---

# 22. Arquitectura recomendada en Rails

La implementación debe respetar la arquitectura actual.

## Vistas

- Usar partials.
- Evitar archivos ERB gigantes.
- Extraer resumen, tabs y panels.
- Mantener lógica de negocio fuera de la vista.
- Usar helpers para badges y acciones repetidas.

Ejemplo:

```text
app/views/clients/
  show.html.erb
  _view_controller.html.erb
  _summary.html.erb
  _tabs.html.erb
  tabs/
    _general.html.erb
    _projects.html.erb
    _contracts.html.erb
    _documents.html.erb
    _billing.html.erb
    _history.html.erb
```

## Stimulus

```text
app/javascript/controllers/tabs_controller.js
```

Debe existir un solo controlador general de tabs.

## Estilos

Organizar los estilos por componente y no por pantalla aislada.

```text
app/assets/stylesheets/components/
  _view_controller.scss
  _module_tabs.scss
  _summary_cards.scss
```

---

# 23. Ejemplo completo de Vista Controlador

```erb
<section class="view-controller" data-controller="tabs">
  <header class="view-controller__summary">
    <div class="view-controller__identity">
      <div class="view-controller__avatar">
        <%= inline_svg_tag "icons/building.svg" %>
      </div>

      <div>
        <div class="view-controller__eyebrow">Cliente</div>

        <div class="view-controller__title-row">
          <h1 class="view-controller__title"><%= @client.name %></h1>
          <%= badge @client.status %>
        </div>

        <div class="view-controller__meta">
          Código <%= @client.code %> · <%= @client.company.name %>
        </div>
      </div>
    </div>

    <div class="view-controller__metrics">
      <div class="summary-metric">
        <span class="summary-metric__label">Proyectos</span>
        <strong class="summary-metric__value"><%= @client.projects.count %></strong>
      </div>

      <div class="summary-metric">
        <span class="summary-metric__label">Saldo pendiente</span>
        <strong class="summary-metric__value">
          <%= number_to_currency(@client.pending_balance, unit: "Q") %>
        </strong>
      </div>
    </div>

    <div class="view-controller__actions">
      <%= link_to "Volver", clients_path, class: "ui-button ui-button--secondary" %>
      <%= link_to "Editar", edit_client_path(@client), class: "ui-button ui-button--primary" %>
    </div>
  </header>

  <nav class="module-tabs" role="tablist" aria-label="Secciones del cliente">
    <button
      type="button"
      id="tab-general"
      class="module-tab is-active"
      role="tab"
      aria-selected="true"
      aria-controls="panel-general"
      tabindex="0"
      data-tabs-target="tab"
      data-action="click->tabs#select keydown->tabs#navigate"
      data-tab-id="general">
      General
    </button>

    <button
      type="button"
      id="tab-projects"
      class="module-tab"
      role="tab"
      aria-selected="false"
      aria-controls="panel-projects"
      tabindex="-1"
      data-tabs-target="tab"
      data-action="click->tabs#select keydown->tabs#navigate"
      data-tab-id="projects">
      Proyectos
    </button>

    <button
      type="button"
      id="tab-documents"
      class="module-tab"
      role="tab"
      aria-selected="false"
      aria-controls="panel-documents"
      tabindex="-1"
      data-tabs-target="tab"
      data-action="click->tabs#select keydown->tabs#navigate"
      data-tab-id="documents">
      Documentos
    </button>
  </nav>

  <div class="view-controller__content">
    <section
      id="panel-general"
      class="module-tab-panel is-active"
      role="tabpanel"
      aria-labelledby="tab-general"
      data-tabs-target="panel"
      data-tab-panel-id="general">
      <%= render "clients/tabs/general", client: @client %>
    </section>

    <section
      id="panel-projects"
      class="module-tab-panel"
      role="tabpanel"
      aria-labelledby="tab-projects"
      data-tabs-target="panel"
      data-tab-panel-id="projects"
      hidden>
      <%= render "clients/tabs/projects", client: @client %>
    </section>

    <section
      id="panel-documents"
      class="module-tab-panel"
      role="tabpanel"
      aria-labelledby="tab-documents"
      data-tabs-target="panel"
      data-tab-panel-id="documents"
      hidden>
      <%= render "clients/tabs/documents", client: @client %>
    </section>
  </div>
</section>
```

---

# 24. Pantallas de expediente

Los expedientes deben ser el ejemplo principal de Vista Controlador.

## Resumen superior

Debe mostrar:

- Cliente.
- Tipo.
- Estado.
- Responsable.
- Próximo vencimiento.
- Saldo o monto.
- Avance.
- Alertas.

## Tabs sugeridas

- Resumen.
- Datos generales.
- Proyectos.
- Contratos.
- Documentos.
- Cobros.
- Facturación.
- Incidentes.
- Tareas.
- Historial.

No mostrar todas estas áreas simultáneamente.

Cada tab debe contener su propia zona de ejecución.

---

# 25. Pantallas de crear y editar

Crear y editar también deben usar Vista Controlador cuando el registro tenga varias áreas.

## Resumen superior en crear

Puede mostrar:

- Nombre del flujo.
- Estado “Nuevo”.
- Pasos completados.
- Errores pendientes.
- Acciones Guardar y Cancelar.

## Resumen superior en editar

Puede mostrar:

- Registro actual.
- Estado.
- Última actualización.
- Usuario que modificó.
- Acciones Guardar y Cancelar.

## Tabs

Las tabs deben representar secciones, no pasos decorativos.

Ejemplos:

- General.
- Configuración.
- Facturación.
- Documentos.
- Permisos.
- Vista previa.

Si el proceso requiere secuencia estricta, el controlador puede validar navegación, pero debe conservar el mismo patrón visual.

---

# 26. Migración de pantallas existentes

Codex debe ejecutar la migración en este orden:

1. Identificar layout y dependencias.
2. Ejecutar pruebas existentes.
3. Tomar captura de referencia de la pantalla actual.
4. Separar resumen, tabs y contenido.
5. Crear o reutilizar partials.
6. Integrar `data-controller="tabs"`.
7. Aplicar estilos del tema.
8. Ajustar responsive.
9. Probar modo oscuro.
10. Probar permisos y rutas.
11. Probar validaciones.
12. Probar Turbo y Stimulus.
13. Comparar visualmente.
14. Ejecutar linters y pruebas.
15. Ejecutar `git diff --check`.

No modificar lógica financiera, reglas de negocio o permisos como parte de un cambio puramente visual.

---

# 27. Criterios de aceptación

Una pantalla se considera terminada únicamente cuando:

- Usa Vista Controlador.
- El resumen está arriba.
- Las tabs están debajo del resumen.
- La ejecución está debajo de las tabs.
- Usa `data-controller="tabs"`.
- La tab activa usa `module-tab is-active`.
- Las tabs no parecen botones.
- Solo un panel está visible.
- No hay títulos duplicados.
- No hay contenido repetido.
- No hay bloques Bootstrap genéricos.
- El diseño coincide con el lenguaje visual de Ynex.
- Funciona en claro y oscuro.
- Funciona en desktop, tablet y mobile.
- Es accesible por teclado.
- No rompe rutas ni validaciones.
- No altera lógica de negocio.
- Reutiliza componentes.
- Las pruebas pasan.
- `git diff --check` no reporta errores.

---

# 28. Instrucción directa para Codex

Antes de modificar cualquier pantalla:

1. Lee este documento completo.
2. Inspecciona los componentes existentes.
3. Inspecciona Dashboard, Compañías, Usuarios, Roles, Monedas, Clientes, Parámetros y Generar cotización.
4. Identifica qué patrones ya existen.
5. Reutiliza esos patrones.
6. Reestructura la pantalla completa, no solo colores o bordes.
7. Aplica Vista Controlador.
8. Mantén el resumen arriba.
9. Coloca toda ejecución debajo de las tabs.
10. Usa tabs reales con `module-tab is-active`.
11. Usa un solo `data-controller="tabs"`.
12. Entrega una implementación completa, responsive y funcional.

No improvises un diseño distinto. No crees un segundo sistema visual. No conviertas las tabs en botones. No dejes secciones completas visibles simultáneamente. No entregues una modificación parcial.
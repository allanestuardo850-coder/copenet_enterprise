# Especificación de implementación de facturas electrónicas (DTE/FEL)

Este documento describe cómo se implementa la facturación electrónica de `Cobros Varios` en el proyecto `rapixchange`.

## Objetivo

- Generar un DTE electrónico para transacciones de tipo `Cobros Varios` y otras transacciones facturables.
- Firmar el XML con el servicio `signer-emisores.feel.com.gt`.
- Enviar el XML firmado a `certificador.feel.com.gt` para obtener certificación FEL.
- Registrar el UUID, estado y posibles errores en la base de datos.

## Componentes principales

- `app/models/transaccion.rb`
- `app/models/dte.rb`
- `app/models/fel/fel_dte.rb`
- `app/controllers/transacciones_controller.rb`
- `app/models/empresa.rb`

## Flujo general de facturación

1. El usuario crea o procesa una transacción del tipo `Facturacion`.
2. El controlador `TransaccionesController#procesar` llama a `@transaccion.facturar`.
3. El método `Transaccion#facturar` verifica si la transacción es facturable y si ya existe un DTE certificado.
4. Si no existe un DTE válido, se crea un nuevo registro `Dte` con `Transaccion#crear_nuevo_dte`.
5. El modelo `Dte` construye la estructura FEL, firma el XML y certifica el documento.
6. En caso de éxito, guarda `uuid`, `estado = "Certificado_FEL"` y `fecha_certificacion`.
7. En caso de error, guarda `estado = "Errores_FEL"` y `errores_fel`.

## `Transaccion#facturar`

- Verifica que la transacción sea facturable con `facturable?`.
- Ignora facturación si `porcentaje_valor_cobro == 0`.
- Reutiliza el último DTE existente salvo que esté anulado o certificado ya.
- Si es necesario, crea un nuevo DTE con `crear_nuevo_dte`.
- Llama a `dte.certificar` y devuelve un hash con `resultado`, `uuid` y `fecha_certificacion`.

```ruby
if dte.certificar
  return { resultado: true, mensaje: "certificado exitosamente", uuid: dte.uuid, fecha_certificacion: dte.fecha_certificacion }
else
  return { resultado: false, mensaje: "sin certificar", errores_fel: dte.errores_fel }
end
```

## `Transaccion#crear_nuevo_dte`

Crea un registro `Dte` con los siguientes campos:

- `transaccion_id` => self.id
- `nit_cliente` => self.nit_cliente
- `descripcion` => descripción generada con `obtener_descripcion`.
- `monto` => `self.porcentaje_valor_cobro.round(5)` o `self.criptomoneda_factura.round(5)` para criptomonedas.
- `estado` => `"PendienteCertificar"`
- `created_by` => self.created_by
- `tipo` => `self.tipo.split(" ").first` (por ejemplo, `Cobros` para `Cobros Varios`).
- `correo` => `self.cliente_correo || ""`
- `tipo_especial` => `self.cliente_tipo_identificacion`

## DTE / electrónica 

### Modelo `Dte`

- `belongs_to :transaccion`
- Atributos principales:
  - `nit_cliente`
  - `descripcion`
  - `monto`
  - `estado`
  - `fecha_certificacion`
  - `uuid`
  - `errores_fel`

### Método `Dte#certificar`

1. Crea objetos FEL:
   - `Fel::FelDte`
   - `Fel::FelEmisor`
   - `Fel::FelReceptor`
   - `Fel::FelTotales`
   - `Fel::FelTotalImpuesto`
2. Agrega adenda según el tipo de transacción:
   - `Facturacion` o `Producto Ventas` usa `<DISENO>2</DISENO>`.
   - otros tipos usan `<DISENO>1</DISENO>`.
3. Configura datos de emisor con la agencia y empresa.
4. Configura datos del receptor con nit, correo y nombre de cliente.
5. Genera clave única con `self.id + "-#{empresa.nombre}-RXE"`.
6. Ajusta los datos generales del DTE:
   - Moneda fija `GTQ`
   - Fecha y hora de la transacción
   - Tipo `FACT`
7. Agrega la frase FEL y, si aplica, el tipo especial.
8. Llama al método de detalle según el tipo de transacción:
   - `detalle_cobros`
   - `detalle_producto`
   - `detalle_divisas`
   - `detalle_criptomonedas`
   - etc.
9. Calcula totales impuestos y agrega totales.
10. Llama a `Fel::FelDte#certificar(...)`.

### Detalle de `Facturacion`

El método `Dte#detalle_cobros`:

- Recorre `self.transaccion.cobros_detalles`.
- Para cada detalle crea `Fel::FelItem` y `Fel::FelImpuesto`.
- Campos principales:
  - `numero_linea`
  - `bien_o_servicio` => `detalle.bien_servicio`
  - `cantidad` => `detalle.cantidad`
  - `unidad_medida` => `UND`
  - `descripcion` => `detalle.descripcion`
  - `precio_unitario` => `detalle.precio_unitario.round(5)`
  - `precio` => `detalle.sub_total.round(5)`
  - `descuento` => `detalle.descuento`
  - `total` => `detalle.total.round(5)`
- Calcula IVA:
  - `monto_gravable = detalle.total / 1.12`
  - `iva = detalle.total - monto_gravable`
  - registra el impuesto con `IVA`.
- Agrega el item al DTE con `dte_fel_a_certificar.agregar_item(nuevo_item)`.
- Acumula el total de IVA en `totales_impuestos`.

### Detalle de `Divisas` y `Criptomonedas`

- Usa un solo item con `bien_o_servicio = 'S'`.
- `descripcion` se obtiene de `transaccion.obtener_descripcion`.
- Total se calcula con `transaccion.porcentaje_valor_cobro` o `transaccion.criptomoneda_factura`.
- Aplica la misma fórmula de IVA 12%.

## Integración FEL / firma y certificación

### Firma de XML

Método `Fel::FelDte#firmar_xml`:

- URL: `https://signer-emisores.feel.com.gt/sign_solicitud_firmas/firma_xml`
- Payload JSON:
  - `llave` => `prefijo_firma`
  - `archivo` => base64 del XML plano
  - `alias` => `prefijo_firma`
  - `es_anulacion` => `N` o `S`
- Respuesta JSON con `resultado` y `archivo`.

### Certificación FEL

Método `Fel::FelDte#certificar_xml`:

- URL de certificación: `https://certificador.feel.com.gt/fel/certificacion/v2/dte`
- URL de anulación: `https://certificador.feel.com.gt/fel/anulacion/v2/dte`
- Headers HTTP:
  - `Content-Type: application/json`
  - `usuario` => `prefijo`
  - `llave` => `llave_certificacion`
  - `identificador` => `clave_unica`
- Body JSON:
  - `nit_emisor`
  - `correo_copia`
  - `xml_dte` => XML firmado

### Respuesta FEL

- Si `resultado` es verdadero: devuelve `uuid`, `serie` y `numero`.
- Si falla: devuelve `descripcion` y `mensaje_certificador`.

## Configuración de la empresa

Los datos usados se encuentran en `app/models/empresa.rb` y son clave para FEL:

- `prefijo`
- `llave`
- `prefijo_firma`
- `llave_firma`
- `nit`
- `correo`
- `afiliacion_iva`
- `token_fel` (para sesiones FEL/validación)

## Controlador y proceso

En `app/controllers/transacciones_controller.rb`:

- `cobros_varios` crea una nueva transacción tipo `Cobros Varios`.
- `procesar` certifica la transacción si no existe un DTE certificado.
- Si `facturar` falla, el controlador extrae `errores_fel` y redirige con un mensaje.

## Consideraciones específicas para otro proyecto

1. Reproduce un modelo transaccional similar a `Transaccion`.
2. Define un objeto `Dte` para almacenar:
   - `transaccion_id`
   - `nit_cliente`
   - `descripcion`
   - `monto`
   - `estado`
   - `fecha_certificacion`
   - `uuid`
   - `errores_fel`
3. Implementa las reglas de negocio para crear el DTE sólo si la transacción es facturable.
4. Implementa la construcción del XML FEL, la firma y la certificación.
5. Haz un adaptador de integración para:
   - firmar XML (`signer-emisores.feel.com.gt`)
   - certificar XML (`certificador.feel.com.gt`)
6. Guarda los errores completos en un campo como `errores_fel`.
7. Maneja anulaciones con la misma lógica FEL si el proyecto lo requiere.

## Notas

- Este código no usa un servicio llamado `infile`; la integración real es con la plataforma FEL de Feel.
- El tipo de factura para `Facturacion` se registra como `Cobros` en el DTE.
- La generación del XML se basa en clases `Fel::FelDte`, `Fel::FelItem` y `Fel::FelImpuesto`.
- La validación de NIT de clientes se realiza con `Empresa#fel_nit_v2`.

## Adaptación Copenet Enterprise / INFILE

En Copenet Enterprise la implementación no debe copiar el flujo de `Transaccion` del proyecto original. La entidad operativa base será `Factura`, con un registro `Dte` asociado para almacenar la certificación electrónica.

### Decisiones de integración

- La empresa emisora se toma de `Company`.
- Las credenciales se leen desde:
  - `infile_prefix`
  - `infile_key`
  - `infile_signature_prefix`
  - `infile_signature_key`
  - `fel_scenario_code`
  - `tax_id`
  - `notification_email`
- La factura manual sigue existiendo como registro administrativo.
- El DTE se crea en una tabla separada para guardar XML, UUID, estado, errores y respuesta completa del certificador.
- La integración se encapsula bajo `Dte::Infile::*`.

### Estructura agregada

- `Factura`
  - `belongs_to :company`
  - `has_one :dte`
  - `certificar_infile!`
- `Dte`
  - `belongs_to :factura`
  - `belongs_to :company`
  - Guarda estado FEL, XML, UUID, serie, número, errores y payloads.
- `Dte::Infile::BuildFromFactura`
  - Construye o actualiza el DTE desde la factura.
- `Dte::Infile::XmlBuilder`
  - Genera el XML base FEL.
- `Dte::Infile::Client`
  - Firma y certifica contra INFILE.
- `Dte::Infile::CertificationPipeline`
  - Orquesta generación, firma, certificación y persistencia.

### Configuración de endpoints

Los endpoints deben mantenerse configurables por ambiente:

- `INFILE_SIGNER_URL`
- `INFILE_CERTIFIER_URL`

Si no se definen, se usan los endpoints documentados originalmente:

- `https://signer-emisores.feel.com.gt/sign_solicitud_firmas/firma_xml`
- `https://certificador.feel.com.gt/fel/certificacion/v2/dte`

### Pendientes para producción

- Agregar NIT fiscal al modelo `Cliente`; mientras no exista, el receptor se genera como `CF`.
- Agregar detalle de factura para certificar múltiples ítems reales.
- Validar el XML generado contra el esquema exacto solicitado por INFILE.
- Confirmar ambiente sandbox/producción y credenciales reales.
- Agregar anulación FEL cuando el negocio defina el flujo de inhabilitación/anulación.

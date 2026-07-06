class RegistrarModuloSistema
  def self.call(codigo:, nombre:, descripcion:, ruta:, grupo:, activo: true)
    new(
      codigo: codigo,
      nombre: nombre,
      descripcion: descripcion,
      ruta: ruta,
      grupo: grupo,
      activo: activo
    ).call
  end

  def initialize(codigo:, nombre:, descripcion:, ruta:, grupo:, activo: true)
    @attributes = {
      codigo: codigo,
      nombre: nombre,
      descripcion: descripcion,
      ruta: ruta,
      grupo: grupo,
      activo: activo
    }
  end

  def call
    modulo = ModuloSistema.find_or_initialize_by(codigo: @attributes[:codigo])
    modulo.assign_attributes(@attributes)
    modulo.save!
    modulo
  end
end

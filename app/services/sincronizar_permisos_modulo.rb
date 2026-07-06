class SincronizarPermisosModulo
  def self.call(modulo_sistema)
    new(modulo_sistema).call
  end

  def initialize(modulo_sistema)
    @modulo_sistema = modulo_sistema
  end

  def call
    Rol.find_each do |rol|
      rol.permisos.find_or_create_by!(modulo_sistema: modulo_sistema)
    end
  end

  private

  attr_reader :modulo_sistema
end

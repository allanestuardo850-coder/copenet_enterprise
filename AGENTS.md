# Copenet Enterprise - Codex Instructions

## Proyecto

Este repositorio es una base empresarial en Ruby on Rails 8.1 para construir sistemas administrativos, financieros, cooperativos, CRM, ERP, logística y módulos empresariales reutilizables.

## Stack

- Ruby 3.3.8
- Rails 8.1
- PostgreSQL
- Hotwire / Turbo / Stimulus
- Tailwind CSS si está disponible
- Arquitectura modular
- GitHub como control de versiones

## Reglas de desarrollo

- No modificar código sin explicar el cambio.
- No usar sudo.
- No cambiar versión de Ruby sin autorización.
- No cambiar Gemfile sin explicar por qué.
- No eliminar archivos existentes sin justificarlo.
- Usar `bundle exec` para comandos Rails.
- Mantener commits pequeños y claros.
- Separar lógica de negocio fuera de controladores.
- Preferir servicios, queries, policies y forms cuando aplique.

## Arquitectura esperada

Crear y mantener estas carpetas cuando sean necesarias:

- app/services
- app/queries
- app/forms
- app/policies
- app/presenters
- app/decorators
- app/validators
- app/view_models

## Primer objetivo del sistema

Construir una plataforma empresarial base con:

- Empresas
- Sucursales
- Usuarios
- Roles
- Permisos
- Auditoría
- Dashboard
- Menú administrativo
- Catálogos configurables

## Comandos de verificación

Antes de proponer cambios grandes, verificar:

```bash
bundle install
bundle exec rails db:migrate
bundle exec rails test

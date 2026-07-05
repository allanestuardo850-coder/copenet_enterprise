module EnterpriseHelper
  def icon(name)
    icons = {
      "dashboard" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3 13.2c0-.58.47-1.05 1.05-1.05h5.1c.58 0 1.05.47 1.05 1.05v6.75c0 .58-.47 1.05-1.05 1.05h-5.1A1.05 1.05 0 0 1 3 19.95zm10.8-9.15c0-.58.47-1.05 1.05-1.05h5.1c.58 0 1.05.47 1.05 1.05v4.65c0 .58-.47 1.05-1.05 1.05h-5.1a1.05 1.05 0 0 1-1.05-1.05zm0 9.15c0-.58.47-1.05 1.05-1.05h5.1c.58 0 1.05.47 1.05 1.05v6.75c0 .58-.47 1.05-1.05 1.05h-5.1a1.05 1.05 0 0 1-1.05-1.05zM3 4.05C3 3.47 3.47 3 4.05 3h5.1c.58 0 1.05.47 1.05 1.05v4.65c0 .58-.47 1.05-1.05 1.05h-5.1A1.05 1.05 0 0 1 3 8.7z"/></svg>',
      "building" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4.5 21a1.5 1.5 0 0 1-1.5-1.5v-12A1.5 1.5 0 0 1 4.5 6H9V4.5A1.5 1.5 0 0 1 10.5 3h9A1.5 1.5 0 0 1 21 4.5v15a1.5 1.5 0 0 1-1.5 1.5zM6 9v3h3V9zm0 6v3h3v-3zm6-6v3h3V9zm0 6v3h3v-3zm6-6v3h0V9zm0 6v3h0v-3z"/></svg>',
      "wallet" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4.5 6A2.5 2.5 0 0 0 2 8.5v7A2.5 2.5 0 0 0 4.5 18H19a3 3 0 0 0 3-3v-1.5A3.5 3.5 0 0 0 18.5 10H6.75A.75.75 0 0 1 6 9.25v-.5A.75.75 0 0 1 6.75 8H21V6zm13.75 7.5a1.25 1.25 0 1 1 0 2.5 1.25 1.25 0 0 1 0-2.5"/></svg>',
      "box" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="m12 2 8 4.5v11L12 22l-8-4.5v-11zm0 2.27L6.36 7 12 9.73 17.64 7zm6 4.05-5 2.5v8.22l5-2.81zM11 19.04v-8.22l-5-2.5v8.41z"/></svg>',
      "coins" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 4c-4.42 0-8 1.57-8 3.5S7.58 11 12 11s8-1.57 8-3.5S16.42 4 12 4m-8 6v4.5C4 16.43 7.58 18 12 18s8-1.57 8-3.5V10c-1.63 1.35-4.71 2.25-8 2.25S5.63 11.35 4 10m0 7v.5C4 19.43 7.58 21 12 21s8-1.57 8-3.5V17c-1.63 1.35-4.71 2.25-8 2.25S5.63 18.35 4 17"/></svg>',
      "receipt" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6 3h12a1 1 0 0 1 1 1v17l-3-2-3 2-3-2-3 2-3-2V4a1 1 0 0 1 1-1m3 4v2h6V7zm0 4v2h6v-2z"/></svg>',
      "invoice" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M7 3h7l5 5v11.5A1.5 1.5 0 0 1 17.5 21h-10A1.5 1.5 0 0 1 6 19.5v-15A1.5 1.5 0 0 1 7.5 3m6 1.5V9h4.5zM9 12v1.5h6V12zm0 3v1.5h6V15z"/></svg>',
      "contract" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6 2h9l5 5v13a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2m7 1.5V8h4.5zM8 12h8v1.5H8zm0 3h8v1.5H8z"/></svg>',
      "report" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 3h14a2 2 0 0 1 2 2v14l-4-3-4 3-4-3-4 3V5a2 2 0 0 1 2-2m2 4v7h2V7zm4 3v4h2v-4zm4-2v6h2V8z"/></svg>',
      "settings" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="m19.5 12 .89 1.78-1.61 2.79-2.05-.26a7.5 7.5 0 0 1-1.54.9l-.52 2.02h-3.22l-.52-2.02a7.5 7.5 0 0 1-1.54-.9l-2.05.26-1.61-2.79L4.5 12l-.89-1.78 1.61-2.79 2.05.26c.47-.36.99-.66 1.54-.9l.52-2.02h3.22l.52 2.02c.55.24 1.07.54 1.54.9l2.05-.26 1.61 2.79zM12 9a3 3 0 1 0 0 6 3 3 0 0 0 0-6"/></svg>',
      "search" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M10.5 4a6.5 6.5 0 0 1 5.16 10.46l4.19 4.19-1.06 1.06-4.19-4.19A6.5 6.5 0 1 1 10.5 4m0 1.5a5 5 0 1 0 0 10 5 5 0 0 0 0-10"/></svg>',
      "bell" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 22a2.5 2.5 0 0 0 2.45-2h-4.9A2.5 2.5 0 0 0 12 22m6-6V11a6 6 0 1 0-12 0v5l-2 2v1h16v-1z"/></svg>',
      "menu" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 7h16v2H4zm0 5h16v2H4zm0 5h16v2H4z"/></svg>',
      "sun" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 5a1 1 0 0 1 1 1v1.2a1 1 0 1 1-2 0V6a1 1 0 0 1 1-1m0 10a3 3 0 1 0 0-6 3 3 0 0 0 0 6m7-4a1 1 0 0 1 0 2h-1.2a1 1 0 1 1 0-2zM7.4 12a1 1 0 0 1-1 1H5.2a1 1 0 1 1 0-2h1.2a1 1 0 0 1 1 1m8.49-4.49a1 1 0 0 1 1.42 0l.85.85a1 1 0 0 1-1.42 1.42l-.85-.85a1 1 0 0 1 0-1.42m-8.78 8.78a1 1 0 0 1 1.42 0l.85.85a1 1 0 0 1-1.42 1.42l-.85-.85a1 1 0 0 1 0-1.42m9.63 1.42a1 1 0 0 1-1.42-1.42l.85-.85a1 1 0 0 1 1.42 1.42zM8.53 8.53A1 1 0 0 1 7.1 7.1l.85-.85a1 1 0 1 1 1.42 1.42z"/></svg>',
      "moon" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M14.5 3.5a8.5 8.5 0 1 0 6 14.51A9 9 0 1 1 14.5 3.5"/></svg>',
      "chevron" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="m9 6 6 6-6 6-1.06-1.06L12.88 12 7.94 7.06z"/></svg>'
    }

    icons.fetch(name.to_s, icons["dashboard"]).html_safe
  end

  def sidebar_item_classes(active)
    classes = ["sidebar-item"]
    classes << "is-active" if active
    classes.join(" ")
  end

  def badge_classes(tone = "primary")
    "badge badge-#{tone}"
  end

  def status_badge_tone(value)
    case value
    when "Activa", "Activo", "Disponible", "Completado", "Emitida", "Cobrado", "Aprobado"
      "success"
    when "Pendiente", "Renovación", "En gestión", "Borrador", "Programado", "Prospecto", "Atención"
      "warning"
    when "Vencido"
      "danger"
    else
      "info"
    end
  end
end

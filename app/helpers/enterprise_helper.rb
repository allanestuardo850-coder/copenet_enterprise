module EnterpriseHelper
  def icon(name)
    icons = {
      "dashboard" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3 13.2c0-.58.47-1.05 1.05-1.05h5.1c.58 0 1.05.47 1.05 1.05v6.75c0 .58-.47 1.05-1.05 1.05h-5.1A1.05 1.05 0 0 1 3 19.95zm10.8-9.15c0-.58.47-1.05 1.05-1.05h5.1c.58 0 1.05.47 1.05 1.05v4.65c0 .58-.47 1.05-1.05 1.05h-5.1a1.05 1.05 0 0 1-1.05-1.05zm0 9.15c0-.58.47-1.05 1.05-1.05h5.1c.58 0 1.05.47 1.05 1.05v6.75c0 .58-.47 1.05-1.05 1.05h-5.1a1.05 1.05 0 0 1-1.05-1.05zM3 4.05C3 3.47 3.47 3 4.05 3h5.1c.58 0 1.05.47 1.05 1.05v4.65c0 .58-.47 1.05-1.05 1.05h-5.1A1.05 1.05 0 0 1 3 8.7z"/></svg>',
      "home" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3 11.4 12 4l9 7.4V21h-6v-6H9v6H3z"/></svg>',
      "building" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4.5 21a1.5 1.5 0 0 1-1.5-1.5v-12A1.5 1.5 0 0 1 4.5 6H9V4.5A1.5 1.5 0 0 1 10.5 3h9A1.5 1.5 0 0 1 21 4.5v15a1.5 1.5 0 0 1-1.5 1.5zM6 9v3h3V9zm0 6v3h3v-3zm6-6v3h3V9zm0 6v3h3v-3zm6-6v3h0V9zm0 6v3h0v-3z"/></svg>',
      "users" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M16 11a4 4 0 1 0-4-4 4 4 0 0 0 4 4m-8 1a3 3 0 1 0-3-3 3 3 0 0 0 3 3m8 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4m-8 0c-.34 0-.71.02-1.11.05C4.01 14.25 1 15.48 1 18v2h5v-2c0-1.46.8-2.69 2-3.58A9 9 0 0 0 8 14"/></svg>',
      "shield" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 2 4 5v6c0 5.25 3.4 10.74 8 12 4.6-1.26 8-6.75 8-12V5zm-1 6h2v5h-2zm0 7h2v2h-2z"/></svg>',
      "layers" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="m12 3 9 4.5-9 4.5-9-4.5zm0 8 9 4.5-9 4.5-9-4.5zm0 4 9 4.5-9 4.5-9-4.5z"/></svg>',
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
      "message" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 5.5A2.5 2.5 0 0 1 6.5 3h11A2.5 2.5 0 0 1 20 5.5v8a2.5 2.5 0 0 1-2.5 2.5H10l-4.5 4v-4H6.5A2.5 2.5 0 0 1 4 13.5zm3.5 2a.75.75 0 0 0 0 1.5h9a.75.75 0 0 0 0-1.5zm0 3.5a.75.75 0 0 0 0 1.5h6a.75.75 0 0 0 0-1.5z"/></svg>',
      "grid" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 4h6v6H4zm10 0h6v6h-6zM4 14h6v6H4zm10 0h6v6h-6z"/></svg>',
      "menu" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 7h16v2H4zm0 5h16v2H4zm0 5h16v2H4z"/></svg>',
      "sun" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 5a1 1 0 0 1 1 1v1.2a1 1 0 1 1-2 0V6a1 1 0 0 1 1-1m0 10a3 3 0 1 0 0-6 3 3 0 0 0 0 6m7-4a1 1 0 0 1 0 2h-1.2a1 1 0 1 1 0-2zM7.4 12a1 1 0 0 1-1 1H5.2a1 1 0 1 1 0-2h1.2a1 1 0 0 1 1 1m8.49-4.49a1 1 0 0 1 1.42 0l.85.85a1 1 0 0 1-1.42 1.42l-.85-.85a1 1 0 0 1 0-1.42m-8.78 8.78a1 1 0 0 1 1.42 0l.85.85a1 1 0 0 1-1.42 1.42l-.85-.85a1 1 0 0 1 0-1.42m9.63 1.42a1 1 0 0 1-1.42-1.42l.85-.85a1 1 0 0 1 1.42 1.42zM8.53 8.53A1 1 0 0 1 7.1 7.1l.85-.85a1 1 0 1 1 1.42 1.42z"/></svg>',
      "moon" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M14.5 3.5a8.5 8.5 0 1 0 6 14.51A9 9 0 1 1 14.5 3.5"/></svg>',
      "chevron" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="m9 6 6 6-6 6-1.06-1.06L12.88 12 7.94 7.06z"/></svg>',
      "chevron_down" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="m6.7 9.7 5.3 5.3 5.3-5.3 1.1 1.1-6.4 6.4-6.4-6.4z"/></svg>',
      "logout" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M10 17v-3H3v-4h7V7l5 5zm8 2h-6v2h6a2 2 0 0 0 2-2V5a2 2 0 0 0-2-2h-6v2h6z"/></svg>',
      "trending-up" => '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 17l6-6 4 4 8-8"/><path d="M15 7h6v6"/></svg>',
      "dollar" => '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M14.8 8.5a3 3 0 0 0-2.8-1.5c-1.5 0-2.7.9-2.7 2.2 0 1.1.8 1.7 2.6 2.1 2 .5 3 1.1 3 2.4 0 1.4-1.3 2.3-2.9 2.3a3.1 3.1 0 0 1-2.9-1.6M12 5.5v13"/></svg>',
      "alert" => '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M10.3 3.9 1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0Z"/><path d="M12 9v4"/><path d="M12 17h.01"/></svg>',
      "credit-card" => '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="2.5" y="5" width="19" height="14" rx="2.5"/><path d="M2.5 9.5h19"/><path d="M6 14.5h4"/></svg>',
      "calendar" => '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3.5" y="5.5" width="17" height="15" rx="2"/><path d="M3.5 9.5h17"/><path d="M8 3v4"/><path d="M16 3v4"/></svg>',
      "refresh" => '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 8a7.5 7.5 0 0 0-13.2-1.5M4 12a7.5 7.5 0 0 0 13.2 1.5"/><path d="M20 4v4h-4"/><path d="M4 20v-4h4"/></svg>',
      "file-text" => '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8Z"/><path d="M14 3v5h5"/><path d="M9 13h6"/><path d="M9 16.5h6"/></svg>',
      "coins-stack" => '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><ellipse cx="12" cy="6" rx="7.5" ry="3"/><path d="M4.5 6v6c0 1.7 3.4 3 7.5 3s7.5-1.3 7.5-3V6"/><path d="M4.5 12v6c0 1.7 3.4 3 7.5 3s7.5-1.3 7.5-3v-6"/></svg>',
      "user-group" => '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M15 19v-1a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v1"/><circle cx="8.5" cy="7" r="4"/><path d="M15.5 3.2a4 4 0 0 1 0 7.6"/><path d="M22 19v-1a4 4 0 0 0-3-3.8"/></svg>'
    }

    icons.fetch(name.to_s, icons["dashboard"]).html_safe
  end

  def sidebar_item_classes(active)
    classes = ["sidebar-item"]
    classes << "is-active" if active
    classes.join(" ")
  end

  def sidebar_section_classes(open)
    classes = ["sidebar-section"]
    classes << "is-open" if open
    classes.join(" ")
  end

  def sidebar_icon(name)
    icons = {
      "dashboard" => '<svg viewBox="0 0 24 24" aria-hidden="true"><rect x="4" y="4" width="6.5" height="6.5" rx="1.6"/><rect x="13.5" y="4" width="6.5" height="6.5" rx="1.6"/><rect x="4" y="13.5" width="6.5" height="6.5" rx="1.6"/><rect x="13.5" y="13.5" width="6.5" height="6.5" rx="1.6"/></svg>',
      "building" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 21V5.8A1.8 1.8 0 0 1 6.8 4h7.4A1.8 1.8 0 0 1 16 5.8V21"/><path d="M16 9h2.2A1.8 1.8 0 0 1 20 10.8V21"/><path d="M3 21h18"/><path d="M8 8h2.2M8 12h2.2M8 16h2.2"/></svg>',
      "users" => '<svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="9" cy="8" r="3.4"/><path d="M3.8 20a5.2 5.2 0 0 1 10.4 0"/><path d="M15.4 6.2a3.1 3.1 0 0 1 0 5.6"/><path d="M16.8 14.4a5 5 0 0 1 3.4 4.8"/></svg>',
      "shield" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3.5 5.2 6.2v5.4c0 4.6 2.9 8.4 6.8 9.9 3.9-1.5 6.8-5.3 6.8-9.9V6.2Z"/><path d="m9.2 12.1 1.9 1.9 3.9-4.1"/></svg>',
      "coins" => '<svg viewBox="0 0 24 24" aria-hidden="true"><ellipse cx="12" cy="6.5" rx="6.8" ry="3"/><path d="M5.2 6.5v5.2c0 1.7 3 3 6.8 3s6.8-1.3 6.8-3V6.5"/><path d="M5.2 12v5.2c0 1.7 3 3 6.8 3s6.8-1.3 6.8-3V12"/></svg>',
      "layers" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="m12 4 8 4-8 4-8-4Z"/><path d="m4 12 8 4 8-4"/><path d="m4 16 8 4 8-4"/></svg>',
      "settings" => '<svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="3.2"/><path d="M19.2 13.5a7.8 7.8 0 0 0 .1-3l2-1.5-2-3.4-2.4 1a8 8 0 0 0-2.6-1.5L14 2.5h-4l-.4 2.6A8 8 0 0 0 7 6.6l-2.4-1-2 3.4 2 1.5a7.8 7.8 0 0 0 .1 3l-2.1 1.5 2 3.4 2.5-1a8 8 0 0 0 2.5 1.5l.4 2.6h4l.4-2.6a8 8 0 0 0 2.5-1.5l2.5 1 2-3.4Z"/></svg>',
      "receipt" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6.5 3.5h11A1.5 1.5 0 0 1 19 5v15.5l-2.4-1.5-2.3 1.5-2.3-1.5-2.3 1.5L7.4 19 5 20.5V5a1.5 1.5 0 0 1 1.5-1.5Z"/><path d="M8.5 8h7M8.5 12h7M8.5 16h4"/></svg>',
      "report" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 4.5h14v15H5z"/><path d="M8.5 15.5v-4M12 15.5v-7M15.5 15.5v-5.2"/><path d="M8 18h8"/></svg>',
      "wallet" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4.5 7.2h14A2.5 2.5 0 0 1 21 9.7v7.1a2.5 2.5 0 0 1-2.5 2.5h-14A2.5 2.5 0 0 1 2 16.8V9.7a2.5 2.5 0 0 1 2.5-2.5Z"/><path d="M5 7.2V5.7A2 2 0 0 1 7.3 3.8l9.4 1.6"/><path d="M17.6 12.2h.1"/></svg>',
      "box" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="m12 3.5 7.5 4.2v8.6L12 20.5l-7.5-4.2V7.7Z"/><path d="m4.8 7.8 7.2 4.1 7.2-4.1"/><path d="M12 12v8.2"/></svg>',
      "invoice" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M7 3.5h7.5L19 8v12.5H7z"/><path d="M14.5 3.5V8H19"/><path d="M9.5 12.5h5M9.5 16h5"/></svg>',
      "contract" => '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6.5 3.5h8L19 8v12.5H6.5z"/><path d="M14.5 3.5V8H19"/><path d="M9 12h6M9 15.5h6"/><path d="m9 19 1.2-1.2 1.1 1.1 1.7-1.9"/></svg>'
    }

    icons.fetch(name.to_s, icons["dashboard"]).html_safe
  end

  def navigation_section_open?(item, current_page)
    item.fetch(:children, []).any? { |child| child[:key] == current_page }
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

  TONE_COLORS = {
    "primary" => "var(--primary)",
    "success" => "var(--success)",
    "warning" => "var(--warning)",
    "danger" => "var(--danger)",
    "info" => "var(--info)"
  }.freeze

  def tone_color(tone)
    TONE_COLORS.fetch(tone.to_s, "var(--primary)")
  end

  # Grafica combinada de barras (dos series) con linea de tendencia superpuesta.
  def dashboard_barline_chart(months:, ingresos:, costos:, utilidad:, max:)
    left, right, top, bottom = 74, 1088, 16, 238
    plot_h = bottom - top
    n = months.size
    slot = (right - left).to_f / n
    y = ->(v) { (bottom - (v.to_f / max) * plot_h).round(1) }
    steps = (0..3).map { |i| (max * i / 3.0).round }

    svg = +%(<svg viewBox="0 0 1160 284" class="dash-chart dash-chart-bars" preserveAspectRatio="xMidYMid meet" role="img" aria-label="Resumen financiero mensual">)
    steps.each do |v|
      gy = y.call(v)
      svg << %(<line x1="#{left}" y1="#{gy}" x2="#{right}" y2="#{gy}" class="dash-grid"/>)
      svg << %(<text x="#{left - 12}" y="#{gy + 4}" class="dash-axis dash-axis-end">Q#{v}k</text>)
      svg << %(<text x="#{right + 12}" y="#{gy + 4}" class="dash-axis">Q#{v}k</text>)
    end

    n.times do |i|
      cx = left + slot * (i + 0.5)
      iy = y.call(ingresos[i])
      cy = y.call(costos[i])
      svg << %(<rect x="#{(cx - 38).round(1)}" y="#{iy}" width="31" height="#{(bottom - iy).round(1)}" rx="7" fill="var(--primary)"/>)
      svg << %(<rect x="#{(cx + 2).round(1)}" y="#{cy}" width="31" height="#{(bottom - cy).round(1)}" rx="7" fill="var(--primary)" opacity="0.28"/>)
      svg << %(<text x="#{cx.round(1)}" y="#{bottom + 26}" class="dash-axis dash-axis-mid">#{months[i]}</text>)
    end

    points = n.times.map { |i| "#{(left + slot * (i + 0.5)).round(1)},#{y.call(utilidad[i])}" }
    svg << %(<polyline points="#{points.join(' ')}" fill="none" stroke="var(--success)" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>)
    n.times do |i|
      cx = (left + slot * (i + 0.5)).round(1)
      svg << %(<circle cx="#{cx}" cy="#{y.call(utilidad[i])}" r="4" fill="var(--surface-strong)" stroke="var(--success)" stroke-width="2.5"/>)
    end
    svg << "</svg>"
    svg.html_safe
  end

  # Donut proporcional a partir de segmentos { value:, tone: }.
  def dashboard_donut_chart(segments:)
    cx = cy = 80
    r = 52
    total = segments.sum { |s| s[:value].to_f }
    total = 1 if total.zero?
    angle = -90.0
    gap = 1.8
    point = lambda do |degrees|
      radians = degrees * Math::PI / 180.0
      [ (cx + r * Math.cos(radians)).round(2), (cy + r * Math.sin(radians)).round(2) ]
    end

    svg = +%(<svg viewBox="0 0 160 160" class="dash-donut" role="img" aria-label="Estado de cartera">)
    segments.each do |seg|
      frac = seg[:value].to_f / total
      sweep = frac * 360.0
      start_angle = angle + gap / 2.0
      end_angle = angle + sweep - gap / 2.0
      end_angle = start_angle if end_angle < start_angle
      start_x, start_y = point.call(start_angle)
      end_x, end_y = point.call(end_angle)
      large_arc = (end_angle - start_angle) > 180 ? 1 : 0

      svg << %(<path d="M #{start_x} #{start_y} A #{r} #{r} 0 #{large_arc} 1 #{end_x} #{end_y}" )
      svg << %(fill="none" stroke="#{tone_color(seg[:tone])}" stroke-width="24" stroke-linecap="butt"/>)
      angle += sweep
    end
    svg << "</svg>"
    svg.html_safe
  end

  # Grafica de lineas multiples { tone:, values: [...] }.
  def dashboard_trend_chart(months:, series:, max:)
    left, right, top, bottom = 62, 1420, 16, 210
    plot_h = bottom - top
    n = months.size
    x = ->(i) { (left + (right - left) * (i.to_f / (n - 1))).round(1) }
    y = ->(v) { (bottom - (v.to_f / max) * plot_h).round(1) }
    steps = (0..3).map { |i| (max * i / 3.0).round }

    svg = +%(<svg viewBox="0 0 1480 242" class="dash-chart dash-chart-trend" role="img" aria-label="Tendencia de facturación">)
    steps.each do |v|
      gy = y.call(v)
      svg << %(<line x1="#{left}" y1="#{gy}" x2="#{right}" y2="#{gy}" class="dash-grid"/>)
      svg << %(<text x="#{left - 10}" y="#{gy + 4}" class="dash-axis dash-axis-end">Q#{v}k</text>)
    end
    n.times do |i|
      svg << %(<text x="#{x.call(i)}" y="#{bottom + 22}" class="dash-axis dash-axis-mid">#{months[i]}</text>)
    end
    series.each do |serie|
      color = tone_color(serie[:tone])
      points = n.times.map { |i| "#{x.call(i)},#{y.call(serie[:values][i])}" }
      svg << %(<polyline points="#{points.join(' ')}" fill="none" stroke="#{color}" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>)
      n.times do |i|
      svg << %(<circle cx="#{x.call(i)}" cy="#{y.call(serie[:values][i])}" r="4.2" fill="var(--surface-strong)" stroke="#{color}" stroke-width="2.2"/>)
      end
    end
    svg << "</svg>"
    svg.html_safe
  end
end

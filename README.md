# Control de horas de capacitación · GOLA Cancún

Consulta de horas de capacitación a partir del reporte de todos los cursos de Coursebox.

- **Consultar:** abre el sitio y escribe la contraseña que te compartieron.
- **Actualizar (administrador):** abre el sitio con `#actualizar`, importa el CSV `all-courses_report_*.csv`, revisa las duraciones y genera `datos.enc.json`. Súbelo a este repositorio reemplazando el anterior.

Los datos se publican cifrados (AES-256-GCM, clave derivada con PBKDF2-SHA256, 310 000 iteraciones). Nunca subas aquí el CSV ni el Excel: el repositorio es público.

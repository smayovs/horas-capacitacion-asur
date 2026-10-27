# Control de horas de capacitación · GOLA Cancún

Consulta de horas de capacitación a partir del reporte de todos los cursos de Coursebox.

- **Consultar:** abre el sitio y escribe la contraseña que te compartieron.
- **Actualizar (administrador):** abre https://smayovs.github.io/horas-capacitacion-asur/#actualizar (el enlace no aparece en la página para no confundir a los compañeros). Importa el CSV `all-courses_report_*.csv`, revisa las duraciones y sigue los cuatro pasos de “Publicar”: contraseña, descargar `datos.enc.json`, subirlo aquí y verificar.
- **Compartir una vista:** los filtros quedan en la dirección (por ejemplo `#cursos?area=CREI`), así que puedes copiar y enviar el enlace.

Los datos se publican cifrados (AES-256-GCM, clave derivada con PBKDF2-SHA256, 310 000 iteraciones). Nunca subas aquí el CSV ni el Excel: el repositorio es público.

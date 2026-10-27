# Control de horas de capacitación · GOLA Cancún

Consulta de horas de capacitación a partir del reporte de todos los cursos de Coursebox.

- **Entrar:** abre el sitio, escribe tu correo @asur.com.mx y abre el enlace que llega a tu correo. Solo entran las personas que un administrador haya agregado.
- **Actualizar (administradores):** pestaña Actualizar → sube el CSV `all-courses_report_*.csv` → revisa las duraciones → Publicar. Funciona desde cualquier equipo; no hace falta GitHub.
- **Usuarios (administradores):** agrega o quita correos y elige el perfil Consulta o Administrador. Siempre queda al menos un administrador.

Los datos y los usuarios viven en Supabase (proyecto `aepiqogklpqkfjicwqlx`). El esquema y los permisos están en `supabase/esquema.sql`; la clave que aparece en la página es la publicable, pública por diseño. Nunca subas aquí el CSV, el Excel ni la clave secreta.

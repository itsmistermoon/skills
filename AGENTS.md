# imaq-skills

Repositorio de respaldo y desarrollo de las skills de Claude para Imaquinaria. Este repo es la fuente de verdad versionada; desde aquí se sincroniza hacia la instalación global (`~/.agents/skills/`).

## Skills

- **skills/imaquinaria-brand**: identidad visual de marca (colores, tipografía, logo, componentes) para el programa de loyalty y todo material branded. Incluye `assets/` (logo, ícono, wordmark) y `references/` (guías por superficie: web, email, print, social, componentes).
- **skills/viralize**: fórmula "creencia falsa → hook → verdad" para crear contenido viral en redes sociales.

## Convenciones

- Cada skill vive en `skills/<nombre>/` con un `SKILL.md` obligatorio (frontmatter `name` + `description`).
- El `name` del frontmatter debe coincidir con el nombre de la carpeta.
- Assets binarios de marca van en `assets/`; documentación de referencia extensa va en `references/`, separada por archivo según el tema.

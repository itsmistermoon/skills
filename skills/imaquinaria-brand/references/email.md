# Email Transaccional — HTML Email

Imaquinaria envía emails vía AWS SES. Los emails HTML deben funcionar en Gmail,
Outlook, Apple Mail y clientes móviles. CSS en HTML email es limitado — sin
variables CSS, sin flexbox en Outlook, sin fuentes web en la mayoría de clientes.

## Paleta hardcodeada para email (sin var())

```
Fondo de página:     #F5F4F2
Superficie (card):   #FFFFFF
Texto principal:     #211A23
Texto secundario:    #5A5258
Acento / CTA:        #E81036
Acento hover*:       #B90C2B   (* usar en VML para Outlook)
Premium:             #4D2559
Borde:               #E2DFE0
```

## Estructura base

```html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{asunto}}</title>
  <style>
    body { margin:0; padding:0; background:#F5F4F2;
           font-family: Arial, sans-serif; }
    /* Fuente de fallback: Arial. Nunca depender de Archivo en email. */
  </style>
</head>
<body bgcolor="#F5F4F2">
  <table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#F5F4F2">
    <tr><td align="center" style="padding: 32px 16px;">

      <!-- Card principal -->
      <table width="560" cellpadding="0" cellspacing="0" border="0"
             style="background:#FFFFFF; border-radius:16px; overflow:hidden;
                    border: 1px solid #E2DFE0;">

        <!-- Header con logo -->
        <tr>
          <td align="center" style="padding: 24px 32px 20px; border-bottom: 1px solid #E2DFE0;">
            <!-- Logo: usar URL absoluta en producción -->
            <img src="https://cdn.loyalty.app/imaquinaria/logo.png"
                 alt="Imaquinaria" width="160" height="auto"
                 style="display:block; border:0;">
          </td>
        </tr>

        <!-- Cuerpo -->
        <tr>
          <td style="padding: 32px;">
            <!-- Título -->
            <h1 style="margin:0 0 16px; font-family:Arial,sans-serif; font-weight:800;
                       font-size:22px; color:#211A23; text-transform:uppercase;
                       letter-spacing:0.02em;">
              {{titulo}}
              <!-- Nota: Arial 800 uppercase es el sustituto de League Spartan en email -->
            </h1>

            <!-- Cuerpo de texto -->
            <p style="margin:0 0 16px; font-family:Arial,sans-serif; font-size:14px;
                      line-height:1.6; color:#5A5258;">
              {{cuerpo}}
            </p>

            <!-- CTA principal -->
            <table cellpadding="0" cellspacing="0" border="0" style="margin: 24px 0;">
              <tr>
                <td bgcolor="#E81036" style="border-radius:10px;">
                  <a href="{{url_cta}}"
                     style="display:inline-block; padding:12px 24px;
                            font-family:Arial,sans-serif; font-size:14px;
                            font-weight:700; color:#FFFFFF; text-decoration:none;">
                    {{texto_cta}}
                  </a>
                </td>
              </tr>
            </table>
          </td>
        </tr>

        <!-- Footer -->
        <tr>
          <td style="padding: 20px 32px; background:#F5F4F2;
                     border-top: 1px solid #E2DFE0; text-align:center;">
            <p style="margin:0; font-family:Arial,sans-serif; font-size:11px;
                      color:#5A5258; line-height:1.5;">
              Imaquinaria · Andrés Bello 724 of. 2, Temuco, Chile<br>
              <a href="{{url_baja}}" style="color:#E81036;">Cancelar suscripción</a>
              &nbsp;·&nbsp;
              <a href="{{url_privacidad}}" style="color:#E81036;">Política de privacidad</a>
            </p>
          </td>
        </tr>

      </table>
    </td></tr>
  </table>
</body>
</html>
```

## Variantes de email por tipo

### Transaccional (confirmación de compra / canje)
- Header: logo + fondo blanco
- Destacar puntos ganados con color `#E81036` y tamaño mayor
- Incluir nivel actual del cliente
- Si se subió de nivel: bloque destacado con fondo `#4D2559`, texto blanco

### Bienvenida (registro nuevo)
- Mostrar nivel inicial (Rōnin) con su emoji 🗡️
- Explicar brevemente los 4 niveles en tabla simple
- CTA: "Ir al portal" → URL del frontend

### Recordatorio / marketing (solo con consent_marketing=true)
- Asunto corto, en español chileno
- Destacar beneficio concreto (puntos por vencer, nueva stamp card)
- Un solo CTA — no múltiples llamadas a la acción

## Reglas de email

- Ancho máximo del card: **560px** (compatible con Outlook)
- Siempre incluir versión texto plano
- Imágenes con `alt` descriptivo siempre
- Sin CSS externo ni `<link>` — todo inline o en `<style>` del head
- Sin JavaScript
- Probar en Gmail, Outlook 2016+ y Apple Mail antes de enviar
- El logo debe cargarse desde URL absoluta en producción (no relativa)

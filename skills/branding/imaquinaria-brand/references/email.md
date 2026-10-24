# Transactional Email — HTML Email

Imaquinaria sends email via AWS SES. HTML emails must work in Gmail, Outlook, Apple Mail and mobile clients. CSS in HTML email is limited — no CSS variables, no flexbox in Outlook, no web fonts in most clients.

## Hardcoded email palette (no var())

```
Page background:     #F5F4F2
Surface (card):      #FFFFFF
Primary text:        #211A23
Secondary text:      #5A5258
Accent / CTA:        #E81036
Accent hover*:       #B90C2B   (* use in VML for Outlook)
Premium:             #4D2559
Border:              #E2DFE0
```

## Base structure

Customer-facing copy in this template (footer links, the sample address, and the CTA label) is Spanish, because the audience is Chilean. Placeholders such as `{{titulo}}` are template variables that code fills in; keep their names in sync with the sending code.

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
    /* Fallback font: Arial. Never rely on Archivo in email. */
  </style>
</head>
<body bgcolor="#F5F4F2">
  <table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#F5F4F2">
    <tr><td align="center" style="padding: 32px 16px;">

      <!-- Main card -->
      <table width="560" cellpadding="0" cellspacing="0" border="0"
             style="background:#FFFFFF; border-radius:16px; overflow:hidden;
                    border: 1px solid #E2DFE0;">

        <!-- Header with logo -->
        <tr>
          <td align="center" style="padding: 24px 32px 20px; border-bottom: 1px solid #E2DFE0;">
            <!-- Logo: use an absolute URL in production -->
            <img src="https://cdn.loyalty.app/imaquinaria/logo.png"
                 alt="Imaquinaria" width="160" height="auto"
                 style="display:block; border:0;">
          </td>
        </tr>

        <!-- Body -->
        <tr>
          <td style="padding: 32px;">
            <!-- Title -->
            <h1 style="margin:0 0 16px; font-family:Arial,sans-serif; font-weight:800;
                       font-size:22px; color:#211A23; text-transform:uppercase;
                       letter-spacing:0.02em;">
              {{titulo}}
              <!-- Note: Arial 800 uppercase is the substitute for League Spartan in email -->
            </h1>

            <!-- Body text -->
            <p style="margin:0 0 16px; font-family:Arial,sans-serif; font-size:14px;
                      line-height:1.6; color:#5A5258;">
              {{cuerpo}}
            </p>

            <!-- Primary CTA -->
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

## Email variants by type

### Transactional (purchase / redemption confirmation)
- Header: logo + white background
- Highlight points earned in `#E81036`, at a larger size
- Include the customer's current level
- If the customer leveled up: a highlighted block with background `#4D2559` and white text

### Welcome (new sign-up)
- Show the starting level (Rōnin) with its emoji 🗡️
- Briefly explain the 4 levels in a simple table
- CTA: "Ir al portal" ("Go to portal") → frontend URL

### Reminder / marketing (only with consent_marketing=true)
- Short subject line, in Chilean Spanish
- Highlight a concrete benefit (points about to expire, new stamp card)
- A single CTA — no multiple calls to action

## Email rules

- Maximum card width: **560px** (compatible with Outlook)
- Always include a plain-text version
- Images always have a descriptive `alt`
- No external CSS or `<link>` — everything inline or in the `<style>` in the head
- No JavaScript
- Test in Gmail, Outlook 2016+ and Apple Mail before sending
- The logo must load from an absolute URL in production (not a relative one)

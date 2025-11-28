# App visual tokens — Mercedes Analytics (mobile)

This file lists the primary color tokens and reasoning used for the Flutter mobile app under `/app`.

Why this palette?
- Clean, professional tone: a deep teal-blue was chosen as a single strong accent for CTAs and highlights — it reads well on light backgrounds and aligns with an enterprise analytics product.
- Neutral greys: a set of muted greys helps keep content dense (more data per screen) without visual fatigue.
- Small set of feedback colors (success / warning / danger) for consistent state indicators & badges.

Main tokens (in `app/lib/ui/theme.dart`)
- primary: #006D77 — primary accent (buttons, highlights)
- background: #FFFFFF — true white app background (matches desktop)
- surface: #FFFFFF — cards / panels
- divider: #E6E9EE — separators
- textPrimary: #111827 — primary text
- textSecondary: #6B7280 — muted text

Usage guidelines (short):
- Use compact cards with small elevation and rounded corners to mimic the web dashboard's card pattern.
- Accent color should be reserved for primary actions and important highlights (do not overuse).
- Prefer concise microcopy and small captions on data-dense screens to keep information visible at a glance.

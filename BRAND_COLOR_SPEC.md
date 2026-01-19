# 🎨 Flow Train – Brand Color & Gradient Specification

**Version:** Export B (LOCKED)  
**Status:** Production Ready  
**Last Updated:** January 2026

---

## 1️⃣ Primary Colors

### Flow Train Blue
**The dominant brand color. Use this as the primary accent everywhere.**

- **HEX:** `#2BAEE4`
- **RGB:** 90, 174, 228
- **HSL:** 195°, 78%, 62%
- **Usage:** Primary buttons, links, headings, brand mark

### Dark Purple (Brand Accent)
**Secondary color. Supports Blue only—never replaces it.**

- **HEX:** `#5A4FCF`
- **RGB:** 90, 79, 207
- **HSL:** 245°, 57%, 56%

#### Purple Usage Rules
✅ Use in gradients only (not large flat fills)  
✅ Supports Flow Train Blue  
✅ Never replace Blue as the primary brand color  
✅ Works on near-black backgrounds (#231F20 → #0E1116)

### Night Black (Dark Mode Base)
**Background color for all dark mode interfaces.**

- **HEX:** `#231F20`
- **RGB:** 35, 31, 32
- **HSL:** 345°, 6%, 13%

### Light Text
**Text color on dark backgrounds.**

- **HEX:** `#E6F4FA`
- **RGB:** 230, 244, 250
- **HSL:** 200°, 67%, 94%

---

## 2️⃣ Export B Gradient (LOCKED)

**Type:** Linear gradient  
**Angle:** 135° (top-left → bottom-right)

> *Note: In graphic tools, this may appear as 45° depending on coordinate system. Use visual orientation as reference.*

### Color Stops (Exact)

| Stop  | Color Name           | HEX       | RGB          | Purpose               |
|-------|----------------------|-----------|--------------|----------------------|
| 0%    | Flow Train Blue      | #2BAEE4   | 90, 174, 228 | Bright entry point   |
| 45%   | Teal Transition      | #3B8FCC   | 59, 143, 204 | Motion & flow        |
| 75%   | Brand Purple         | #5A4FCF   | 90, 79, 207  | Depth & sophistication |
| 100%  | Night Fade           | #231F20   | 35, 31, 32   | Clean dark falloff    |

### CSS Implementation

```css
--ft-gradient-primary: linear-gradient(
  135deg,
  #2BAEE4 0%,
  #3B8FCC 45%,
  #5A4FCF 75%,
  #231F20 100%
);
```

### Effect
- ✅ Bright clarity at entry point
- ✅ Motion and flow through teal
- ✅ Depth and sophistication via purple
- ✅ Clean transition into dark mode

---

## 3️⃣ Banner Overlay Composition (STANDARD)

**This specification applies to every banner being generated.**

### Background Stack (Layered)

1. **Base Fill:** #231F20
2. **Gradient Overlay:** Export B Gradient (above) at 20–35% opacity
3. **Star Field:** Subtle, randomized placement
4. **Silhouette:** Moon-lit mountain landscape (lower-right corner)
5. **Wordmark:** Primary banner only (see section 4)

### Banner Dimensions

- **Standard:** 1920 × 1080 px
- **Retina (2x):** 3840 × 2160 px

---

## 4️⃣ Wordmark Color Treatment

### Default Rendering (Preferred)

Single solid color:
- **Color:** Flow Train Blue `#2BAEE4`
- **Style:** Outlined path (no font substitution risk)

### Optional Hero Treatment (Main Banner ONLY)

Gradient text effect:
- **Top:** #2BAEE4 (Flow Train Blue)
- **Bottom:** #5A4FCF (Dark Purple)
- **Noise:** 1–2% to avoid banding
- **Restriction:** Use only on primary/hero banners, not secondary graphics

---

## 5️⃣ Color Palette Reference

| Component       | HEX       | Use Case                    |
|-----------------|-----------|----------------------------|
| Primary Blue    | #2BAEE4   | Buttons, links, accents     |
| Secondary Purple| #5A4FCF   | Gradients, depth            |
| Teal Transition | #3B8FCC   | Gradient stop only          |
| Night Black     | #231F20   | Dark backgrounds            |
| Light Text      | #E6F4FA   | Text on dark                |
| Border          | #3A3536   | Subtle dividers             |

---

## 6️⃣ Implementation Checklist

- [ ] All primary buttons use Flow Train Blue (#2BAEE4)
- [ ] Gradient overlays use Export B spec at correct angle
- [ ] Dark mode backgrounds use Night Black (#231F20)
- [ ] Text contrast verified (WCAG AA minimum)
- [ ] Purple only appears in gradients, never as large fill
- [ ] Wordmark uses outlined paths, not fonts
- [ ] Banner includes star field + mountain silhouette
- [ ] Retina assets (2x) provided for all banners

---

## 7️⃣ Design System Integration

This color specification is locked and integrated into:

- **CSS Variables:** `--ft-blue`, `--ft-purple`, `--ft-gradient-primary`
- **Microsite:** Dark mode theme with gradient accents
- **Documentation Kits:** Notion, Confluence, GitHub templates
- **Banner Assets:** SVG wordmark + PNG exports

**Do not deviate from these specifications without explicit approval.**

---

**Questions?** Refer to [BRAND_MANIFEST.md](BRAND_MANIFEST.md) for full brand guidelines.

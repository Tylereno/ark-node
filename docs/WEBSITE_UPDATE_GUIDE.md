# Website Update Guide: Industrial Pivot

**Purpose:** Update tylereno.me to match the new "Industrial Systems Architect" narrative

---

## Required Changes

### 1. Hero Section / Headline

**OLD (Remove):**
- "Student"
- "Nomad" 
- "Digital Nomad"
- "RV" / "Van" / "Bus"
- Any lifestyle imagery

**NEW (Use):**
```
Tyler Eno | Industrial Systems Architect
```

### 2. Professional Bio

**OLD (Remove):**
- References to "saving money"
- "Homelab"
- "Personal project"
- Lifestyle content

**NEW (Use):**

**Short Version (Twitter/LinkedIn):**
```
Tyler Eno is a systems architect specializing in sovereign infrastructure for disconnected and hostile environments. He is the lead developer of ARK, an autonomous server kernel designed to maintain operational continuity in DDIL (Denied, Degraded, Intermittent, Limited) scenarios. His work focuses on the intersection of industrial autonomy, edge resilience, and subsurface/aerospace computing.
```

**Long Version (Website About Page):**
```
About Tyler Eno

Tyler Eno is an industrial systems architect focused on solving the "Dark Site" problem: how to maintain enterprise-grade computing in environments where the cloud is a liability.

With a background in field-deployed infrastructure, Tyler designs systems that prioritize autonomy over connectivity. His flagship project, ARK (Autonomous Resilient Kernel), is a sovereign infrastructure stack engineered for high-latency, low-trust environments—from remote extraction sites to aerospace analogs.

Unlike traditional DevOps approaches that assume infinite power and bandwidth, Tyler's work centers on entropy-hardened architecture: systems that degrade gracefully, recover automatically without human intervention, and maintain data integrity during extended blackouts.

He is currently exploring applications of autonomous edge compute in the critical mineral supply chain (DLE) and commercial space sectors.
```

### 3. Project Section

**ARK Description:**
```
ARK: Autonomous Resilient Kernel

Sovereign Operational Technology (OT) for Denied, Degraded, Intermittent, and Limited (DDIL) environments. ARK provides enterprise-grade compute, storage, and logic execution at the extreme edge, capable of indefinite operation without external connectivity or human intervention.

Applications: Direct Lithium Extraction (DLE), remote mining operations, aerospace analog systems, subsurface exploration platforms.

[View CONOPS] [GitHub Repository]
```

### 4. Design Aesthetic

**Remove:**
- Playful colors
- Casual fonts
- Lifestyle photography
- "Fun" elements

**Add:**
- Stark, high-contrast design
- Engineering-focused layout
- Minimal color palette (black, white, gray)
- Professional typography
- Technical diagrams (if applicable)

### 5. Contact / CTA

**OLD:**
- "Let's chat!"
- "Get in touch"
- Casual language

**NEW:**
- "Contact for Industrial Partnerships"
- "Research Collaborations"
- "Fellowship Inquiries"

---

## Implementation Checklist

- [ ] Update hero section headline
- [ ] Replace bio with industrial narrative
- [ ] Update ARK project description
- [ ] Remove all lifestyle/casual language
- [ ] Update design to be more professional/stark
- [ ] Add link to CONOPS document
- [ ] Update contact section
- [ ] Test on mobile devices
- [ ] Verify all links work

---

## Files to Update

If using a static site generator (Jekyll, Hugo, etc.):
- `_config.yml` or `config.toml` (site title, description)
- `index.html` or `index.md` (hero section)
- `about.md` or `about.html` (bio)
- `projects.md` or portfolio section
- CSS files (design updates)

If using a framework (React, Next.js, etc.):
- Main page component
- About page component
- Project/portfolio component
- Global styles/CSS

---

## Key Messaging Points

1. **Problem:** Industrial operations fail when connectivity is severed
2. **Solution:** Sovereign OT layer for extreme edge deployments
3. **Validation:** 12+ months field testing via Mobile Node Alpha
4. **Applications:** Mining, DLE, aerospace, subsurface operations
5. **Philosophy:** "Software should be robust enough to run in the dark"

---

## Links to Include

- GitHub: [ARK Repository]
- CONOPS: [Link to CONOPS.md or CONOPS.pdf]
- Documentation: [Link to docs/]
- Contact: [Professional email]

---

**Remember:** The website should match the README. If someone reads your GitHub and then visits your site, they should see the same professional, industrial narrative—not a lifestyle blog.

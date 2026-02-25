# DayTrader Modern UI Refresh

## Goal
Modernize the DayTrader 7 web UI to look like a contemporary fintech trading platform, while keeping the entire Java EE backend stack untouched.

## What to change
- All JSP files in `daytrader-ee7-web/src/main/webapp/`
- All XHTML (JSF) files in the same directory
- All static HTML files (index.html, header.html, footer.html, contentHome.html, etc.)
- CSS files — create new modern stylesheets
- Remove FRAMESET-based layout, replace with modern responsive layout
- The `images/` directory — update or replace dated GIF/JPEG assets if needed

## What NOT to change
- Java source code (all .java files)
- Server configuration (server.xml, web.xml, persistence.xml)
- Maven build files (pom.xml) — do not change dependencies
- EJB/JPA/JAX-RS backend logic
- Database schemas

## Design Direction
- Clean, modern fintech look (think Robinhood, E*Trade modern UI)
- Dark mode with accent colors (green for gains, red for losses)
- Responsive design (works on mobile)
- Use only vanilla CSS (no npm/node build — this deploys on AIX/WebSphere Liberty)
- Keep all form actions, servlet mappings, and JSP/JSF EL expressions intact
- Preserve all existing functionality — just make it look modern

## Important
- The app uses both JSP (Servlet-based) and XHTML (JSF-based) pages
- Some pages have both versions (e.g., portfolio.jsp and portfolio.xhtml)
- The `*Img.jsp` files are the JSP versions, plain `*.jsp` are non-image versions
- Forms POST to servlets — keep all action URLs the same

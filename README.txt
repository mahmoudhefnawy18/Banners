SHOSHO BANNERS — PASSWORDLESS DASHBOARD (interim build)

1. In Supabase Authentication > Users, ensure your email is an existing confirmed user.
2. In Authentication > URL Configuration, add the final HTTPS GitHub Pages URL to Redirect URLs.
3. Publish index.html, config.js, icon.svg, manifest.webmanifest, sw.js to GitHub Pages.
4. Open the published site, enter your email, follow the sign-in link. The browser will retain your session.
5. This ZIP currently contains the PRIVATE DASHBOARD only. It does NOT yet include the public customer ordering page or image uploads. Do not expose the dashboard without authentication.
6. The new banner SQL tables are separate from Charge Log. Do not run schema.sql again if tables already exist.
7. Export CSV backups regularly.

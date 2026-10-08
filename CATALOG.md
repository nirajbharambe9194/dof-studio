# DoF Studio Professional Camera & Lens Catalog

The application includes a seeded manufacturer catalog covering major interchangeable-lens systems and representative current/recent bodies and lenses across Canon RF/RF-S, Nikon Z/F, Sony E, Fujifilm X/GFX, Panasonic L/Lumix G, OM System/Olympus Micro Four Thirds, Leica, Sigma, Pentax and Hasselblad XCD.

## Global vs personal data

- Manufacturer catalog entries are global records (`isCatalog=true`, `userId=null`).
- A signed-in user can click **Customize** on any manufacturer entry.
- Customize creates a private copy owned by that user.
- Private copies can be edited or deleted without changing the manufacturer catalog.
- Users can also create completely new camera/lens entries with **Add Custom**.

## Seed

From `backend`:

```powershell
npx prisma generate
npx prisma db push
npx prisma db seed
```

`start.bat` performs these steps automatically.

## Important

No database can truthfully contain literally every camera and lens ever sold worldwide without a maintained external product database. This seed is a broad built-in professional catalog for the major systems represented in the application. The custom catalog is deliberately included so users can add uncommon, legacy, regional, adapted, cinema, industrial, or newly released equipment.

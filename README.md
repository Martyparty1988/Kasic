# Kasa Pro

Moderní PWA aplikace pro správu fakturace a skladu, určená pro provozovatele vil s kompletním servisem pro hosty.

## Funkce

- **Fakturace:** Tvorba faktur s položkami, City Tax a exportem do JPEG
- **Správa skladu:** Sledování stavu zásob s automatickým odečítáním
- **Historie prodejů:** Ukládání a správa historie prodejů
- **PWA funkcionalita:** Funguje offline i online s možností instalace na zařízení
- **Tmavý režim:** Pro příjemnější práci v noci
- **Responsivní design:** Funguje na mobilech, tabletech i počítačích

## Technologie

- React.js
- TailwindCSS
- HTML2Canvas (pro export do JPEG)
- LocalStorage (pro ukládání dat)
- Service Worker (pro PWA funkcionalitu)

## Instalace a spuštění

### Předpoklady
- Node.js 14+ a npm

### Instalace
1. Naklonujte repozitář
   ```
   git clone https://github.com/Martyparty1988/Kasa.git
   cd Kasa
   ```

2. Nainstalujte závislosti
   ```
   npm install
   ```

3. Spusťte vývojový server
   ```
   npm start
   ```

### Produkční build
```
npm run build
```

## Nasazení

Po vytvoření produkčního buildu můžete aplikaci nasadit na libovolný statický hosting (Netlify, Vercel, GitHub Pages, atd.).

### Příklad nasazení na GitHub Pages:

1. Nainstalujte gh-pages
   ```
   npm install --save-dev gh-pages
   ```

2. Upravte package.json
   ```json
   "homepage": "https://martyparty1988.github.io/Kasa",
   "scripts": {
     // další scripty
     "predeploy": "npm run build",
     "deploy": "gh-pages -d build"
   }
   ```

3. Nasaďte aplikaci
   ```
   npm run deploy
   ```

## Instalace PWA na zařízení

1. Otevřete aplikaci v prohlížeči Chrome nebo Safari
2. Na mobilním zařízení:
   - V Chrome: klikněte na tři tečky v menu a zvolte "Přidat na plochu"
   - V Safari: klikněte na ikonu sdílení a zvolte "Přidat na plochu"
3. Na počítači v Chrome:
   - Klikněte na ikonu instalace v adresním řádku nebo
   - Otevřete menu (tři tečky) a zvolte "Nainstalovat Kasa Pro"

## Použití

### Hlavní obrazovka
- Vyberte vilu, počet hostů a počet nocí
- Přidávejte položky do košíku
- Vytvořte fakturu z položek v košíku

### Správa skladu
- Editujte ceny a počty jednotlivých položek
- Přidávejte nové položky do nabídky

### Historie prodejů
- Prohlížejte historii prodejů
- Zobrazujte detaily prodejů
- Exportujte data

### Nastavení
- Změňte kurz EUR/CZK
- Přepínejte mezi světlým a tmavým režimem
- Zálohujte data

## Licence

MIT

## Autor

Martin Müller

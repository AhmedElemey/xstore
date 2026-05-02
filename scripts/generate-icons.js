/**
 * Builds iOS AppIcon PNGs (opaque), Android mipmaps + adaptive foregrounds
 * from assets/icon.png. Run: npm install && node generate-icons.js
 */
const fs = require("fs");
const path = require("path");
const sharp = require("sharp");

const root = path.resolve(__dirname, "..");
const iconIn = path.join(root, "assets", "icon.png");
const IOS_DIR = path.join(root, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset");
const ANDROID_RES = path.join(root, "android", "app", "src", "main", "res");

const iosExports = [
  ["Icon-App-20x20@2x.png", 40],
  ["Icon-App-20x20@3x.png", 60],
  ["Icon-App-29x29@1x.png", 29],
  ["Icon-App-29x29@2x.png", 58],
  ["Icon-App-29x29@3x.png", 87],
  ["Icon-App-40x40@2x.png", 80],
  ["Icon-App-40x40@3x.png", 120],
  ["Icon-App-60x60@2x.png", 120],
  ["Icon-App-60x60@3x.png", 180],
  ["Icon-App-20x20@1x.png", 20],
  ["Icon-App-40x40@1x.png", 40],
  ["Icon-App-76x76@1x.png", 76],
  ["Icon-App-76x76@2x.png", 152],
  ["Icon-App-83.5x83.5@2x.png", 167],
  ["Icon-App-1024x1024@1x.png", 1024],
];

async function rasterOpaque(buf, size) {
  return sharp(buf)
    .resize(size, size, { fit: "cover", position: "centre" })
    .flatten({ background: { r: 79, g: 70, b: 229 } })
    .png({ compressionLevel: 9 })
    .toBuffer();
}

/** Renders clean 1024 master icon (orange X, no underline). */
async function renderMasterIcon() {
  const svg = `
  <svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">
    <rect width="1024" height="1024" fill="#4F46E5"/>
    <g transform="translate(512 480)">
      <rect x="-96" y="-360" width="192" height="720" rx="48" fill="#FD6E01" transform="rotate(43)"/>
      <rect x="-96" y="-360" width="192" height="720" rx="48" fill="#FD6E01" transform="rotate(-43)"/>
    </g>
  </svg>`;

  return sharp(Buffer.from(svg))
    .flatten({ background: { r: 79, g: 70, b: 229 } })
    .png({ compressionLevel: 9 })
    .toBuffer();
}

/** Indigo AppColors.primary (#4F46E5) → transparency for adaptive foreground. */
async function keyedForeground(masterBuf, innerPx, totalPx) {
  const keyed = await sharp(masterBuf)
    .resize(innerPx, innerPx, { fit: "cover", position: "centre" })
    .ensureAlpha()
    .raw()
    .toBuffer({ resolveWithObject: true });

  const { data, info } = keyed;
  const w = info.width;
  const h = info.height;
  const br = 79;
  const bg = 70;
  const bb = 229;
  const thresh = 90;
  for (let i = 0; i < data.length; i += 4) {
    const r = data[i];
    const g = data[i + 1];
    const b = data[i + 2];
    const d = Math.hypot(r - br, g - bg, b - bb);
    if (d < thresh) {
      data[i + 3] = Math.round((255 * d) / thresh);
    }
  }

  const keyedPng = await sharp(Buffer.from(data), {
    raw: { width: w, height: h, channels: 4 },
  })
    .png()
    .toBuffer();

  const left = Math.floor((totalPx - innerPx) / 2);
  const top = Math.floor((totalPx - innerPx) / 2);

  return sharp({
    create: {
      width: totalPx,
      height: totalPx,
      channels: 4,
      background: { r: 0, g: 0, b: 0, alpha: 0 },
    },
  })
    .composite([{ input: keyedPng, left, top }])
    .png()
    .toBuffer();
}

async function foregroundLayer(buf, totalPx) {
  const inner = Math.round(totalPx * (72 / 108));
  return keyedForeground(buf, inner, totalPx);
}

async function main() {
  if (!fs.existsSync(iconIn)) {
    console.error("Missing", iconIn);
    process.exit(1);
  }
  const raw = fs.readFileSync(iconIn);
  const existingNormalized = await rasterOpaque(raw, 1024);
  if (!existingNormalized) {
    console.error("Failed to normalize existing icon");
    process.exit(1);
  }

  const master1024 = await renderMasterIcon();
  fs.mkdirSync(path.dirname(iconIn), { recursive: true });
  fs.writeFileSync(iconIn, master1024);
  console.log("Updated assets/icon.png (orange X, underline removed, clean render)");

  fs.mkdirSync(IOS_DIR, { recursive: true });
  for (const [filename, px] of iosExports) {
    const out = await rasterOpaque(master1024, px);
    fs.writeFileSync(path.join(IOS_DIR, filename), out);
  }
  console.log("Wrote", iosExports.length, "iOS icons");

  const androidLauncher = [
    ["mipmap-mdpi", 48],
    ["mipmap-hdpi", 72],
    ["mipmap-xhdpi", 96],
    ["mipmap-xxhdpi", 144],
    ["mipmap-xxxhdpi", 192],
  ];

  const androidForeground = [
    ["mipmap-mdpi", 108],
    ["mipmap-hdpi", 162],
    ["mipmap-xhdpi", 216],
    ["mipmap-xxhdpi", 324],
    ["mipmap-xxxhdpi", 432],
  ];

  for (const [folder, px] of androidLauncher) {
    const dir = path.join(ANDROID_RES, folder);
    fs.mkdirSync(dir, { recursive: true });
    const square = await rasterOpaque(master1024, px);
    fs.writeFileSync(path.join(dir, "ic_launcher.png"), square);
    fs.writeFileSync(path.join(dir, "ic_launcher_round.png"), square);
  }
  console.log("Wrote launcher + round mipmaps");

  for (const [folder, px] of androidForeground) {
    const dir = path.join(ANDROID_RES, folder);
    fs.mkdirSync(dir, { recursive: true });
    const fg = await foregroundLayer(master1024, px);
    fs.writeFileSync(path.join(dir, "ic_launcher_foreground.png"), fg);
  }
  console.log("Wrote adaptive ic_launcher_foreground mipmaps");

  console.log("Done.");
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});

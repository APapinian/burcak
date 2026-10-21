// Burçak vektör çizimi için SVG yol üreticileri (kıvırcık saç bulutu, bukle sarmalları).
.pragma library

// Tekrarlanabilir sözde rastgele sayı (aynı tohum → aynı saç).
function rng(seed) {
    let s = seed >>> 0;
    return function () { s = (s * 1664525 + 1013904223) >>> 0; return s / 4294967296; };
}

// Elips çevresinde dışa doğru kabarık bukleler: yumuşak, dağınık bir saç silueti.
function curlyBlob(cx, cy, rx, ry, bumps, depth, seed, startDeg, endDeg) {
    const r = rng(seed || 1);
    const a0 = (startDeg === undefined ? 0 : startDeg) * Math.PI / 180;
    const a1 = (endDeg === undefined ? 360 : endDeg) * Math.PI / 180;
    const pts = [];
    for (let i = 0; i <= bumps; i++) {
        const a = a0 + (a1 - a0) * i / bumps;
        const k = 1 + (r() - .5) * .08;
        pts.push([cx + Math.cos(a) * rx * k, cy + Math.sin(a) * ry * k]);
    }
    let d = "M " + pts[0][0].toFixed(1) + " " + pts[0][1].toFixed(1);
    for (let i = 1; i < pts.length; i++) {
        const [x0, y0] = pts[i - 1], [x1, y1] = pts[i];
        const mx = (x0 + x1) / 2, my = (y0 + y1) / 2;
        const nx = mx - cx, ny = my - cy, len = Math.hypot(nx, ny) || 1;
        const bulge = depth * (.7 + r() * .6);
        d += " Q " + (mx + nx / len * bulge).toFixed(1) + " " + (my + ny / len * bulge).toFixed(1) + " " + x1.toFixed(1) + " " + y1.toFixed(1);
    }
    return d + ((endDeg === undefined || endDeg - (startDeg || 0) >= 360) ? " Z" : "");
}

// Küçük bukle sarmalı (yalnızca çizgi): saçın kıvırcık dokusu.
function spiral(cx, cy, radius, turns, rot) {
    const steps = Math.round(turns * 14);
    let d = "";
    for (let i = 0; i <= steps; i++) {
        const t = i / steps, a = rot + t * turns * Math.PI * 2, rr = radius * (1 - t * .75);
        const x = cx + Math.cos(a) * rr, y = cy + Math.sin(a) * rr * 1.25;
        d += (i ? " L " : "M ") + x.toFixed(1) + " " + y.toFixed(1);
    }
    return d;
}

// Bir alana dağılmış birçok bukle sarmalı.
function curlField(cx, cy, rx, ry, count, seed, minR, maxR) {
    const r = rng(seed);
    let d = "";
    for (let i = 0; i < count; i++) {
        const a = r() * Math.PI * 2, dist = Math.sqrt(r());
        const x = cx + Math.cos(a) * rx * dist, y = cy + Math.sin(a) * ry * dist;
        d += " " + spiral(x, y, minR + r() * (maxR - minR), .55 + r() * .35, r() * 6.28);
    }
    return d;
}

// Yüzün yanından omuzlara dökülen kıvırcık lüle (öne düşen saç).
function lock(x, y, length, width, dir, seed) {
    const r = rng(seed);
    const n = Math.max(3, Math.round(length / 14));
    let left = [], right = [];
    for (let i = 0; i <= n; i++) {
        const t = i / n, sway = Math.sin(t * Math.PI * 2.2 + seed) * width * .35 * dir;
        const w = width * (1 - t * .55) * (.85 + r() * .3);
        left.push([x + sway - w / 2, y + t * length]);
        right.push([x + sway + w / 2, y + t * length]);
    }
    let d = "M " + left[0][0].toFixed(1) + " " + left[0][1].toFixed(1);
    for (let i = 1; i < left.length; i++) {
        const p = left[i], q = left[i - 1];
        d += " Q " + (Math.min(p[0], q[0]) - width * .28).toFixed(1) + " " + ((p[1] + q[1]) / 2).toFixed(1) + " " + p[0].toFixed(1) + " " + p[1].toFixed(1);
    }
    const tip = [(left[n][0] + right[n][0]) / 2, left[n][1] + width * .4];
    d += " Q " + tip[0].toFixed(1) + " " + tip[1].toFixed(1) + " " + right[n][0].toFixed(1) + " " + right[n][1].toFixed(1);
    for (let i = right.length - 2; i >= 0; i--) {
        const p = right[i], q = right[i + 1];
        d += " Q " + (Math.max(p[0], q[0]) + width * .28).toFixed(1) + " " + ((p[1] + q[1]) / 2).toFixed(1) + " " + p[0].toFixed(1) + " " + p[1].toFixed(1);
    }
    return d + " Z";
}

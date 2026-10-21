// Burçak hareket kütüphanesi: 100 animasyon. Her hareket t∈[0,1) döngü evresinden poz üretir.
// beats: dans döngüsünün vuruş sayısı (BPM ile süre = beats*60000/bpm); dur: diğerleri için ms.
.pragma library

const TAU = Math.PI * 2;
function s(t, f, ph) { return Math.sin(TAU * ((f || 1) * t + (ph || 0))); }
function c(t, f, ph) { return Math.cos(TAU * ((f || 1) * t + (ph || 0))); }
function hop(t, f) { return Math.abs(Math.sin(Math.PI * (f || 1) * t)); }
function step(t, n) { return Math.floor(t * n) % 2; }

// Kenetli eller, dik duruş
const BASE = {bob: 0, headTilt: 0, hairSway: 0, armLShoulder: -18, armLElbow: -48, armRShoulder: 18, armRElbow: 48,
              legL: 0, legR: 0, bodyTilt: 0, squashX: 1, squashY: 1, dx: 0, eyes: "acik", mouth: "gulum",
              blush: false, prop: "", hand: ""};
const DOWN = {armLShoulder: 8, armLElbow: 4, armRShoulder: -8, armRElbow: -4};      // kollar yanda
const UP = {armLShoulder: 158, armLElbow: 12, armRShoulder: -158, armRElbow: -12};   // kollar havada
function P(o) { return Object.assign({}, BASE, o); }
function mix(...parts) { return Object.assign({}, ...parts); }

const M = {};
function add(name, cat, opts, pose) { M[name] = Object.assign({name: name, cat: cat, loop: true, dur: 2400}, opts, {pose: pose}); }

// ——— Boşta (10)
add("nefes", "bosta", {dur: 3600}, t => P({bob: hop(t) * 1.5, hairSway: s(t) * 1.2}));
add("etrafa_bak", "bosta", {dur: 4200}, t => P({headTilt: s(t) * 9, hairSway: s(t, 1, .1) * 3}));
add("sac_burgu", "bosta", {dur: 3000}, t => P(mix({armRShoulder: -128, armRElbow: -70 + s(t, 2) * 14}, {headTilt: -5, eyes: "mutlu"})));
add("gerinme", "bosta", {dur: 3200, loop: false}, t => P(mix(UP, {squashY: 1 + hop(t) * .06, eyes: t > .3 && t < .8 ? "kapali" : "acik", mouth: "o"})));
add("esneme", "bosta", {dur: 2800, loop: false}, t => P({armRShoulder: -110 * hop(t), armRElbow: -60, eyes: "kapali", mouth: t > .2 && t < .8 ? "o" : "gulum", headTilt: -6 * hop(t)}));
add("ayak_vurma", "bosta", {dur: 900}, t => P({legR: -10 * step(t, 2), headTilt: s(t) * 3}));
add("sallanma", "bosta", {dur: 2600}, t => P({bodyTilt: s(t) * 3, headTilt: s(t, 1, .25) * 4, hairSway: s(t) * 3}));
add("mirildanma", "bosta", {dur: 1600}, t => P({headTilt: s(t) * 6, eyes: "mutlu", mouth: step(t, 4) ? "o" : "gulum"}));
add("tac_duzelt", "bosta", {dur: 2400, loop: false}, t => P({armRShoulder: -150 * hop(t), armRElbow: -40, headTilt: 4, eyes: "asagi"}));
add("tirnak_bak", "bosta", {dur: 2600}, t => P({armLShoulder: -40, armLElbow: -100, eyes: "asagi", headTilt: 6 + s(t) * 2}));

// ——— Yürüme / koşma (6)
add("yuru", "yuru", {dur: 700}, t => P(mix(DOWN, {bob: hop(t, 2) * 3, legL: s(t) * 14, legR: -s(t) * 14, armLShoulder: 8 - s(t) * 14, armRShoulder: -8 - s(t) * 14, hairSway: s(t) * 3})));
add("parmak_ucu", "yuru", {dur: 900}, t => P({bob: 4 + hop(t, 2) * 2, legL: s(t) * 8, legR: -s(t) * 8, eyes: "asagi", mouth: "dudak", squashY: 1.03}));
add("kos", "yuru", {dur: 420}, t => P(mix(DOWN, {bob: hop(t, 2) * 7, legL: s(t) * 26, legR: -s(t) * 26, armLShoulder: -s(t) * 34, armRShoulder: -s(t) * 34, armLElbow: -60, armRElbow: 60, bodyTilt: 4, hairSway: s(t) * 6, mouth: "sirit"})));
add("sek", "yuru", {dur: 640}, t => P(mix(DOWN, {bob: hop(t, 2) * 12, legL: step(t, 2) * 20, legR: (1 - step(t, 2)) * -20, eyes: "mutlu", mouth: "sirit", armLShoulder: 30 * hop(t, 2), armRShoulder: -30 * hop(t, 2)})));
add("sinsice", "yuru", {dur: 1200}, t => P({bob: -4 + hop(t, 2) * 2, squashY: .94, legL: s(t) * 10, legR: -s(t) * 10, armLShoulder: 40, armLElbow: 90, armRShoulder: -40, armRElbow: -90, eyes: "asagi", headTilt: s(t, .5) * 6}));
add("tören", "yuru", {dur: 800}, t => P(mix(DOWN, {bob: hop(t, 2) * 4, legL: step(t, 2) * -24, legR: (1 - step(t, 2)) * -24, armLShoulder: step(t, 2) ? 40 : -10, armRShoulder: step(t, 2) ? 10 : -40, mouth: "dudak"})));

// ——— Rock (6)
add("kafa_salla", "rock", {beats: 2}, t => P({headTilt: s(t, 2) * 16, hairSway: s(t, 2, .1) * 10, bob: hop(t, 2) * 4, eyes: "kapali", mouth: "sirit", armLShoulder: 30, armRShoulder: -30}));
add("hava_gitari", "rock", {beats: 2}, t => P({armLShoulder: 75, armLElbow: -35, armRShoulder: -10 + s(t, 4) * 14, armRElbow: 85, headTilt: s(t, 2) * 8, bob: hop(t, 2) * 3, legR: -8, eyes: "kapali", mouth: "sirit"}));
add("yumruk_havaya", "rock", {beats: 2}, t => P({armRShoulder: -150 + hop(t, 2) * 25, armRElbow: -20, bob: hop(t, 2) * 6, mouth: "sirit", eyes: "mutlu"}));
add("ziplama_tekme", "rock", {beats: 4}, t => P(mix(DOWN, {bob: hop(t, 2) * 16, legR: t > .4 && t < .6 ? -40 : 0, armLShoulder: 60, armRShoulder: -60, mouth: "o"})));
add("seytan_boynuzu", "rock", {beats: 2}, t => P({armRShoulder: -140, armRElbow: -30 + s(t, 2) * 10, headTilt: s(t, 2) * 10, bob: hop(t, 2) * 3, mouth: "sirit", eyes: "acik"}));
add("tepinme", "rock", {beats: 2}, t => P(mix(DOWN, {legL: -16 * step(t, 4), legR: -16 * (1 - step(t, 4)), bob: hop(t, 4) * 3, headTilt: s(t, 2) * 6})));

// ——— Heavy metal (5)
add("hizli_kafa", "metal", {beats: 1}, t => P({headTilt: s(t, 2) * 24, hairSway: s(t, 2, .15) * 16, bodyTilt: s(t, 2) * 5, eyes: "kapali", mouth: "o", armLShoulder: 40, armRShoulder: -40}));
add("sac_pervane", "metal", {beats: 2}, t => P({headTilt: s(t) * 26, hairSway: c(t) * 20, bodyTilt: 8, bob: hop(t, 2) * 3, eyes: "kapali", mouth: "o"}));
add("pogo", "metal", {beats: 1}, t => P(mix(DOWN, {bob: hop(t) * 18, squashY: 1 - hop(t + .5) * .06, squashX: 1 + hop(t + .5) * .04, mouth: "o", eyes: "kapali"})));
add("cift_boynuz", "metal", {beats: 2}, t => P(mix(UP, {armLElbow: 30, armRElbow: -30, headTilt: s(t, 2) * 14, bob: hop(t, 2) * 5, mouth: "o"})));
add("cigilik", "metal", {beats: 4}, t => P({squashY: 1 + hop(t) * .05, armLShoulder: 50, armLElbow: -10, armRShoulder: -50, armRElbow: 10, mouth: "o", eyes: "kapali", headTilt: -10 * hop(t)}));

// ——— Soft (5)
add("yavas_salinim", "soft", {beats: 4}, t => P({bodyTilt: s(t) * 4, headTilt: s(t, 1, .2) * 6, hairSway: s(t) * 4, eyes: "kapali", mouth: "gulum"}));
add("yana_adim", "soft", {beats: 4}, t => P({dx: s(t) * 10, legL: s(t) * 6, legR: -s(t) * 6, headTilt: s(t) * 4, eyes: "mutlu"}));
add("cakmak_salla", "soft", {beats: 4}, t => P({armRShoulder: -150 + s(t) * 14, armRElbow: -10, hand: "cakmak", bodyTilt: s(t) * 3, eyes: "kapali"}));
add("kendine_sarilma", "soft", {beats: 4}, t => P({armLShoulder: -40, armLElbow: -110, armRShoulder: 40, armRElbow: 110, bodyTilt: s(t) * 3, eyes: "kapali", blush: true}));
add("hafif_bas", "soft", {beats: 2}, t => P({headTilt: s(t) * 5, bob: hop(t) * 1.5, eyes: "mutlu"}));

// ——— Pop (8)
add("omuz_titret", "pop", {beats: 1}, t => P({armLShoulder: -18 + s(t, 4) * 8, armRShoulder: 18 + s(t, 4) * 8, bodyTilt: s(t, 2) * 3, eyes: "mutlu", mouth: "sirit"}));
add("kalca_salla", "pop", {beats: 2}, t => P({dx: s(t, 2) * 6, bodyTilt: s(t, 2) * 6, armLShoulder: 50, armLElbow: -100, armRShoulder: -50, armRElbow: 100, eyes: "mutlu"}));
add("yukari_asagi", "pop", {beats: 2}, t => P({armRShoulder: step(t, 2) ? -150 : 30, armRElbow: step(t, 2) ? -10 : 40, legR: step(t, 2) ? -6 : 0, mouth: "sirit"}));
add("donus", "pop", {beats: 4}, t => P({squashX: Math.abs(c(t)), bob: hop(t) * 6, mouth: "sirit", eyes: "mutlu"}));
add("alkis", "pop", {beats: 1}, t => P({armLShoulder: -60, armLElbow: -60 + hop(t, 2) * 20, armRShoulder: 60, armRElbow: 60 - hop(t, 2) * 20, bob: hop(t, 2) * 3, mouth: "sirit"}));
add("el_kalp", "pop", {beats: 4}, t => P({armLShoulder: -95, armLElbow: -70, armRShoulder: 95, armRElbow: 70, headTilt: s(t) * 6, blush: true, eyes: "mutlu"}));
add("pop_adim", "pop", {beats: 2}, t => P(mix(DOWN, {dx: step(t, 2) ? 8 : -8, legL: step(t, 2) ? -10 : 0, legR: step(t, 2) ? 0 : -10, bob: hop(t, 2) * 4, armLShoulder: step(t, 2) ? 40 : 0, armRShoulder: step(t, 2) ? 0 : -40, mouth: "sirit"})));
add("kol_dalga", "pop", {beats: 2}, t => P(mix(UP, {armLShoulder: 150 + s(t, 2) * 18, armRShoulder: -150 + s(t, 2) * 18, bodyTilt: s(t, 2) * 4, eyes: "mutlu", mouth: "sirit"})));

// ——— Rap / hip-hop (6)
add("ziplayan_bas", "rap", {beats: 1}, t => P({bob: hop(t) * 5, headTilt: 6 + s(t) * 5, armLShoulder: -30, armLElbow: -100, armRShoulder: 30, armRElbow: 100, mouth: "dudak"}));
add("akis_kolu", "rap", {beats: 2}, t => P({armRShoulder: -70 + s(t, 2) * 25, armRElbow: -40, bob: hop(t, 2) * 4, headTilt: s(t, 2) * 5, mouth: step(t, 4) ? "o" : "dudak"}));
add("yo_isaret", "rap", {beats: 2}, t => P({armRShoulder: -95, armRElbow: -10 + step(t, 2) * 25, bob: hop(t, 2) * 3, mouth: "sirit", headTilt: -6}));
add("omuz_zipla", "rap", {beats: 1}, t => P({armLShoulder: -18 - hop(t) * 10, armRShoulder: 18 + hop(t + .5) * 10, bob: hop(t, 2) * 3, eyes: "asagi"}));
add("kollar_kavusuk", "rap", {beats: 2}, t => P({armLShoulder: -60, armLElbow: -110, armRShoulder: 60, armRElbow: 110, headTilt: s(t, 2) * 8, bob: hop(t, 2) * 2, mouth: "dudak"}));
add("mikrofon", "rap", {beats: 2}, t => P({armRShoulder: -40, armRElbow: -120, hand: "mikrofon", bob: hop(t, 2) * 4, mouth: step(t, 4) ? "o" : "sirit", armLShoulder: 40 + s(t, 2) * 20, armLElbow: 0}));

// ——— Elektronik / dans (6)
add("kollar_havada_zipla", "elektronik", {beats: 1}, t => P(mix(UP, {bob: hop(t) * 14, eyes: "kapali", mouth: "sirit", armLShoulder: 150 + hop(t) * 10, armRShoulder: -150 - hop(t) * 10})));
add("yumruk_pompa", "elektronik", {beats: 1}, t => P({armRShoulder: -150 + hop(t) * 40, armRElbow: -20, bob: hop(t) * 6, mouth: "sirit"}));
add("shuffle", "elektronik", {beats: 1}, t => P(mix(DOWN, {legL: s(t, 2) * 20, legR: -s(t, 2) * 20, dx: s(t) * 8, bob: hop(t, 2) * 4, armLShoulder: 30, armRShoulder: -30})));
add("eller_dalga", "elektronik", {beats: 2}, t => P({armLShoulder: 100 + s(t, 2) * 30, armLElbow: s(t, 2, .25) * 30, armRShoulder: -100 + s(t, 2, .5) * 30, armRElbow: s(t, 2, .75) * 30, eyes: "kapali"}));
add("hizli_zipla", "elektronik", {beats: .5}, t => P(mix(DOWN, {bob: hop(t) * 9, squashY: 1 + hop(t) * .04, mouth: "o"})));
add("isik_donus", "elektronik", {beats: 4}, t => P(mix(UP, {squashX: Math.abs(c(t)), bob: hop(t, 2) * 6, eyes: "kapali", mouth: "sirit"})));

// ——— Sakin / klasik / akustik (5)
add("orkestra_sefi", "sakin", {beats: 4}, t => P({armRShoulder: -110 + s(t, 2) * 30, armRElbow: -30 + s(t, 2, .25) * 20, armLShoulder: -60 + s(t, 1) * 10, armLElbow: -40, eyes: "kapali", headTilt: s(t) * 4}));
add("gozler_kapali", "sakin", {beats: 4}, t => P({bodyTilt: s(t) * 2, headTilt: s(t) * 5, eyes: "kapali", mouth: "dudak", hairSway: s(t) * 2}));
add("yavas_kollar", "sakin", {beats: 8}, t => P({armLShoulder: 40 + hop(t) * 90, armLElbow: 10, armRShoulder: -40 - hop(t) * 90, armRElbow: -10, eyes: "kapali"}));
add("bale_kollari", "sakin", {beats: 4}, t => P({armLShoulder: 150, armLElbow: 50, armRShoulder: -150, armRElbow: -50, bob: 4 + hop(t) * 2, bodyTilt: s(t) * 3, eyes: "kapali", squashY: 1.03}));
add("piyano_parmak", "sakin", {beats: 2}, t => P({armLShoulder: -36, armLElbow: -70 + s(t, 4) * 8, armRShoulder: 36, armRElbow: 70 + s(t, 4, .5) * 8, eyes: "asagi", headTilt: s(t) * 4}));

// ——— Halk (5)
add("halay_omuz", "halk", {beats: 2}, t => P({armLShoulder: 70, armLElbow: -20, armRShoulder: -70, armRElbow: 20, bob: hop(t, 2) * 5, legR: step(t, 2) * -14, mouth: "sirit"}));
add("mendil_salla", "halk", {beats: 2}, t => P({armRShoulder: -150 + s(t, 2) * 20, armRElbow: -10, hand: "mendil", armLShoulder: 70, armLElbow: -20, bob: hop(t, 2) * 4, legL: step(t, 2) * -12, eyes: "mutlu", mouth: "sirit"}));
add("omuz_oynat", "halk", {beats: 1}, t => P({armLShoulder: -18 + s(t, 6) * 10, armRShoulder: 18 - s(t, 6) * 10, bodyTilt: s(t, 2) * 4, eyes: "mutlu"}));
add("kasik_oyunu", "halk", {beats: 2}, t => P({armLShoulder: 90, armLElbow: -40 + s(t, 4) * 15, armRShoulder: -90, armRElbow: 40 - s(t, 4) * 15, hand: "kasik", bob: hop(t, 2) * 4, mouth: "sirit"}));
add("sekme_adim", "halk", {beats: 2}, t => P(mix(DOWN, {bob: hop(t, 2) * 8, legL: step(t, 2) * -18, legR: (1 - step(t, 2)) * -18, armLShoulder: 60, armRShoulder: -60})));

// ——— Arabesk (4)
add("el_kalbinde", "arabesk", {beats: 4}, t => P({armRShoulder: 40, armRElbow: 110, bodyTilt: s(t) * 4, headTilt: 8 + s(t) * 4, eyes: "kapali", mouth: "dudak"}));
add("gozyasi_sil", "arabesk", {beats: 4, loop: false}, t => P({armRShoulder: -100 * hop(t), armRElbow: -80, headTilt: 10, eyes: "kapali", mouth: "dudak"}));
add("dramatik_el", "arabesk", {beats: 4}, t => P({armRShoulder: -120 + s(t) * 20, armRElbow: -10, armLShoulder: 30, armLElbow: 100, headTilt: -10, eyes: "kapali", mouth: "o"}));
add("dertli_bas", "arabesk", {beats: 4}, t => P({headTilt: s(t, 2) * 10, eyes: "kapali", mouth: "dudak", bodyTilt: 3}));

// ——— Tepkiler (15)
add("ezildim", "tepki", {dur: 1600, loop: false}, t => P(mix(DOWN, {squashY: t < .2 ? 1 - t * 2.5 : t < .7 ? .5 : .5 + (t - .7) * 1.67, squashX: t < .2 ? 1 + t * 2 : t < .7 ? 1.4 : 1.4 - (t - .7) * 1.33, eyes: "kapali", mouth: "o"})));
add("sasirma_zipla", "tepki", {dur: 900, loop: false}, t => P(mix(UP, {bob: hop(t) * 22, eyes: "sasir", mouth: "o"})));
add("sevinc_zipla", "tepki", {dur: 1100, loop: false}, t => P(mix(UP, {bob: hop(t, 2) * 16, eyes: "mutlu", mouth: "sirit"})));
add("utangac", "tepki", {dur: 2200, loop: false}, t => P({armLShoulder: -40, armLElbow: -110, armRShoulder: 40, armRElbow: 110, headTilt: 10, eyes: "asagi", blush: true, legR: -6}));
add("kahkaha", "tepki", {dur: 1400}, t => P({bob: hop(t, 4) * 3, headTilt: -8 + s(t, 4) * 3, eyes: "mutlu", mouth: "sirit", armLShoulder: -50, armLElbow: -100, armRShoulder: 50, armRElbow: 100}));
add("trip", "tepki", {dur: 2000, loop: false}, t => P({armLShoulder: -60, armLElbow: -110, armRShoulder: 60, armRElbow: 110, headTilt: -10, mouth: "of", eyes: "acik"}));
add("ofleme", "tepki", {dur: 1600, loop: false}, t => P({mouth: "of", squashY: 1 + hop(t) * .03, headTilt: s(t) * 4, armLShoulder: 10, armRShoulder: -10, armLElbow: 0, armRElbow: 0}));
add("hapsirma", "tepki", {dur: 1400, loop: false}, t => P({headTilt: t < .6 ? -10 * t / .6 : 14, eyes: t < .6 ? "kapali" : "mutlu", mouth: t < .6 ? "o" : "sirit", bob: t > .6 ? hop((t - .6) / .4) * 6 : 0}));
add("kikirdama", "tepki", {dur: 1200}, t => P({armRShoulder: 40, armRElbow: 130, eyes: "mutlu", bob: hop(t, 3) * 2, blush: true}));
add("merhaba_el", "tepki", {dur: 1200}, t => P({armRShoulder: -140, armRElbow: -30 + s(t, 3) * 25, eyes: "mutlu", mouth: "sirit"}));
add("hosca_kal_el", "tepki", {dur: 1600}, t => P({armRShoulder: -130, armRElbow: -20 + s(t, 2) * 25, eyes: "acik", mouth: "dudak", headTilt: 6}));
add("alkis_tepki", "tepki", {dur: 900}, t => P({armLShoulder: -60, armLElbow: -60 + hop(t, 3) * 20, armRShoulder: 60, armRElbow: 60 - hop(t, 3) * 20, eyes: "mutlu", mouth: "sirit"}));
add("omuz_silk", "tepki", {dur: 1400, loop: false}, t => P({armLShoulder: 40, armLElbow: 90, armRShoulder: -40, armRElbow: -90, bob: hop(t) * 4, headTilt: 8, mouth: "dudak"}));
add("yuzunu_kapat", "tepki", {dur: 1800, loop: false}, t => P({armRShoulder: -40, armRElbow: -130, headTilt: 10, eyes: "kapali", mouth: "of"}));
add("basparmak", "tepki", {dur: 1400, loop: false}, t => P({armRShoulder: -90, armRElbow: -60, eyes: "mutlu", mouth: "sirit", headTilt: -5}));

// ——— Etkinlikler (10)
add("yaziyor", "etkinlik", {dur: 600}, t => P({prop: "laptop", eyes: "asagi", headTilt: s(t, .25) * 3, armLElbow: -48 + s(t, 2) * 4, armRElbow: 48 - s(t, 2, .5) * 4}));
add("okuyor", "etkinlik", {dur: 5200}, t => P({prop: "kitap", eyes: "asagi", headTilt: 6 + s(t) * 2, armRShoulder: t > .85 ? 10 : 18}));
add("tokmak", "etkinlik", {dur: 1300}, t => P({hand: "tokmak", armRShoulder: -100 + hop(t) * 60, armRElbow: -30, eyes: "acik", mouth: t > .9 ? "o" : "dudak"}));
add("not_aliyor", "etkinlik", {dur: 900}, t => P({prop: "kitap", eyes: "asagi", armRElbow: 48 + s(t, 3) * 6, headTilt: 8}));
add("dusunuyor", "etkinlik", {dur: 3000}, t => P({armRShoulder: 40, armRElbow: 130, headTilt: -8 + s(t) * 3, eyes: "acik", mouth: "dudak"}));
add("misir_yiyor", "etkinlik", {dur: 1400}, t => P({prop: "misir", armRShoulder: 18 - hop(t) * 50, armRElbow: 48 + hop(t) * 60, mouth: hop(t) > .7 ? "o" : "gulum", eyes: "acik"}));
add("kulakli_dinle", "etkinlik", {dur: 1800}, t => P({headTilt: s(t) * 6, eyes: "kapali", mouth: "gulum", bob: hop(t, 2) * 1.5}));
add("uyuklama", "etkinlik", {dur: 3000}, t => P({headTilt: 14 + s(t) * 3, eyes: "kapali", mouth: "dudak", bob: hop(t) * 1}));
add("izle_arka", "etkinlik", {dur: 1800, view: "arka"}, t => ({legL: s(t) * 22, legR: -s(t) * 22, headTilt: s(t, .5) * 2, hairSway: s(t, .5) * 2, breathe: hop(t), reach: 0}));
add("izle_misir", "etkinlik", {dur: 2200, view: "arka"}, t => ({legL: s(t) * 16, legR: -s(t, 1, .2) * 16, headTilt: 3, hairSway: 0, breathe: hop(t), reach: hop(t)}));

// ——— Etkileşim / ekranda gezinme (9)
add("tirman", "etkilesim", {dur: 800}, t => P(mix(UP, {armLShoulder: 165 + s(t) * 10, armRShoulder: -165 + s(t) * 10, legL: s(t) * 30, legR: -s(t) * 30, eyes: "acik", mouth: "of"})));
add("kenarda_asili", "etkilesim", {dur: 1600}, t => P(mix(UP, {legL: s(t) * 14, legR: -s(t, 1, .3) * 14, bodyTilt: s(t, .5) * 4, eyes: "sasir", mouth: "o"})));
add("dusus", "etkilesim", {dur: 500}, t => P(mix(UP, {legL: 20, legR: -20, eyes: "sasir", mouth: "o", hairSway: s(t, 2) * 10})));
add("inis", "etkilesim", {dur: 600, loop: false}, t => P(mix(DOWN, {squashY: 1 - hop(t) * .18, squashX: 1 + hop(t) * .12, eyes: "kapali", mouth: "o"})));
add("tasiniyor", "etkilesim", {dur: 900}, t => P(mix(UP, {legL: s(t) * 18, legR: -s(t) * 18, bodyTilt: s(t, .5) * 8, eyes: "sasir", mouth: "sirit"})));
add("birakildi_sek", "etkilesim", {dur: 800, loop: false}, t => P(mix(DOWN, {bob: hop(t, 2) * (1 - t) * 18, squashY: 1 - hop(t * 2) * .1, eyes: "mutlu", mouth: "sirit"})));
add("kenarda_otur", "etkilesim", {dur: 2400}, t => P({legL: -70 + s(t) * 16, legR: -70 - s(t) * 16, squashY: .9, eyes: "acik", headTilt: s(t, .5) * 5}));
add("kenardan_bak", "etkilesim", {dur: 2400}, t => P({dx: -18 + hop(t) * 18, bodyTilt: -12 * hop(t), eyes: "acik", mouth: "dudak"}));
add("kelebek_kovala", "etkilesim", {dur: 1200}, t => P(mix(UP, {bob: hop(t, 2) * 10, armLShoulder: 140 + s(t, 2) * 20, armRShoulder: -140 + s(t, 2, .5) * 20, legL: s(t, 2) * 14, legR: -s(t, 2) * 14, eyes: "mutlu", mouth: "sirit"})));

var moves = M;
var names = Object.keys(M);
function byCat(cat) { return names.filter(n => M[n].cat === cat); }
// Müzik türü → dans kategorisi
var genreDance = {rock: "rock", metal: "metal", soft: "soft", pop: "pop", rap: "rap", elektronik: "elektronik", sakin: "sakin", halk: "halk", arabesk: "arabesk"};
function durationOf(move, bpm) { return move.beats ? Math.max(300, move.beats * 60000 / Math.max(50, Math.min(200, bpm || 110))) : move.dur; }

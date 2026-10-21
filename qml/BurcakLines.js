// Burçak'ın diyalogları (kategori → satırlar). Torba seçimi: bir kategori bitmeden satır tekrar etmez.
.pragma library

var lines = {
    selam: ["Günaydın! Bugün harika şeyler yapacağız.", "Buradayım, buradayım!", "Hoş geldin! Seni özledim.",
            "Selaaam! Kahvaltı yaptın mı?", "Hazırım, kumandan!", "Bugün enerjim yerinde!", "Yine birlikteyiz, ne güzel.",
            "Merhaba! Ekranı ben ısıttım."],
    web: ["İnternette 5 dakika dedin, bir saat oldu.", "Öff… yine mi çerez onayı?", "Bu kadar sekme mi olur ya?",
          "Araştırma yapıyoruz, değil mi? Değil mi?!", "Bir kedi videosu daha izlesek kimse fark etmez.",
          "Google da bilmiyormuş, bak.", "Püff… sayfa yükleniyor mu hâlâ?", "Reklamlar yine üstüme geliyor!",
          "Şu yorumları okuma bence, sinirlenirsin.", "Bu siteyi dün de açmıştın, biliyorum.", "Yine mi alışveriş sepeti?",
          "Öff, şifreni hatırlıyor musun?", "Bir tıklama daha… sonra çalışırız, söz.", "Sekmelerin arasında kayboldum!"],
    ilgi: ["Heey! Buradayım!", "Bana da bakar mısın biraz?", "Sıkıldım… biraz oyalanalım mı?", "Pşşt! Ben buradayım.",
           "Bir dakikalığına benimle ilgilensen?", "Dans edelim mi? Lütfen?", "Hıı… kimse beni sevmiyor mu?",
           "Bak bak, zıplayabiliyorum!", "Bir şaka anlatayım mı?", "Göz göze geldik, kaçamazsın!"],
    kod: ["Hata değil, sürpriz özellik!", "Derleniyor… ben de sabırla bekliyorum.", "Çalışıyorsa dokunmayalım bence.",
          "Noktalı virgül… şaka şaka.", "Bu fonksiyon çok uzun oldu, böl bence.", "Commit mesajına 'düzeltmeler' yazma ama!",
          "Test yazdın mı? Ben yazmadım.", "Stack Overflow'a sorsak mı?", "Kod gibi kod olmuş!", "Bir kahve, bir hata ayıklama.",
          "Değişken adı 'x' mi? Gerçekten mi?", "Yeşil yandı! Testler geçti mi?"],
    hukuk: ["Heyetimiz: ben. Karar: mola!", "İtiraz! …neye itiraz ettiğimi unuttum.", "Bu dilekçe çok iyi olmuş bence.",
            "Madde 1: Burçak her zaman haklıdır.", "Celse kısa bir süreliğine aranıyor.", "Mahkeme bu şakayı kabul etti.",
            "Kanun kitabı ağırmış, kolum koptu!", "Tanık kürsüsüne kelebek çağırıyorum.", "Kesin hüküm: bugün çok çalıştın.",
            "Delil yetersiz, ama tatlılık yeterli."],
    okuma: ["Şşş, en güzel yerindeyiz.", "Bir sayfa daha… sonra bir sayfa daha.", "Bu kitabı ben de okumak istiyorum.",
            "Kahraman ne yapacak sence?", "Sayfa kenarını kıvırmak yok!", "Bu cümleyi altını çizerek okudum.",
            "Kitap kokusu gibisi yok.", "Bölüm sonu geldi, devam mı?"],
    muzik: ["Bu şarkıda yerimde duramıyorum!", "Ses biraz daha açılsa mı?", "♪ La la laa ♪", "Bu şarkıyı ben seçmiş gibiyim.",
            "Ritim tam bana göre!", "Dans pistini açtım!"],
    rock: ["Rock'n'roll! Elinde hava gitarı var mı?", "Sahne bizim!", "Bu riff'e bayıldım!", "Daha yüksek sesle!"],
    metal: ["Saçlarım pervane oldu!", "Boynum gitti ama değdi!", "\\m/ Metal sonsuza dek!"],
    soft: ["Ne güzel, sakin sakin…", "Çakmakları havaya!", "Bu şarkı içimi ısıttı."],
    pop: ["Pop yıldızı modundayım!", "Koreografiyi biliyorum, izle!", "Bu nakarat kafama yapıştı.", "Hadi beraber söyleyelim!"],
    rap: ["Yo yo, mikrofon bende!", "Ritme kafiye: Burçak!", "Bu bas çok iyi!"],
    elektronik: ["Işıklar yansın!", "Drop geliyor, hazır ol!", "Zıpla zıpla zıpla!"],
    sakin: ["Gözlerimi kapatıp dinleyeceğim.", "Orkestrayı ben yönetiyorum.", "Ne kadar huzurlu…"],
    halk: ["Halaya durdum!", "Mendil nerede, mendil?", "Omuzlar titresin!"],
    arabesk: ["Ah bu şarkı… içim burkuldu.", "Gözüme bir şey kaçtı, ağlamıyorum.", "Bu dert bitmez…"],
    film: ["Patlamış mısır hazır!", "Şşş, en heyecanlı yeri!", "Bir bölüm daha… son bölüm, söz.", "Bu karakteri hiç sevmedim.",
           "Sence katil kim?", "Ayy, çok romantik!", "Korkarsam elini tutabilir miyim?", "Altyazıyı okuyamadım, geri sar!",
           "Bu sahne efsane!", "Birlikte izlemek daha güzel."],
    ezildim: ["Hey, ezildim!", "Aaay! Pencere üstüme düştü!", "Önüne bak biraz!", "Beni görmedin mi?!",
              "Yassıldım… krep gibi oldum.", "Pencereler bana karşı!", "Bir dahakine haber ver!", "Ah saçlarım!",
              "Burası benim yerimdi!", "Of, ezildim ama tatlılığım yerinde.", "Kim attı bu pencereyi?", "Nefes alamıyorum! …tamam alıyorum."],
    dustu: ["Aaaa! Düşüyorum!", "Zemin nereye gitti?", "Bir pencere kapattın ve ben uçtum!", "Paraşütüm yoktu!",
            "Yere indim, puan ver bakalım.", "Oha, iniş on numara!"],
    tasiniyor: ["Wiii! Uçuyorum!", "Yavaş, başım dönüyor!", "Beni nereye götürüyorsun?", "Taksi ücreti ne kadar?",
                "Yüksekten korkarım ama eğlenceli!", "Bırakma! …tamam bırak."],
    tirmanma: ["Tırmanıyorum, beni izle!", "Zirveye az kaldı!", "Buradan manzara harika.", "Pencerenin tepesi benim kalem!",
               "Kenarda oturup ayak sallamak en güzeli."],
    gece: ["Saat geç oldu, pijamalarımı giydim.", "Uykum geldi… sen de dinlen ama.", "Gece kuşu musun sen?",
           "Yıldızlar çıktı mı dışarıda?", "Bir bölüm daha deme sakın.", "Pijama partisi!"],
    sabah: ["Günaydın! Pijamaları çıkardım.", "Sabah sabah enerjim tavan!", "Güne güzel başlayalım.", "Su içtin mi bugün?"],
    aksam: ["Akşam oldu, siyah hoodie zamanı.", "Günün nasıl geçti?", "Biraz mola versek mi?"],
    pil: ["Pilimiz bitiyor… şarja takalım mı?", "Enerjim düşüyor, şarj lütfen!", "Fişi bul, fişi!", "Şarj olunca dans ederim."],
    bildirim: ["Bildirim geldi! Bakalım mı?", "Biri seni arıyor galiba!", "Mesaj var, mesaj!", "Ding! Önemli olabilir.",
               "Yine mi bildirim? Popülersin."],
    sarki: ["Bu şarkıya bayılırım ♪", "Ooo, yeni şarkı!", "Bu da güzelmiş.", "Bunu tekrar çalalım mı sonra?", "Ses aç, ses!"],
    saka: ["Bugün de harikasın.", "Su içtin mi? Bir bardak iç bakalım.", "Biraz esneyelim mi?", "Klavyende kırıntı mı var?",
           "Ekranı silsen mi? Parmak izin her yerde.", "Fare bana kaçıyor gibi geliyor.", "Gülümse, kamera yok ama olsun.",
           "Bugün kendine iyi davran.", "Pencereleri dizmede ustalaştın.", "Seninle çalışmak çok eğlenceli."],
    kelebek: ["Kelebek! Kelebek!", "Gel buraya küçük kelebek!", "Kelebekler en sevdiğim!"],
    uyku: ["Zzz…", "Hı? Uyuyakalmışım…", "Beş dakika daha…"]
};

var bags = {};
function pick(cat) {
    const list = lines[cat] || lines.saka;
    if (!bags[cat] || bags[cat].length === 0) {
        bags[cat] = list.slice();
        for (let i = bags[cat].length - 1; i > 0; i--) { const j = Math.floor(Math.random() * (i + 1)); [bags[cat][i], bags[cat][j]] = [bags[cat][j], bags[cat][i]]; }
    }
    return bags[cat].pop();
}
function total() { let n = 0; for (const k in lines) n += lines[k].length; return n; }

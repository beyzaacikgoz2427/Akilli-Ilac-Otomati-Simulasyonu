function akilli_ilac_otomati_gui

%  AKILLİ İLAÇ OTOMATI SİMÜLASYONU
%  Bu proje, bir ilaç otomatının çalışma mantığını simüle eder.
%  Kullanıcı göz seçer, satın alır; yönetici rapor ve grafik görür.
%  Tüm veriler rastgele üretilir, her çalıştırmada farklı sonuç verir.
 
%% ORTAM HAZIRLAMA
clc; clear; close all;
 
%% SABİTLER
SATIR         = 5;
SUTUN         = 5;
N             = SATIR * SUTUN;  % Toplam göz sayısı = 25
KRITIK        = 3;              % Bu değer ve altı = kritik stok uyarısı
BASLANGIC_MIN = 8;
BASLANGIC_MAX = 20;
FIYAT_MIN     = 30;
FIYAT_MAX     = 150;
 
%% VERİ YAPISI
rng('shuffle'); %her çalıştırmada farklı sayı
stok_0   = randi([BASLANGIC_MIN, BASLANGIC_MAX], N, 1); % Başlangıç stoğu
stok     = stok_0;                                        % Anlık stok
fiyatlar = randi([FIYAT_MIN, FIYAT_MAX], N, 1);
 
% İlaç adları
ilac_adlari = {
    'Parol 500mg';   'Aspirin 100mg'; 'Amoksisilin';   'İbuprofen 400'; 'Metformin';
    'Omeprazol';     'Losartan 50mg'; 'Atorvastatin';  'Levotiroksin';  'Amlodipin';
    'Ranitidin';     'Diklofenak';    'Sertralin';      'Lansoprazol';  'Bisoprolol';
    'Varfarin';      'Metoprolol';    'Fluoksetin';    'Klaritromisin'; 'Ramipril';
    'Gabapentin';    'Prednizolon';   'Pantoprazol';   'Sitagliptin';  'Rosuvastatin'
};
  
% Yönetici metrikleri
toplam_ciro  = 0;
islem_sayisi = 0;
son_islem    = 'Henüz işlem yapılmadı.';
talep_sayaci = zeros(N, 1); %hangi ilacın kaç kez seçildiği
secili_goz   = 0;  % 0 = hiçbir göz seçili değil
 
%% RENK TANIMLARI
C_BG     = [0.12 0.13 0.16];   % Ana arka plan
C_GOVDE  = [0.10 0.11 0.14];   % Otomat gövdesi
C_GOZ_N  = [0.16 0.20 0.30];   % Gözlerin sabit normal rengi
C_BORDER = [0.25 0.28 0.38];   % Panel çerçeve rengi
C_PANEL  = [0.14 0.16 0.22];   % Sağ panel arka planı
C_HEADER = [0.07 0.09 0.14];   % Başlık çubuğu
C_TEXT   = [0.88 0.90 0.95];   % Genel metin rengi
C_GREEN  = [0.12 0.72 0.38];   % Başarı  yeşil
C_ORANGE = [0.95 0.62 0.10];   % Uyarı  turuncu
C_RED    = [0.90 0.22 0.22];   % Hata  kırmızı
C_GOLD   = [0.95 0.80 0.25];   % Fiyat  gold
 
%% ANA PENCERE
fig = uifigure('Name', 'Akıllı İlaç Otomatı', ...
    'Position', [60 40 1000 720], 'Color', C_BG, ...
    'Resize', 'off');
 
% ÜST BAŞLIK
uipanel(fig, 'Position', [0 685 1000 35], ...
    'BackgroundColor', C_HEADER, 'BorderType', 'none');
 
uilabel(fig, ...
    'Text', 'AKILLİ İLAÇ OTOMATI', ...
    'FontSize', 14, 'FontWeight', 'bold','FontColor', [0.70 0.80 1.00], ...
    'HorizontalAlignment', 'center','Position', [0 688 1000 25]);
 
% SOL: OTOMAT GÖVDESİ
uipanel(fig, 'Position', [15 15 595 665], ...
    'BackgroundColor', C_GOVDE, ...
    'BorderType', 'line', 'HighlightColor', C_BORDER);
 
uipanel(fig, 'Position', [25 645 575 28], ...
    'BackgroundColor', [0.08 0.10 0.18], 'BorderType', 'none');
uilabel(fig, 'Text', '[ İLAÇ SEÇİMİ — GÖZ NUMARASINA TIKLAYIN ]', ...
    'FontSize', 9, 'FontWeight', 'bold', ...
    'FontColor', [0.40 0.55 0.85], ...
    'HorizontalAlignment', 'center', ...
    'Position', [25 647 575 22]);
 
%% 5×5 TIKANABILIR GÖZ IZGARASI
GOZ_W  = 108;
GOZ_H  = 110;
BOS    = 7;
IZGA_X = 30;
IZGA_Y = 120;
 
goz_buton = gobjects(N, 1);
 
for i = 1:N
    s = ceil(i / SUTUN);           
    c = mod(i - 1, SUTUN) + 1;    
 
    px = IZGA_X + (c - 1) * (GOZ_W + BOS);
    py = IZGA_Y + (SATIR - s) * (GOZ_H + BOS);
 
    goz_metin = sprintf('%s\n%d TL\nStok: %d', kisalt(ilac_adlari{i}, 12), fiyatlar(i), stok(i));
 
    goz_buton(i) = uibutton(fig, ...
        'Text', goz_metin, ...
        'FontSize', 8, 'FontWeight', 'bold', ...
        'FontColor', C_TEXT, ...
        'BackgroundColor', C_GOZ_N, ...
        'HorizontalAlignment', 'center', ...
        'Position', [px py GOZ_W GOZ_H], ...
        'ButtonPushedFcn', @(src,evt) gozSecCallback(i));
 
    % Göz numarası rozeti
    uilabel(fig, 'Text', sprintf('A%d', i), ...
        'FontSize', 7, 'FontColor', [0.45 0.55 0.75], ...
        'HorizontalAlignment', 'left', ...
        'Position', [px+3 py+GOZ_H-16 40 14]);
end
 
% Alt dekoratif şeritler
uipanel(fig, 'Position', [25 22 575 14], ...
    'BackgroundColor', [0.08 0.12 0.22], 'BorderType', 'none');
uilabel(fig, 'Text', '● ● ●', 'FontSize', 9, ...
    'FontColor', [0.20 0.40 0.80], ...
    'HorizontalAlignment', 'center', 'Position', [25 23 575 12]);
 
uipanel(fig, 'Position', [25 40 575 75], ...
    'BackgroundColor', [0.09 0.10 0.13], ...
    'BorderType', 'line', 'HighlightColor', C_BORDER);
uilabel(fig, 'Text', '[ ÖDEME YUVALARI — TEMASSIZ · QR · BANKA KARTI ]', ...
    'FontSize', 8, 'FontWeight', 'bold', ...
    'FontColor', [0.30 0.40 0.65], ...
    'HorizontalAlignment', 'center', 'Position', [25 88 575 18]);
uilabel(fig, 'Text', '▣  ▣  ▣', 'FontSize', 22, ...
    'FontColor', [0.25 0.35 0.60], ...
    'HorizontalAlignment', 'center', 'Position', [25 45 575 38]);
 
%% SAĞ: HASTA EKRANI
uipanel(fig, 'Position', [622 15 365 665], ...
    'BackgroundColor', C_PANEL, ...
    'BorderType', 'line', 'HighlightColor', C_BORDER);
 
% Ekran başlık şeridi
uipanel(fig, 'Position', [632 640 345 28], ...
    'BackgroundColor', [0.06 0.09 0.16], 'BorderType', 'none');
uilabel(fig, 'Text', 'HASTA BİLGİ EKRANI', ...
    'FontSize', 9, 'FontWeight', 'bold', ...
    'FontColor', [0.40 0.55 0.85], ...
    'HorizontalAlignment', 'center', 'Position', [632 642 345 22]);
 
% LCD ekran paneli
ekran_panel = uipanel(fig, 'Position', [632 430 345 205], ...
    'BackgroundColor', [0.04 0.10 0.08], ...
    'BorderType', 'line', 'HighlightColor', [0.10 0.30 0.20]);
 
ekran_baslik = uilabel(ekran_panel, ...
    'Text', '—  SEÇİM BEKLENİYOR  —', ...
    'FontSize', 10, 'FontWeight', 'bold', ...
    'FontColor', [0.25 0.85 0.55], ...
    'HorizontalAlignment', 'center', 'Position', [0 170 345 25]);
 
ekran_ilac = uilabel(ekran_panel, ...
    'Text', '', 'FontSize', 14, 'FontWeight', 'bold', ...
    'FontColor', [0.35 0.95 0.65], ...
    'HorizontalAlignment', 'center', 'Position', [5 125 335 42]);
 
ekran_fiyat = uilabel(ekran_panel, ...
    'Text', '', 'FontSize', 26, 'FontWeight', 'bold', ...
    'FontColor', C_GOLD, ...
    'HorizontalAlignment', 'center', 'Position', [5 82 335 44]);
 
ekran_stok = uilabel(ekran_panel, ...
    'Text', '', 'FontSize', 9, ...
    'FontColor', [0.40 0.80 0.55], ...
    'HorizontalAlignment', 'center', 'Position', [5 55 335 26]);
 
% LCD alt tarama çizgisi
uilabel(ekran_panel, ...
    'Text', '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', ...
    'FontSize', 6, 'FontColor', [0.12 0.35 0.22], ...
    'HorizontalAlignment', 'center', 'Position', [0 10 345 12]);
 
% SATIN AL butonu
satin_al_btn = uibutton(fig, ...
    'Text', '  SATIN AL', ...
    'FontSize', 15, 'FontWeight', 'bold', ...
    'FontColor', [1 1 1], ...
    'BackgroundColor', [0.08 0.42 0.20], ...
    'Position', [632 378 345 45], ...
    'Enable', 'off', ...
    'ButtonPushedFcn', @satinAlCallback);
 
% Ödeme animasyon etiketi
odeme_lbl = uilabel(fig, ...
    'Text', '', 'FontSize', 14, 'FontWeight', 'bold', ...
    'FontColor', C_GOLD, ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'center', ...
    'Position', [632 260 345 45], ...
    'Visible', 'off');
 
%% YÖNETİCİ KONSOLU
uipanel(fig, 'Position', [632 15 365 178], ...
    'BackgroundColor', [0.08 0.08 0.12], ...
    'BorderType', 'line', 'HighlightColor', [0.20 0.22 0.35]);
 
uilabel(fig, 'Text', ' YÖNETİCİ KONSOLU', ...
    'FontSize', 9, 'FontWeight', 'bold', ...
    'FontColor', [0.40 0.45 0.70], ...
    'Position', [645 152 300 20]);
 
rapor_btn = uibutton(fig, ...
    'Text', ' YÖNETİCİ RAPORUNU GÖSTER', ...
    'FontSize', 10, 'FontWeight', 'bold', ...
    'FontColor', [0.85 0.90 1.00], ...
    'BackgroundColor', [0.15 0.25 0.55], ...
    'Position', [642 92 348 45], ...
    'ButtonPushedFcn', @yoneticiRaporCallback);
 
grafik_btn = uibutton(fig, ...
    'Text', ' ANALİZ GRAFİKLERİNİ GÖSTER', ...
    'FontSize', 10, 'FontWeight', 'bold', ...
    'FontColor', [0.85 0.75 1.00], ...
    'BackgroundColor', [0.22 0.12 0.45], ...
    'Position', [642 32 348 45], ...
    'ButtonPushedFcn', @grafikleriGosterCallback);
 
%%  CALLBACK FONKSİYONLARI
 
% Göz Seçimi
    function gozSecCallback(goz_no)
        secili_goz = goz_no;
 
        for k = 1:N
            goz_buton(k).BackgroundColor = C_GOZ_N; 
        end
 
        % LCD ekranını güncelle
        ekran_baslik.Text  = sprintf('— GÖZ  A%d  SEÇİLDİ —', goz_no);
        ekran_ilac.Text    = ilac_adlari{goz_no};
        ekran_fiyat.Text   = sprintf('%d TL', fiyatlar(goz_no));
 
        if stok(goz_no) == 0
            ekran_stok.Text      = '✗  STOK YOK';
            ekran_stok.FontColor = C_RED;
            satin_al_btn.Enable  = 'off';
            satin_al_btn.BackgroundColor = [0.25 0.10 0.10];
        elseif stok(goz_no) <= KRITIK
            ekran_stok.Text      = sprintf('⚠  Son %d Adet Kaldı!', stok(goz_no));
            ekran_stok.FontColor = C_ORANGE;
            satin_al_btn.Enable  = 'on';
            satin_al_btn.BackgroundColor = [0.45 0.28 0.05];
        else
            ekran_stok.Text      = sprintf('✓  Stok Mevcut  (%d adet)', stok(goz_no));
            ekran_stok.FontColor = C_GREEN;
            satin_al_btn.Enable  = 'on';
            satin_al_btn.BackgroundColor = [0.08 0.42 0.20];
        end
    end
 
% Satın Al
    function satinAlCallback(~, ~)
        if secili_goz == 0, return; end
 
        satin_al_btn.Enable = 'off';
 
        odeme_lbl.Text      = ' LÜTFEN ÖDEMENİZİ YAPINIZ...';
        odeme_lbl.FontColor = C_GOLD;
        odeme_lbl.Visible   = 'on';
        drawnow;  
 
        pause(2);
 
        odeme_lbl.Text      = ' ÖDEME ALINDI!';
        odeme_lbl.FontColor = C_GREEN;
        drawnow;
        pause(1);
 
        odeme_lbl.Visible = 'off';
 
        talep_sayaci(secili_goz) = talep_sayaci(secili_goz) + 1;
 
        if stok(secili_goz) > 0
            stok(secili_goz)  = stok(secili_goz) - 1;
            toplam_ciro  = toplam_ciro + fiyatlar(secili_goz);
            islem_sayisi = islem_sayisi + 1;
 
            son_islem = sprintf('Göz A%d | %s | %d TL', ...
                secili_goz, ilac_adlari{secili_goz}, fiyatlar(secili_goz));
 
            goz_buton(secili_goz).Text = sprintf('%s\n%d TL\nStok: %d', ...
                kisalt(ilac_adlari{secili_goz}, 12), ...
                fiyatlar(secili_goz), stok(secili_goz));
            goz_buton(secili_goz).BackgroundColor = C_GOZ_N; 
 
            gozSecCallback(secili_goz);
            
            msgbox(sprintf('%s başarıyla verilmiştir. Lütfen çekmeceden alınız.', ilac_adlari{secili_goz}), 'İşlem Başarılı', 'help');
        else
            msgbox('Seçilen ilaç tükenmiştir!', 'Hata', 'error');
        end
    end
 
% Yönetici Raporu
    function yoneticiRaporCallback(~, ~)
        doluluk   = (sum(stok) / sum(stok_0)) * 100;
        tukenen_n = sum(stok == 0);
        kritik_n  = sum(stok > 0 & stok <= KRITIK);
        normal_n  = sum(stok > KRITIK);
 
        if islem_sayisi > 0
            ort_fiyat = toplam_ciro / islem_sayisi;
        else
            ort_fiyat = 0;
        end
 
        tukenme_hizi = (stok_0 - stok) ./ stok_0;
        [max_hiz, mh_idx] = max(tukenme_hizi);
 
        rf = uifigure('Name', 'Akıllı İlaç Otomatı — Yönetici Raporu', ...
            'Position', [200 150 480 560], ...
            'Color', [0.08 0.09 0.13], ...
            'Resize', 'off');
 
        uipanel(rf, 'Position', [0 510 480 50], ...
            'BackgroundColor', [0.10 0.18 0.40], 'BorderType', 'none');
        uilabel(rf, 'Text', ' YÖNETİCİ RAPORU', ...
            'FontSize', 16, 'FontWeight', 'bold', ...
            'FontColor', [0.80 0.88 1.00], ...
            'HorizontalAlignment', 'center', ...
            'Position', [0 517 480 32]);
 
        uipanel(rf, 'Position', [20 390 440 110], ...
            'BackgroundColor', [0.12 0.16 0.28], ...
            'BorderType', 'line', 'HighlightColor', [0.25 0.35 0.65]);
 
        uilabel(rf, 'Text', 'SATIŞ ÖZETİ', ...
            'FontSize', 8, 'FontWeight', 'bold', ...
            'FontColor', [0.45 0.60 0.90], ...
            'Position', [32 488 200 16]);
 
        uilabel(rf, 'Text', sprintf('%d', islem_sayisi), ...
            'FontSize', 28, 'FontWeight', 'bold', ...
            'FontColor', C_GOLD, 'Position', [40 420 120 52]);
        uilabel(rf, 'Text', 'işlem', ...
            'FontSize', 9, 'FontColor', [0.55 0.65 0.85], ...
            'Position', [40 408 80 18]);
 
        uilabel(rf, 'Text', sprintf('%.2f TL', toplam_ciro), ...
            'FontSize', 22, 'FontWeight', 'bold', ...
            'FontColor', C_GREEN, 'Position', [200 425 230 42]);
        uilabel(rf, 'Text', 'toplam ciro', ...
            'FontSize', 9, 'FontColor', [0.55 0.65 0.85], ...
            'Position', [200 408 150 18]);
 
        uipanel(rf, 'Position', [20 265 440 115], ...
            'BackgroundColor', [0.10 0.14 0.18], ...
            'BorderType', 'line', 'HighlightColor', [0.25 0.32 0.42]);
 
        uilabel(rf, 'Text', 'STOK DURUMU', ...
            'FontSize', 8, 'FontWeight', 'bold', ...
            'FontColor', [0.45 0.60 0.75], ...
            'Position', [32 368 200 16]);
 
        doluluk_px = round(doluluk * 4.0);  
        uipanel(rf, 'Position', [32 342 400 14], ...
            'BackgroundColor', [0.15 0.18 0.25], 'BorderType', 'none');
        if doluluk_px > 0
            bar_renk = [0.12 0.72 0.35];
            if doluluk < 40, bar_renk = C_RED;
            elseif doluluk < 65, bar_renk = C_ORANGE; end
            uipanel(rf, 'Position', [32 342 doluluk_px 14], ...
                'BackgroundColor', bar_renk, 'BorderType', 'none');
        end
        uilabel(rf, 'Text', sprintf('Doluluk Oranı: %.1f%%', doluluk), ...
            'FontSize', 9, 'FontWeight', 'bold', ...
            'FontColor', [0.75 0.85 1.00], 'Position', [32 326 250 16]);
 
        stok_kutu = [32 268; 182 268; 332 268];
        stok_sayilar = [normal_n, kritik_n, tukenen_n];
        stok_etiket  = {'Normal', 'Kritik', 'Tükenmiş'};
        stok_renkler = {C_GREEN, C_ORANGE, C_RED};
        for m = 1:3
            uipanel(rf, 'Position', [stok_kutu(m,1) stok_kutu(m,2) 128 48], ...
                'BackgroundColor', [0.13 0.15 0.22], ...
                'BorderType', 'line', 'HighlightColor', [0.22 0.26 0.38]);
            uilabel(rf, 'Text', sprintf('%d göz', stok_sayilar(m)), ...
                'FontSize', 16, 'FontWeight', 'bold', ...
                'FontColor', stok_renkler{m}, ...
                'HorizontalAlignment', 'center', ...
                'Position', [stok_kutu(m,1) stok_kutu(m,2)+22 128 26]);
            uilabel(rf, 'Text', stok_etiket{m}, ...
                'FontSize', 8, 'FontColor', [0.50 0.58 0.75], ...
                'HorizontalAlignment', 'center', ...
                'Position', [stok_kutu(m,1) stok_kutu(m,2)+6 128 16]);
        end
 
        uipanel(rf, 'Position', [20 175 440 80], ...
            'BackgroundColor', [0.14 0.10 0.18], ...
            'BorderType', 'line', 'HighlightColor', [0.35 0.22 0.50]);
 
        uilabel(rf, 'Text', 'EN HIZLI TÜKENEN İLAÇ', ...
            'FontSize', 8, 'FontWeight', 'bold', ...
            'FontColor', [0.65 0.45 0.90], 'Position', [32 242 280 16]);
 
        uilabel(rf, 'Text', ilac_adlari{mh_idx}, ...
            'FontSize', 16, 'FontWeight', 'bold', ...
            'FontColor', [0.85 0.70 1.00], 'Position', [32 208 280 32]);
 
        uilabel(rf, 'Text', sprintf('Tükenme Hızı: %.0f%%', max_hiz * 100), ...
            'FontSize', 9, 'FontColor', [0.55 0.45 0.80], ...
            'Position', [32 180 280 22]);
 
        uipanel(rf, 'Position', [20 95 440 70], ...
            'BackgroundColor', [0.10 0.11 0.15], ...
            'BorderType', 'line', 'HighlightColor', [0.20 0.22 0.30]);
 
        uilabel(rf, 'Text', 'GÖSTERGELER (Rapor İçi)', ...
            'FontSize', 8, 'FontWeight', 'bold', ...
            'FontColor', [0.40 0.48 0.68], 'Position', [32 152 200 16]);
 
        renk_x = [32 172 322];
        renk_c = {C_GREEN, C_ORANGE, C_RED};
        renk_t = {'Normal (>3)', 'Kritik (1-3)', 'Tükenmiş (0)'};
        for m = 1:3
            uipanel(rf, 'Position', [renk_x(m) 122 12 12], ...
                'BackgroundColor', renk_c{m}, 'BorderType', 'none');
            uilabel(rf, 'Text', renk_t{m}, ...
                'FontSize', 8, 'FontColor', [0.55 0.62 0.80], ...
                'Position', [renk_x(m)+16 118 130 18]);
        end
 
        uibutton(rf, 'Text', 'KAPAT', ...
            'FontSize', 11, 'FontWeight', 'bold', ...
            'FontColor', [0.85 0.90 1.00], ...
            'BackgroundColor', [0.18 0.22 0.45], ...
            'Position', [160 30 160 45], ...
            'ButtonPushedFcn', @(~,~) close(rf));
    end
 
% Grafik Düzeni
    function grafikleriGosterCallback(~, ~)
        if islem_sayisi == 0
            msgbox('Henüz satış yapılmadı. İstatistik oluşturulamaz.', 'Bilgi', 'warn');
            return;
        end
 
        % TEK BİR ANA PENCERE (Subplot Düzeni)
        main_fig = figure('Name', 'Yönetici Analiz Paneli', 'NumberTitle', 'off', ...
            'Color', [0.08 0.09 0.13], 'Position', [100 80 1100 650]);
 
        % --- GRAPH 1: YAN YANA STOK KARŞILAŞTIRMASI ---
        subplot(2, 2, [1, 2]); % Üst kısmı tamamen kaplayan geniş bar grafik
        b = bar(1:N, [stok_0, stok], 'grouped');
        b(1).FaceColor = [0.25 0.45 0.75]; b(1).EdgeColor = 'none'; % Başlangıç (Mavi)
        b(2).FaceColor = [0.12 0.65 0.35]; b(2).EdgeColor = 'none'; % Kalan (Yeşil)
        
        % Kritik stok durumuna düşenlerin rengini barda vurgulamak yerine net bir eşik çizgisi
        hold on;
        yline(KRITIK, 'Color', [0.90 0.22 0.22], 'LineStyle', '--', 'LineWidth', 2, ...
            'Label', sprintf('Kritik Eşik (%d)', KRITIK), 'FontSize', 10, 'FontWeight', 'bold', 'LabelVerticalAlignment', 'bottom');
        hold off;
        
        ax1 = gca; ax1.Color = [0.11 0.12 0.16]; grid on;
        ax1.XColor = [0.8 0.85 0.9]; ax1.YColor = [0.8 0.85 0.9];
        ax1.FontSize = 10;
        title('GÖZ BAZLI STOK DEĞİŞİMİ (Başlangıç vs Güncel)', 'Color', [0.95 0.95 1], 'FontSize', 12, 'FontWeight', 'bold');
        xlabel('Göz Numarası (A1 - A25)', 'Color', [0.7 0.75 0.8]);
        ylabel('Stok Adedi', 'Color', [0.7 0.75 0.8]);
        xlim([0 N+1]); xticks(1:N);
        legend({'Başlangıç Stoğu', 'Mevcut Stok'}, 'TextColor', 'white', 'Color', [0.15 0.16 0.2], 'EdgeColor', 'none');
 
        % --- GRAPH 2: GEOMETRİK OTOMAT ISI HARİTASI (HEATMAP) ---
        subplot(2, 2, 3);
        stok_matrisi = reshape(stok, SATIR, SUTUN);
        
        % Görsel bir matris (Heatmap) çizimi
        imagesc(stok_matrisi);
        colormap(gca, flipud(hot)); % Azalan stok beyaza/kırmızıya döner
        caxis([0 BASLANGIC_MAX]);
        cb = colorbar('Color', 'white');
        title(cb, 'Stok', 'Color', 'white');
        
        ax2 = gca;
        ax2.XColor = [0.8 0.85 0.9]; ax2.YColor = [0.8 0.85 0.9];
        ax2.XTick = 1:SUTUN; ax2.YTick = 1:SATIR;
        ax2.FontSize = 11;
        title('OTOMAT KUŞBAKIŞI STOK YOĞUNLUĞU', 'Color', [0.95 0.95 1], 'FontSize', 12, 'FontWeight', 'bold');
        xlabel('Sütunlar', 'Color', [0.7 0.75 0.8]);
        ylabel('Satırlar', 'Color', [0.7 0.75 0.8]);
        
        % Hücrelerin içine stok sayılarını yazdıralım
        for r = 1:SATIR
            for c = 1:SUTUN
                val = stok_matrisi(r,c);
                if val < 4, txt_c = 'cyan'; else, txt_c = 'black'; end
                text(c, r, sprintf('%d', val), 'Color', txt_c, ...
                    'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 12);
            end
        end
 
        % --- GRAPH 3: EN ÇOK TALEP GÖREN İLAÇLAR ---
        subplot(2, 2, 4);
        [sirali_talep, s_idx] = sort(talep_sayaci, 'descend');
        en_cok_istenen = sirali_talep > 0;
        
        if any(en_cok_istenen)
            % Sadece satışı olan ilk 7 ilacı gösterelim 
            gosterim_adedi = min(7, sum(en_cok_istenen));
            grafik_talepler = sirali_talep(1:gosterim_adedi);
            grafik_isimler = ilac_adlari(s_idx(1:gosterim_adedi));
            
            b2 = barh(1:gosterim_adedi, grafik_talepler, 0.5);
            b2.FaceColor = [0.85 0.65 0.15]; b2.EdgeColor = 'none';
            
            ax3 = gca; ax3.Color = [0.11 0.12 0.16]; grid on;
            ax3.XColor = [0.8 0.85 0.9]; ax3.YColor = [0.8 0.85 0.9];
            ax3.YTick = 1:gosterim_adedi;
            ax3.YTickLabel = grafik_isimler;
            ax3.YDir = 'reverse'; % En çok satılan en üstte dursun
            ax3.FontSize = 10;
            title('EN ÇOK SATIN ALINAN İLAÇLAR (TOP 7)', 'Color', [0.95 0.95 1], 'FontSize', 12, 'FontWeight', 'bold');
            xlabel('Satış Adedi', 'Color', [0.7 0.75 0.8]);
        else
            % Satış yoksa boş bilgi mesajı bas
            text(0.5, 0.5, 'Henüz Grafik Üretilecek Kadar Satış Yapılmadı', ...
                'Color', C_ORANGE, 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold');
            axis off;
        end
    end
 
end 
 
%% 
%   YARDIMCI FONKSİYONLAR
 
function k = kisalt(isim, maks)
    if length(isim) > maks
        k = [isim(1:maks) '..'];
    else
        k = isim;
    end
end
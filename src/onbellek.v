`timescale 1ns/1ps

module onbellek (
    // Saat ve reset
    input               clk_i,
    input               rst_i,

    // Anabellek istek sinyalleri
    output  [31:0]      anabellek_istek_adres_o,        // Istegin yapildigi adres 
    output  [127:0]     anabellek_istek_veri_o,         // Istekle yazilacak veri
    output              anabellek_istek_gecerli_o,      // Istek gecerli
    output              anabellek_istek_yaz_gecerli_o,  // Istek yazma istegi
    input               anabellek_istek_hazir_i,        // Anabellek istegi kabul etmeye hazir

    // Anabellek yanit sinyalleri
    input   [127:0]     anabellek_cevap_veri_i,     // Okunan veri
    input               anabellek_cevap_gecerli_i,  // Okunan veri gecerli
    output              anabellek_cevap_hazir_o,    // Modul okunan veriyi kabul etmeye hazir

    // Module istek sinyalleri
    input   [31:0]      islemci_istek_adres_i,      // Istegin yapildigi adres
    input   [31:0]      islemci_istek_veri_i,       // Istekle yazilacak veri
    input               islemci_istek_gecerli_i,    // Istek gecerli
    input               islemci_istek_yaz_i,        // Istek yazma istegi
    output              islemci_istek_hazir_o,      // Modul istegi kabul etmeye hazir

    // Modulun yanit sinyalleri
    output  [31:0]      islemci_cevap_veri_o,       // Modulden okunan veri       
    output              islemci_cevap_gecerli_o,    // Modulden okunan veri gecerli
    input               islemci_cevap_hazir_i,      // Dis modul veriyi kabul etmeye hazir

    // Onbellek istek ve yanit sinyalleri
    output              onbellek_istek_gecerli_o,  // Onbellek istegi gecerli
    output              onbellek_istek_yaz_o,      // Istek yazma istegi
    output  [127:0]     onbellek_istek_veri_o,     // Istekle yazilacak veri
    output  [6:0]       onbellek_istek_adres_o,    // Istegin yapilacagi adres
    input   [127:0]     onbellek_cevap_veri_i      // Onbellekten okunan veri

);

reg  [31:0]      anabellek_istek_adres_r;
reg  [31:0]      anabellek_istek_adres_ns;

reg  [127:0]     anabellek_istek_veri_r;
reg  [127:0]     anabellek_istek_veri_ns;

reg              anabellek_istek_gecerli_r;
reg              anabellek_istek_gecerli_ns;

reg              anabellek_istek_yaz_gecerli_r;
reg              anabellek_istek_yaz_gecerli_ns;

reg              anabellek_cevap_hazir_r;
reg              anabellek_cevap_hazir_ns;

reg              istek_hazir_r;
reg              istek_hazir_ns;

reg  [31:0]      yanit_veri_r;
reg  [31:0]      yanit_veri_ns;

reg              yanit_gecerli_r;
reg              yanit_gecerli_ns;

localparam DURUM_BOSTA      = 0;
localparam DURUM_OKU_ISTEK  = 1;
localparam DURUM_YAZ_ISTEK  = 2;
localparam DURUM_BEKLE      = 3;
localparam DURUM_YAZ        = 4;
localparam DURUM_OKU        = 5;
localparam DURUM_YANIT      = 6;
//------Benim ekledigim durumlar--------
localparam DURUM_ONBELLEK_BEKLE  = 7;
//------Benim ekledigim durumlar--------

reg [2:0] durum_r;
reg [2:0] durum_ns;

reg [127:0] arabellek_obek_r;
reg [127:0] arabellek_obek_ns;

reg [31:0] arabellek_adres_r;
reg [31:0] arabellek_adres_ns;

reg [31:0] arabellek_veri_r;
reg [31:0] arabellek_veri_ns;

reg        arabellek_yaz_istek_r;
reg        arabellek_yaz_istek_ns;

//----------Benim eklediðim sinyaller------------

reg [20:0] etiketler [127:0]; //128 satýrýn her biri icin 21 bitlik etiket
reg [127:0] kirli; //kirli bitler icin 1 tutar(yani gecersiz veri icin 1 tutar)
//reg miss_r; //onbellekte bulunamadý sinyali 
//reg miss_ns:

reg onbellek_istek_gecerli_r;  
reg onbellek_istek_gecerli_ns;

reg onbellek_istek_yaz_r;      
reg onbellek_istek_yaz_ns;

reg [127:0] onbellek_istek_veri_r;     
reg [127:0] onbellek_istek_veri_ns;

reg [6:0] onbellek_istek_adres_r;    
reg [6:0] onbellek_istek_adres_ns;    

//------------Bulamama oraný icin sayaclar-----------------
reg [16:0] sayac_erisim;
reg [16:0] erisim_sayisi_ns;

reg [16:0] sayac_bulamama;
reg [16:0] bulamama_sayisi_ns;
//------------Bulamama oraný icin sayaclar-----------------


//----------Benim eklediðim sinyaller------------


// Verilen veri obegi icerisinde ilgili baytlara veriyi yaz
function [127:0] obege_yaz (
    input [127:0] veri_obegi,
    input [31:0] adres,
    input [31:0] veri
);
    integer i;
    reg [3:0] bayt_adresi;

    begin
        bayt_adresi = adres[3:0] & 4'b1100; // 32 bite hizala
        obege_yaz = veri_obegi;
        // Little Endian
        for (i = 0; i < 4; i = i + 1) begin
            obege_yaz[(bayt_adresi + i) * 8 +: 8] = veri[i * 8 +: 8];
        end
    end
endfunction

// Verilen veri obegi icerisinden ilgili baytlari oku
function [31:0] obekten_oku (
    input [127:0] veri_obegi,
    input [31:0] adres
);
    integer i;
    reg [3:0] bayt_adresi;

    begin
        bayt_adresi = adres[3:0] & 5'b1100; // 32 bite hizala
        obekten_oku = 0;
        // Little Endian
        for (i = 0; i < 4; i = i + 1) begin
            obekten_oku[i * 8 +: 8] = veri_obegi[(bayt_adresi + i) * 8 +: 8];
        end
    end
endfunction

always @* begin
    anabellek_istek_adres_ns = anabellek_istek_adres_r;
    anabellek_istek_veri_ns = anabellek_istek_veri_r;
    anabellek_istek_gecerli_ns = anabellek_istek_gecerli_r;
    anabellek_istek_yaz_gecerli_ns = anabellek_istek_yaz_gecerli_r;
    anabellek_cevap_hazir_ns = 0;
    istek_hazir_ns = 0;
    yanit_gecerli_ns = 0;
    yanit_veri_ns = yanit_veri_r;
    durum_ns = durum_r;
    arabellek_obek_ns = arabellek_obek_r;
    arabellek_adres_ns = arabellek_adres_r;
    arabellek_veri_ns = arabellek_veri_r;
    arabellek_yaz_istek_ns = arabellek_yaz_istek_r;
    //-------------------------  
    onbellek_istek_gecerli_ns = onbellek_istek_gecerli_r;
    onbellek_istek_yaz_ns = onbellek_istek_yaz_r;
    onbellek_istek_veri_ns = onbellek_istek_veri_r;
    onbellek_istek_adres_ns = onbellek_istek_adres_r; 
    
    erisim_sayisi_ns = sayac_erisim;
    bulamama_sayisi_ns = sayac_bulamama;
    
    //-------------------------
    case(durum_r)
    // Herhangi bir istek yok
    DURUM_BOSTA: begin
        istek_hazir_ns = 1;
        if (islemci_istek_hazir_o && islemci_istek_gecerli_i) begin
            istek_hazir_ns = 0;
            arabellek_adres_ns = islemci_istek_adres_i;
            arabellek_veri_ns = islemci_istek_veri_i;
            arabellek_yaz_istek_ns = islemci_istek_yaz_i;
            //------------------------------------
            onbellek_istek_gecerli_ns = 1;
            //------------------------------------
            durum_ns = DURUM_OKU_ISTEK;
        end
    end
    // Anabellege okuma istegi gonderiyoruz, anabellek istegimizi kabul edene kadar (hazir ve gecerli) bekle.
    // (Once onbellege istek gönderiyoruz miss olursa anabellege istek gönderiyoruz)
    DURUM_OKU_ISTEK: begin
    //------------------------------------
                
        if(etiketler[arabellek_adres_r[10:4]] == arabellek_adres_r[31:11] && onbellek_istek_gecerli_r && !kirli[arabellek_adres_r[10:4]]) begin //cache hit
            
            erisim_sayisi_ns = sayac_erisim + 1; //erisim
            
            onbellek_istek_gecerli_ns = 1;
            onbellek_istek_yaz_ns = 0;      // Istek yazma istegi
            onbellek_istek_veri_ns = arabellek_obek_r;     // Istekle yazilacak veri
            onbellek_istek_adres_ns = arabellek_adres_r[10:4];    // Istegin yapilacagi adres
            durum_ns = DURUM_ONBELLEK_BEKLE;
        end
    //------------------------------------
        else begin//ben ekledim cache miss
        
            anabellek_istek_gecerli_ns = 1;
            anabellek_istek_yaz_gecerli_ns = 0;
            anabellek_istek_adres_ns = arabellek_adres_r;
            anabellek_istek_veri_ns = arabellek_obek_r;
            if (anabellek_istek_hazir_i && anabellek_istek_gecerli_o) begin
                
                erisim_sayisi_ns = sayac_erisim + 1; //erisim
                bulamama_sayisi_ns = sayac_bulamama + 1;//bulamadý        
                
                anabellek_istek_gecerli_ns = 0;
                durum_ns = DURUM_BEKLE;
            end
        end//ben ekledim
    end
    // Anabellege yazma istegi gonderiyoruz, anabellek istegimizi kabul edene kadar (hazir ve gecerli) bekle.
    DURUM_YAZ_ISTEK: begin
        
        //--------onbellege de yaz----------
        onbellek_istek_gecerli_ns = 1;
        onbellek_istek_yaz_ns = 1;      // Istek yazma istegi
        onbellek_istek_veri_ns = arabellek_obek_r;     // Istekle yazilacak veri
        onbellek_istek_adres_ns = arabellek_adres_r[10:4];    // Istegin yapilacagi adres
        //--------onbellege de yaz----------
        
        anabellek_istek_gecerli_ns = 1;
        anabellek_istek_yaz_gecerli_ns = 1;
        anabellek_istek_adres_ns = arabellek_adres_r;
        anabellek_istek_veri_ns = arabellek_obek_r;
        if (anabellek_istek_hazir_i && anabellek_istek_gecerli_o) begin
            anabellek_istek_gecerli_ns = 0;
            anabellek_istek_yaz_gecerli_ns = 0;
            durum_ns = DURUM_BOSTA;
        end
    end
    // Anabellege okuma istegimizi gonderdik, yanit vermesini bekliyoruz.
    DURUM_BEKLE: begin
        anabellek_cevap_hazir_ns = 1;
        if (anabellek_cevap_hazir_o && anabellek_cevap_gecerli_i) begin
            anabellek_cevap_hazir_ns = 0;
            arabellek_obek_ns = anabellek_cevap_veri_i;
            //-----------------------------------------------
            onbellek_istek_gecerli_ns = 1;
            onbellek_istek_yaz_ns = 1;      // Istek yazma istegi
            onbellek_istek_veri_ns = anabellek_cevap_veri_i;     // Istekle yazilacak veri
            onbellek_istek_adres_ns = arabellek_adres_r[10:4];    // Istegin yapilacagi adres
            //etiketler[arabellek_adres_r[10:4]] = arabellek_adres_r[31:11]; //etiket güncelle
            //kirli[arabellek_adres_r[10:4]] = 0;
            //-----------------------------------------------
            durum_ns = arabellek_yaz_istek_r ? DURUM_YAZ : DURUM_OKU;
        end
    end
    // Anabellekten gelen veri obeginin uzerine veriyi yaz, sonra obegi geri anabellege yaz.
    DURUM_YAZ: begin
        arabellek_obek_ns = obege_yaz(arabellek_obek_r, arabellek_adres_r, arabellek_veri_r);
        durum_ns = DURUM_YAZ_ISTEK;
    end
    // Anabellekten gelen veri obeginin icinden istenen 32 biti oku ve yanitla.
    DURUM_OKU: begin
        yanit_veri_ns = obekten_oku(arabellek_obek_r, arabellek_adres_r);
        durum_ns = DURUM_YANIT;
    end
    // Istegi yapan modulun hazir olmasini bekle.
    DURUM_YANIT: begin
        yanit_gecerli_ns = 1;
        if (islemci_cevap_hazir_i && islemci_cevap_gecerli_o) begin
            yanit_gecerli_ns = 0;
            durum_ns = arabellek_yaz_istek_r ? DURUM_YAZ : DURUM_BOSTA;
        end
    end
    //Onbellekten sonucun gelmesini bekliyoruz.
    DURUM_ONBELLEK_BEKLE: begin
        if(onbellek_istek_gecerli_r) begin
            onbellek_istek_gecerli_ns = 0;
            arabellek_obek_ns = onbellek_cevap_veri_i;
            durum_ns = arabellek_yaz_istek_r ? DURUM_YAZ : DURUM_OKU;
        end
    end
    
    default: durum_ns = DURUM_BOSTA;
    endcase
end

integer y;

always @(posedge clk_i) begin
    if (rst_i) begin
        durum_r <= DURUM_BOSTA;
        anabellek_istek_adres_r <= 0;
        anabellek_istek_veri_r <= 0;
        anabellek_istek_gecerli_r <= 0;
        anabellek_istek_yaz_gecerli_r <= 0;
        anabellek_cevap_hazir_r <= 0;
        istek_hazir_r <= 0;
        yanit_veri_r <= 0;
        yanit_gecerli_r <= 0;
        arabellek_obek_r <= 0;
        onbellek_istek_gecerli_r <= 0;
        onbellek_istek_yaz_r <= 0;
        onbellek_istek_veri_r <= 0;
        onbellek_istek_adres_r <= 0;
        for(y = 0; y<128;y = y + 1) begin
            etiketler[y] <= 0;
            kirli[y] <= 1;
        end
        sayac_erisim <= 0;
        sayac_bulamama <= 0; 
    end
    else begin
        durum_r <= durum_ns;
        anabellek_istek_adres_r <= anabellek_istek_adres_ns;
        anabellek_istek_veri_r <= anabellek_istek_veri_ns;
        anabellek_istek_gecerli_r <= anabellek_istek_gecerli_ns;
        anabellek_istek_yaz_gecerli_r <= anabellek_istek_yaz_gecerli_ns;
        anabellek_cevap_hazir_r <= anabellek_cevap_hazir_ns;
        istek_hazir_r <= istek_hazir_ns;
        yanit_veri_r <= yanit_veri_ns;
        yanit_gecerli_r <= yanit_gecerli_ns;
        arabellek_obek_r <= arabellek_obek_ns;
        arabellek_adres_r <= arabellek_adres_ns;
        arabellek_veri_r <= arabellek_veri_ns;
        arabellek_yaz_istek_r <= arabellek_yaz_istek_ns;
        //-------------------------------------------
        onbellek_istek_gecerli_r <= onbellek_istek_gecerli_ns;
        onbellek_istek_yaz_r <= onbellek_istek_yaz_ns;
        onbellek_istek_veri_r <= onbellek_istek_veri_ns;
        onbellek_istek_adres_r <= onbellek_istek_adres_ns;
        if(durum_r == DURUM_BEKLE) begin
            etiketler[arabellek_adres_r[10:4]] <= arabellek_adres_r[31:11]; //etiket güncelle
            kirli[arabellek_adres_r[10:4]] = 0;
        end
        
        sayac_erisim <= erisim_sayisi_ns;
        sayac_bulamama <= bulamama_sayisi_ns;
        
        //-------------------------------------------
    end
end

assign anabellek_istek_adres_o = anabellek_istek_adres_r;
assign anabellek_istek_veri_o = anabellek_istek_veri_r;
assign anabellek_istek_gecerli_o = anabellek_istek_gecerli_r;
assign anabellek_istek_yaz_gecerli_o = anabellek_istek_yaz_gecerli_r;
assign anabellek_cevap_hazir_o = anabellek_cevap_hazir_r;
assign islemci_istek_hazir_o = istek_hazir_r;
assign islemci_cevap_veri_o = yanit_veri_r;
assign islemci_cevap_gecerli_o = yanit_gecerli_r;

assign onbellek_istek_gecerli_o = onbellek_istek_gecerli_r;
assign onbellek_istek_yaz_o = onbellek_istek_yaz_r;
assign onbellek_istek_veri_o = onbellek_istek_veri_r;
assign onbellek_istek_adres_o = onbellek_istek_adres_r;

endmodule
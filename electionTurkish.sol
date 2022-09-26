// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.7;

contract Secim {
    
    struct OyVeren {
        bool oyKullanildi;  //Vatandaş oy kullanınca, bunu gücelleyeceğiz. Eğer 1 ise vatandaş oy kullandı, 0 ise kullanmadı.
        uint oyVerilenKisi; //Burada hangi adaya oy verdiğini tutacağız. (index olarak)
    }

    struct Aday {
        string isim; //Adayın ismini tutacağız.
        uint alinanOy; //Burada alınan oyları tutacağız.
    }

    mapping(address=>OyVeren) public oyVerenler; //Burada her oy veren vatandaş'ın adresi, OyVeren Structını tutacak.

    Aday[] public adaylar; //Aday structını tutacak şekilde bir array tutuyoruz.
    address public anlasmaBaslatan; //Akıllı anlaşmayı çağıran adresi tutmak için bunu tanımladım.

    constructor(string[] memory adayIsimleri) { //Burada akıllı anlaşma çağrılırken adayların ismini girmemiz için bir constructor tanımladım.
        anlasmaBaslatan = msg.sender; //Akıllı anlaşmayı çağıran adresi anlasmaBaslatan adı altında tutuyoruz.
       
        for(uint i = 0 ; i < adayIsimleri.length ; i++) { //İsimler girildikten sonra bu döngü sayesinde arreyimizin içinde
            adaylar.push(Aday({isim: adayIsimleri[i], alinanOy: 0})); //tutulacak olan her adayın ismini atıyoruz.
        }                                                             
    }

     modifier tekOyHakki() { //Bu modifierda her oy veren vatandaşın, sadece bir kez oy kullanması için 
        OyVeren storage oyVeren = oyVerenler[msg.sender]; //require yardımı ile koşul getiriyoruz.
        
        require(!oyVeren.oyKullanildi, "Oy kullanildi, baska oy atamazsiniz!");
        _;
    }

     function oyKullanma(uint tercih) external tekOyHakki {
        require(anlasmaBaslatan != msg.sender, "Gecersiz oy!"); //Anlaşmayı başlatan adresin oy kullanma yetkisine sahip olmasını istemediğim için bunu yapıyoruz.
        
        OyVeren storage oyVeren = oyVerenler[msg.sender]; //Her oy veren vatandaşın, kendisinin işlemi yapmasını istiyoruz.
        oyVeren.oyKullanildi = true; //Eğer ilk oy kullanışı ise oyKullanildi'yi true ya güncelliyoruz.
        oyVeren.oyVerilenKisi = tercih; //Burada vatandaşın kime oy verdiğini atıyoruz.

        adaylar[tercih].alinanOy++; //Burada vatandaşın oy verdiği adayın, aldığı toplam oy sayısını güncelliyoruz.
     }

     function secimKazanani() external view returns(string memory kazananAday) {
        uint fazlaOy = 0; //Bunu adayları karşılaştırırken kullanacağız. Fazla oy alan adayın oyunu buna eşitleyeceğiz.
        
        for(uint i = 0 ; i < adaylar.length ; i++){ //Burada adayları karşılaştırmak için bir for loop kullandım.
            
            if(adaylar[i].alinanOy > fazlaOy){ //Burada adaylar arası alınan oy sayılarını karşılaştıran bir if kullandım.
                fazlaOy = adaylar[i].alinanOy; //Eğer karşılaştırdığımız aday, fazlaOy'u güncelleyen adayın oy sayısından fazla ise yeniden fazlaOy'u güncelliyoruz.
                kazananAday = adaylar[i].isim; //Daha fazla oy alan bir aday çıkıncaya kadar adayın ismini de güncelliyoruz.
            }
        }
    }

}
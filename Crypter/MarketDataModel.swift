//
//  MarketDataModel.swift
//  Crypter
//


import Foundation

// Coin Gecko API response : MarketDataModel
/*
 
 https://api.coingecko.com/api/v3/global
 
 {
   "data": {
     "active_cryptocurrencies": 12916,
     "upcoming_icos": 0,
     "ongoing_icos": 49,
     "ended_icos": 3376,
     "markets": 568,
     "total_market_cap": {
       "btc": 53183637.93972199,
       "eth": 626051591.3994783,
       "ltc": 17840130522.012856,
       "bch": 8018107691.628192,
       "bnb": 3648621393.0946083,
       "eos": 635797173063.6346,
       "xrp": 3067792332107.3647,
       "xlm": 9970413512237.828,
       "link": 138578865025.32385,
       "dot": 140888076061.85065,
       "yfi": 109690439.19227345,
       "usd": 1022238994780.4579,
       "aed": 3754786051728.095,
       "ars": 144334988867271.97,
       "aud": 1512867711520.3088,
       "bdt": 97110569046883.28,
       "bhd": 385358545057.3626,
       "bmd": 1022238994780.4579,
       "brl": 5339460941436.773,
       "cad": 1337543501525.515,
       "chf": 992600197365.7938,
       "clp": 898139180814106.8,
       "cny": 7112330030084.526,
       "czk": 25101999554168.387,
       "dkk": 7608992001371.534,
       "eur": 1023246922429.3099,
       "gbp": 888343064527.1268,
       "hkd": 8023926987264.911,
       "huf": 405983095902593.75,
       "idr": 15232281037324124,
       "ils": 3511120053737.2524,
       "inr": 81480317079784.12,
       "jpy": 147145425424426.56,
       "krw": 1415983255605637.5,
       "kwd": 315674557261.16833,
       "lkr": 367901445693735.2,
       "mmk": 2146098210911785.5,
       "mxn": 20416443430673.81,
       "myr": 4601097715506.836,
       "ngn": 436424494041620.2,
       "nok": 10262333936525.611,
       "nzd": 1686069753361.9421,
       "php": 58323843802721.19,
       "pkr": 229554992506592,
       "pln": 4812113400004.391,
       "rub": 62356584815041.555,
       "sar": 3842213041756.6943,
       "sek": 10956641728497.492,
       "sgd": 1436111874358.224,
       "thb": 37301500919538.88,
       "try": 18640356333670.508,
       "twd": 31605584218383.15,
       "uah": 37743132699019.87,
       "vef": 102356790547.36685,
       "vnd": 24075346716433750,
       "zar": 17881822287895.582,
       "xdr": 759617619109.3989,
       "xag": 55177128439.12594,
       "xau": 598347150.814847,
       "bits": 53183637939721.984,
       "sats": 5318363793972199
     },
     "total_volume": {
       "btc": 4284633.494789662,
       "eth": 50436595.19901204,
       "ltc": 1437254459.2130103,
       "bch": 645962820.7329128,
       "bnb": 293943890.19377786,
       "eos": 51221728507.71458,
       "xrp": 247150557773.1228,
       "xlm": 803246437181.5958,
       "link": 11164329289.214886,
       "dot": 11350366261.053003,
       "yfi": 8836991.00001545,
       "usd": 82354641509.86885,
       "aed": 302496833729.89886,
       "ars": 11628059902027.062,
       "aud": 121881163475.73764,
       "bdt": 7823518904591.416,
       "bhd": 31045640983.182766,
       "bmd": 82354641509.86885,
       "brl": 430162998998.49854,
       "cad": 107756518910.38023,
       "chf": 79966851033.93176,
       "clp": 72356788030570.48,
       "cny": 572990653769.0645,
       "czk": 2022292423806.8257,
       "dkk": 613003232829.1216,
       "eur": 82435843186.39746,
       "gbp": 71567583500.9815,
       "hkd": 646431640655.1119,
       "huf": 32707216700636.062,
       "idr": 1227158277674404.8,
       "ils": 282866369606.3991,
       "inr": 6564298894366.875,
       "jpy": 11854477106156.91,
       "krw": 114075860923720.4,
       "kwd": 25431689780.73803,
       "lkr": 29639244663697.363,
       "mmk": 172896113048953.84,
       "mxn": 1644809959534.7205,
       "myr": 370678241435.9193,
       "ngn": 35159667099808.254,
       "nok": 826764422715.6855,
       "nzd": 135834839805.32088,
       "php": 4698743906636.297,
       "pkr": 18493639169714.074,
       "pln": 387678298309.5939,
       "rub": 5023633626229.821,
       "sar": 309540214445.03046,
       "sek": 882699942293.1136,
       "sgd": 115697482863.3277,
       "thb": 3005120868695.1123,
       "try": 1501723052352.683,
       "twd": 2546240723847.479,
       "uah": 3040700050338.768,
       "vef": 8246170254.383136,
       "vnd": 1939582189861109.5,
       "zar": 1440613273003.833,
       "xdr": 61197075268.85138,
       "xag": 4445235072.5713825,
       "xau": 48204642.314971656,
       "bits": 4284633494789.6616,
       "sats": 428463349478966.2
     },
     "market_cap_percentage": {
       "btc": 35.99775935166138,
       "eth": 19.24582082522093,
       "usdt": 6.6160097306404,
       "usdc": 5.05967530187105,
       "bnb": 4.470148867351053,
       "busd": 1.951897673032006,
       "xrp": 1.6181676029252332,
       "ada": 1.561063631484716,
       "sol": 1.155152735732882,
       "dot": 0.8159064029243734
     },
     "market_cap_change_percentage_24h_usd": 2.556299656001906,
     "updated_at": 1662658090
   }
 }
 
*/

struct GlobalData: Codable {
    let data: MarketDataModel?
}

struct MarketDataModel: Codable {

    let totalMarketCap, totalVolume, marketCapPercentage: [String: Double]
    let marketCapChangePercentage24HUsd: Double
   
    
    enum CodingKeys: String, CodingKey {
        case totalMarketCap = "total_market_cap"
        case totalVolume = "total_volume"
        case marketCapPercentage = "market_cap_percentage"
        case marketCapChangePercentage24HUsd = "market_cap_change_percentage_24h_usd"
    }
    
    var marketCap: String {
        if let item = totalMarketCap.first(where: { $0.key == "usd" }){
            return "$" + item.value.formattedWithAbbreviations()
        }
        return ""
    }
    
    var volume: String {
        if let item = totalVolume.first(where: { $0.key == "usd" }) {
            return "$" +  item.value.formattedWithAbbreviations()
        }
        return ""
    }
    
    var btcDominance: String {
        if let item = marketCapPercentage.first(where: { $0.key == "btc"}) {
            return item.value.asPercentString()
        }
        return ""
    }
}

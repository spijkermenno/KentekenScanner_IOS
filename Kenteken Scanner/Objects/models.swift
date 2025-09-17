//
//  models.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 27/12/2023.
//

import Foundation

struct GekentekendeVoertuig: Decodable {
    let id: Int
    let kenteken: String
    let voertuigsoort: String?
    let merk: String?
    let handelsbenaming: String?
    let vervaldatum_apk: Int?
    let datum_tenaamstelling: Int?
    let bruto_bpm: Double?
    let inrichting: String?
    let aantal_zitplaatsen: Int?
    let eerste_kleur: String?
    let tweede_kleur: String?
    let aantal_cilinders: Int?
    let cilinderinhoud: Double?
    let massa_ledig_voertuig: Double?
    let toegestane_maximum_massa_voertuig: Double?
    let massa_rijklaar: Double?
    let maximum_massa_trekken_ongeremd: Double?
    let maximum_trekken_massa_geremd: Double?
    let datum_eerste_toelating: Int?
    let datum_eerste_tenaamstelling_in_nederland: Int?
    let wacht_op_keuren: String?
    let catalogusprijs: Double?
    let wam_verzekerd: String?
    let maximum_constructiesnelheid: Double?
    let laadvermogen: Double?
    let oplegger_geremd: Double?
    let aanhangwagen_autonoom_geremd: Double?
    let aanhangwagen_middenas_geremd: Int?
    let aantal_staanplaatsen: Int?
    let aantal_deuren: Int?
    let aantal_wielen: Int?
    let afwijkende_maximum_snelheid: Double?
    let lengte: Double?
    let breedte: Double?
    let plaats_chassisnummer: String?
    let technische_max_massa_voertuig: Double?
    let type: String?
    let variant: String?
    let uitvoering: String?
    let vermogen_massarijklaar: Double?
    let wielbasis: Double?
    let export_indicator: String?
    let openstaande_terugroepactie_indicator: String?
    let vervaldatum_tachograaf: Int?
    let taxi_indicator: String?
    let maximum_massa_samenstelling: Double?
    let aantal_rolstoelplaatsen: Int?
    let maximum_ondersteunende_snelheid: Double?
    let jaar_laatste_registratie_tellerstand: Int?
    let tellerstandoordeel: String?
    let code_toelichting_tellerstandoordeel: String?
    let tenaamstellen_mogelijk: String?
    let wielbasis_voertuig_minimum: Double?
    let wielbasis_voertuig_maximum: Double?
    let lengte_voertuig_minimum: Double?
    let lengte_voertuig_maximum: Double?
    let breedte_voertuig_minimum: Double?
    let breedte_voertuig_maximum: Double?
    let hoogte_voertuig: Double?
    let hoogte_voertuig_minimum: Double?
    let hoogte_voertuig_maximum: Double?
    let massa_bedrijfsklaar_minimaal: Double?
    let massa_bedrijfsklaar_maximaal: Double?
    let technisch_toelaatbaar_massa_koppelpunt: Double?
    let maximum_massa_technisch_maximaal: Double?
    let maximum_massa_technisch_minimaal: Double?
    let subcategorie_nederland: String?
    let verticale_belasting_koppelpunt_getrokken_voertuig: Double?
    let zuinigheidsclassificatie: String?
    let registratie_datum_goedkeuring_afschrijvingsmoment_bpm: Int?
    let gemiddelde_lading_waarde: Double?
    let aerodynamische_voorziening_of_uitrusting: String?
    let additionele_massa_alternatieve_aandrijving: Double?
    let verlengde_cabine_indicator: String?
    let carrosserie_gegevens: [CarrosserieGegevens]?
    let emissie_gegevens: [EmissieGegevens]?
    let images: [Image]?
    
    // MARK: - Hoofdsecties (volgorde behouden)
    
    func getKenteken() -> KeyValuePair {
        KeyValuePair(id: "kenteken", key: "Kenteken", value: kenteken)
    }
    
    func getCarInformation() -> [KeyValuePair] {
        func formatEuro(_ amount: Double) -> String {
            let nf = NumberFormatter()
            nf.numberStyle = .currency
            nf.currencyCode = "EUR"
            nf.locale = Locale(identifier: "nl_NL")
            return nf.string(from: NSNumber(value: amount)) ?? "\(amount)"
        }
        
        var list: [KeyValuePair] = []
        
        // Jouw bestaande velden hier ongemoeid gelaten:
        if let v = voertuigsoort { list.append(KeyValuePair(id: "voertuigsoort", key: "Voertuigsoort", value: v)) }
        if let v = merk { list.append(KeyValuePair(id: "merk", key: "Merk", value: v)) }
        if let v = handelsbenaming { list.append(KeyValuePair(id: "handelsbenaming", key: "Handelsbenaming", value: v)) }
        if let v = inrichting { list.append(KeyValuePair(id: "inrichting", key: "Inrichting", value: v)) }
        
        let t = type ?? "N/A"
        let varnt = variant ?? "N/A"
        let u = uitvoering ?? "N/A"
        if type != nil || variant != nil || uitvoering != nil {
            list.append(KeyValuePair(id: "type_variant", key: "Type/Variant/Uitvoering", value: "\(t), \(varnt), \(u)"))
        }
        
        if let v = eerste_kleur { list.append(KeyValuePair(id: "eerste_kleur", key: "Eerste kleur", value: v)) }
        if let v = tweede_kleur { list.append(KeyValuePair(id: "tweede_kleur", key: "Tweede kleur", value: v)) }
        if let v = aantal_zitplaatsen { list.append(KeyValuePair(id: "zitplaatsen", key: "Aantal zitplaatsen", value: "\(v)")) }
        if let v = aantal_staanplaatsen { list.append(KeyValuePair(id: "staanplaatsen", key: "Aantal staanplaatsen", value: "\(v)")) }
        if let v = aantal_rolstoelplaatsen { list.append(KeyValuePair(id: "rolstoelplaatsen", key: "Aantal rolstoelplaatsen", value: "\(v)")) }
        if let v = aantal_deuren { list.append(KeyValuePair(id: "deuren", key: "Aantal deuren", value: "\(v)")) }
        if let v = aantal_wielen { list.append(KeyValuePair(id: "wielen", key: "Aantal wielen", value: "\(v)")) }
        if let c = carrosserie_gegevens?.first {
            list.append(KeyValuePair(id: "carrosserie", key: "Carrosserietype", value: c.type_carrosserie_europese_omschrijving))
        }
        if let v = plaats_chassisnummer { list.append(KeyValuePair(id: "chassis", key: "Plaats chassisnummer", value: v)) }
        if let v = wam_verzekerd { list.append(KeyValuePair(id: "wam", key: "WAM verzekerd", value: v)) }
        if let v = taxi_indicator { list.append(KeyValuePair(id: "taxi", key: "Taxi-indicator", value: v)) }
        if let v = export_indicator { list.append(KeyValuePair(id: "export", key: "Export-indicator", value: v)) }
        if let v = tenaamstellen_mogelijk { list.append(KeyValuePair(id: "tenaamstellen", key: "Tenaamstellen mogelijk", value: v)) }
        if let v = openstaande_terugroepactie_indicator { list.append(KeyValuePair(id: "terugroepactie", key: "Openstaande terugroepactie", value: v)) }
        if let v = wacht_op_keuren { list.append(KeyValuePair(id: "wacht_op_keuren", key: "Wacht op keuren", value: v)) }
        
        if let v = catalogusprijs, v > 0 {
            list.append(KeyValuePair(id: "catalogusprijs", key: "Catalogusprijs", value: formatEuro(v)))
        }
        if let v = bruto_bpm, v > 0 {
            list.append(KeyValuePair(id: "bruto_bpm", key: "Bruto BPM", value: formatEuro(v)))
        }
        if let v = tellerstandoordeel { list.append(KeyValuePair(id: "tellerstandoordeel", key: "Tellerstandoordeel", value: v)) }
        if let v = zuinigheidsclassificatie {
            var value = "Klasse \(v)"
            if let emissieGegevens = emissie_gegevens, !emissieGegevens.isEmpty {
                if let uitlaatemissieniveau = emissieGegevens.first?.uitlaatemissieniveau {
                    value += " - \(uitlaatemissieniveau)"
                }
            }
            list.append(KeyValuePair(id: "zuinigheid", key: "Energieklasse", value: value))
        }
        
        return list
    }
    
    func getEngineSpecifics() -> [KeyValuePair] {
        var list: [KeyValuePair] = []
        if let unwrapped = cilinderinhoud {
            list.append(KeyValuePair(id: "cilinderinhoud", key: "Cilinderinhoud", value: "\(Int(unwrapped)) cc"))
        }
        if let unwrapped = aantal_cilinders {
            if let inhoud = cilinderinhoud, unwrapped > 0 {
                let perCilinder = Int(inhoud) / unwrapped
                list.append(KeyValuePair(id: "inhoud_per_cilinder", key: "Inhoud per cilinder", value: "\(perCilinder) cc"))
            }
            list.append(KeyValuePair(id: "aantal_cilinders", key: "Aantal cilinders", value: "\(unwrapped)"))
        }
        return list
    }
    
    func getEmissieGegevens() -> [KeyValuePair] {
        var list: [KeyValuePair] = []
        emissie_gegevens?.forEach { gegevens in
            list += gegevens.generateKeyValueArray()
        }
        return list
    }
    
    func getDates() -> [KeyValuePair] {
        var list: [KeyValuePair] = []
        if let v = vervaldatum_apk {
            list.append(KeyValuePair(id: "apk", key: "Vervaldatum APK", value: formatDate(String(v)) ?? "N/A"))
        }
        if let v = vervaldatum_tachograaf {
            list.append(KeyValuePair(id: "tachograaf", key: "Vervaldatum tachograaf", value: formatDate(String(v)) ?? "N/A"))
        }
        if let v = datum_tenaamstelling {
            list.append(KeyValuePair(id: "tenaamstelling", key: "Datum tenaamstelling", value: formatDate(String(v)) ?? "N/A"))
        }
        if let v = datum_eerste_toelating {
            list.append(KeyValuePair(id: "toelating", key: "Datum eerste toelating", value: formatDate(String(v)) ?? "N/A"))
        }
        
        print(datum_eerste_toelating)
        print(datum_eerste_tenaamstelling_in_nederland)
        
        if datum_eerste_tenaamstelling_in_nederland != datum_eerste_toelating {
            if let v = datum_eerste_tenaamstelling_in_nederland {
                list.append(KeyValuePair(id: "tenaamstelling_nl", key: "Datum eerste tenaamstelling in NL", value: formatDate(String(v)) ?? "N/A"))
            }
        }
        return list
    }
    
    // Alleen velden die nog NIET eerder getoond zijn:
    func getTechnicalSpecs() -> [KeyValuePair] {
        var list: [KeyValuePair] = []
        
        if let v = lengte { list.append(KeyValuePair(id: "lengte", key: "Lengte", value: "\(Int(v)) cm")) }
        if let v = breedte { list.append(KeyValuePair(id: "breedte", key: "Breedte", value: "\(Int(v)) cm")) }
        if let v = hoogte_voertuig { list.append(KeyValuePair(id: "hoogte", key: "Hoogte", value: "\(Int(v)) cm")) }
        if let v = wielbasis { list.append(KeyValuePair(id: "wielbasis", key: "Wielbasis", value: "\(Int(v)) cm")) }
        if let v = massa_ledig_voertuig { list.append(KeyValuePair(id: "massa_ledig", key: "Massa ledig", value: "\(Int(v)) kg")) }
        if let v = massa_rijklaar { list.append(KeyValuePair(id: "massa_rijklaar", key: "Massa rijklaar", value: "\(Int(v)) kg")) }
        if let v = toegestane_maximum_massa_voertuig { list.append(KeyValuePair(id: "max_massa", key: "Max massa voertuig", value: "\(Int(v)) kg")) }
        if let v = technische_max_massa_voertuig { list.append(KeyValuePair(id: "technische_max", key: "Technische max massa", value: "\(Int(v)) kg")) }
        if let v = maximum_massa_trekken_ongeremd { list.append(KeyValuePair(id: "trek_ongeremd", key: "Trekgewicht ongeremd", value: "\(Int(v)) kg")) }
        if let v = maximum_trekken_massa_geremd { list.append(KeyValuePair(id: "trek_geremd", key: "Trekgewicht geremd", value: "\(Int(v)) kg")) }
        if let v = maximum_massa_samenstelling { list.append(KeyValuePair(id: "samenstelling", key: "Max massa samenstelling", value: "\(Int(v)) kg")) }
        if let v = laadvermogen { list.append(KeyValuePair(id: "laadvermogen", key: "Laadvermogen", value: "\(Int(v)) kg")) }
        if let v = oplegger_geremd { list.append(KeyValuePair(id: "oplegger", key: "Oplegger geremd", value: "\(Int(v)) kg")) }
        if let v = aanhangwagen_autonoom_geremd { list.append(KeyValuePair(id: "aanhang_autonoom", key: "Aanhangwagen autonoom geremd", value: "\(Int(v)) kg")) }
        if let v = aanhangwagen_middenas_geremd { list.append(KeyValuePair(id: "aanhang_middenas", key: "Aanhangwagen middenas geremd", value: "\(v) kg")) }
        if let v = afwijkende_maximum_snelheid { list.append(KeyValuePair(id: "afwijkende_snelheid", key: "Afwijkende maximum snelheid", value: "\(Int(v)) km/u")) }
        if let v = maximum_constructiesnelheid { list.append(KeyValuePair(id: "max_constructie", key: "Maximum constructiesnelheid", value: "\(Int(v)) km/u")) }
        if let v = maximum_ondersteunende_snelheid { list.append(KeyValuePair(id: "max_ondersteuning", key: "Maximum ondersteunende snelheid", value: "\(Int(v)) km/u")) }
        if let v = subcategorie_nederland { list.append(KeyValuePair(id: "subcategorie", key: "Subcategorie NL", value: v)) }
        if let v = verticale_belasting_koppelpunt_getrokken_voertuig { list.append(KeyValuePair(id: "verticaal", key: "Verticale belasting koppelpunt", value: "\(Int(v)) kg")) }
        if let v = vermogen_massarijklaar { list.append(KeyValuePair(id: "vermogen_massarijklaar", key: "Vermogen massarijklaar", value: "\(v) KW/kg")) }
        if let v = jaar_laatste_registratie_tellerstand { list.append(KeyValuePair(id: "jaar_teller", key: "Jaar laatste tellerstand registratie", value: "\(v)")) }
        if let v = wielbasis_voertuig_minimum { list.append(KeyValuePair(id: "wb_min", key: "Wielbasis min", value: "\(Int(v)) cm")) }
        if let v = wielbasis_voertuig_maximum { list.append(KeyValuePair(id: "wb_max", key: "Wielbasis max", value: "\(Int(v)) cm")) }
        if let v = lengte_voertuig_minimum { list.append(KeyValuePair(id: "len_min", key: "Lengte min", value: "\(Int(v)) cm")) }
        if let v = lengte_voertuig_maximum { list.append(KeyValuePair(id: "len_max", key: "Lengte max", value: "\(Int(v)) cm")) }
        if let v = breedte_voertuig_minimum { list.append(KeyValuePair(id: "br_min", key: "Breedte min", value: "\(Int(v)) cm")) }
        if let v = breedte_voertuig_maximum { list.append(KeyValuePair(id: "br_max", key: "Breedte max", value: "\(Int(v)) cm")) }
        if let v = hoogte_voertuig_minimum { list.append(KeyValuePair(id: "hoogte_min", key: "Hoogte min", value: "\(Int(v)) cm")) }
        if let v = hoogte_voertuig_maximum { list.append(KeyValuePair(id: "hoogte_max", key: "Hoogte max", value: "\(Int(v)) cm")) }
        if let v = massa_bedrijfsklaar_minimaal { list.append(KeyValuePair(id: "massa_bk_min", key: "Massa bedrijfsklaar min", value: "\(Int(v)) kg")) }
        if let v = massa_bedrijfsklaar_maximaal { list.append(KeyValuePair(id: "massa_bk_max", key: "Massa bedrijfsklaar max", value: "\(Int(v)) kg")) }
        if let v = technisch_toelaatbaar_massa_koppelpunt { list.append(KeyValuePair(id: "massa_koppelpunt", key: "Technisch toelaatbaar massa koppelpunt", value: "\(Int(v)) kg")) }
        if let v = maximum_massa_technisch_maximaal { list.append(KeyValuePair(id: "max_massa_technisch_max", key: "Maximum massa technisch maximaal", value: "\(Int(v)) kg")) }
        if let v = maximum_massa_technisch_minimaal { list.append(KeyValuePair(id: "max_massa_technisch_min", key: "Maximum massa technisch minimaal", value: "\(Int(v)) kg")) }
        if let v = registratie_datum_goedkeuring_afschrijvingsmoment_bpm { list.append(KeyValuePair(id: "registratie_bpm", key: "Registratiedatum goedkeuring BPM", value: "\(v)")) }
        if let v = gemiddelde_lading_waarde { list.append(KeyValuePair(id: "gemiddelde_lading", key: "Gemiddelde lading waarde", value: "\(Int(v)) kg")) }
        if let v = aerodynamische_voorziening_of_uitrusting { list.append(KeyValuePair(id: "aero", key: "Aerodynamische voorziening/uitrusting", value: v)) }
        if let v = additionele_massa_alternatieve_aandrijving { list.append(KeyValuePair(id: "massa_alternatief", key: "Additionele massa alternatieve aandrijving", value: "\(Int(v)) kg")) }
        if let v = verlengde_cabine_indicator { list.append(KeyValuePair(id: "verlengde_cabine", key: "Verlengde cabine-indicator", value: v)) }
        
        return list
    }
    
    func generateKeyValueArray() -> [KeyValuePair] {
        var list: [KeyValuePair] = []
        if let image = getImage() { list.append(image) }
        list.append(getKenteken())
        list += getCarInformation()
        list += getEngineSpecifics()
        list += getEmissieGegevens()
        list += getDates()
        list += getTechnicalSpecs()
        list += [KeyValuePair(id: "empty", key: "", value: "")]
        return list
    }
    
    func getImage() -> KeyValuePair? {
        if let image = images?.first {
            return KeyValuePair(id: "imageURL", key: "imageURL", value: image.file_path)
        }
        return nil
    }
    
    func getImageURLs() -> [String] {
        images?.map { $0.file_path } ?? []
    }
    
    func formatDate(_ inputDateString: String) -> String? {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd"
        if let date = f.date(from: inputDateString) {
            let out = DateFormatter()
            out.dateFormat = "dd MMMM yyyy"
            out.locale = Locale(identifier: "nl_NL")
            return out.string(from: date)
        }
        return nil
    }
}

// MARK: - Helpers

struct KeyValuePair: Decodable, Identifiable {
    let id: String
    let key: String
    let value: String
}

struct EmissieGegevens: Decodable {
    let id: Int
    let gekentekende_voertuig_id: Int
    let brandstof_omschrijving: String
    let brandstofverbruik_buiten_de_stad: String?
    let brandstofverbruik_gecombineerd: String?
    let brandstofverbruik_stad: String?
    let co2_uitstoot_gecombineerd: String?
    let co2_uitstoot_gewogen: String?
    let geluidsniveau_rijdend: String?
    let geluidsniveau_stationair: String?
    let emissieklasse: String?
    let milieuklasse_eg_goedkeuring_licht: String?
    let milieuklasse_eg_goedkeuring_zwaar: String?
    let uitstoot_deeltjes_licht: String?
    let uitstoot_deeltjes_zwaar: String?
    let nettomaximumvermogen: String?
    let nominaal_continu_maximumvermogen: String?
    let roetuitstoot: String?
    let toerental_geluidsniveau: String?
    let emissie_deeltjes_type1_wltp: Double?
    let emissie_co2_gecombineerd_wltp: Double?
    let emissie_co2_gewogen_gecombineerd_wltp: Double?
    let brandstof_verbruik_gecombineerd_wltp: Double?
    let brandstof_verbruik_gewogen_gecombineerd_wltp: Double?
    let elektrisch_verbruik_enkel_elektrisch_wltp: Double?
    let actie_radius_enkel_elektrisch_wltp: Double?
    let actie_radius_enkel_elektrisch_stad_wltp: Double?
    let elektrisch_verbruik_extern_opladen_wltp: Double?
    let actie_radius_extern_opladen_wltp: Double?
    let actie_radius_extern_opladen_stad_wltp: Double?
    let max_vermogen_15_minuten: Double?
    let max_vermogen_60_minuten: Double?
    let netto_max_vermogen_elektrisch: Double?
    let klasse_hybride_elektrisch_voertuig: String?
    let opgegeven_maximum_snelheid: Double?
    let uitlaatemissieniveau: String?
    let maximum_massa_trekken_ongeremd: Double?
    let maximum_massa_trekken_geremd: Double?
    
    func getBrandstofOmschrijving() -> String {
        if brandstof_omschrijving == "Elektriciteit" {
            return "Elektrisch"
        }
        return brandstof_omschrijving
    }
    
    func getVermogen() -> KeyValuePair? {
        if let v = nettomaximumvermogen, let kw = Double(v) {
            let pk = Int((kw * 1.35962).rounded())
            return KeyValuePair(id: "vermogen_\(getBrandstofOmschrijving())", key: "\(getBrandstofOmschrijving()) vermogen", value: "\(Int(kw)) kW / \(pk) PK")
        }
        if let kw = netto_max_vermogen_elektrisch {
            let pk = Int((kw * 1.35962).rounded())
            return KeyValuePair(id: "vermogen_\(getBrandstofOmschrijving())", key: "\(getBrandstofOmschrijving()) vermogen", value: "\(Int(kw)) kW / \(pk) PK")
        }
        return nil
    }
    
    func getBrandstofVerbruik() -> [KeyValuePair] {
        func format(_ s: String, label: String) -> KeyValuePair {
            if let val = Double(s) {
                let km = Int((100 / val).rounded())
                return KeyValuePair(id: label, key: label, value: "\(s.replacingOccurrences(of: ".", with: ",")) L/100km (\(km) km/l)")
            }
            return KeyValuePair(id: label, key: label, value: "\(s) L/100km")
        }
        var list: [KeyValuePair] = []
        if let v = brandstofverbruik_stad { list.append(format(v, label: "Brandstof verbruik stad")) }
        if let v = brandstofverbruik_buiten_de_stad { list.append(format(v, label: "Brandstof verbruik buiten stad")) }
        if let v = brandstofverbruik_gecombineerd { list.append(format(v, label: "Brandstof verbruik gecombineerd")) }
        return list
    }
    
    func getEmissieExtra() -> [KeyValuePair] {
        var list: [KeyValuePair] = []
        if let v = co2_uitstoot_gecombineerd { list.append(KeyValuePair(id: "co2", key: "CO₂-uitstoot gecombineerd", value: "\(v) g/km")) }
        if let v = emissieklasse { list.append(KeyValuePair(id: "emissieklasse", key: "Emissieklasse", value: v)) }
        if let v = milieuklasse_eg_goedkeuring_licht { list.append(KeyValuePair(id: "milieuklasse", key: "Milieuklasse EG", value: v)) }
        if let v = uitlaatemissieniveau { list.append(KeyValuePair(id: "uitlaat", key: "\(getBrandstofOmschrijving()) Uitlaatemissieniveau", value: v)) }
        if let v = geluidsniveau_rijdend { list.append(KeyValuePair(id: "geluid_rijdend", key: "Geluidsniveau rijdend", value: "\(v) dB")) }
        if let v = geluidsniveau_stationair { list.append(KeyValuePair(id: "geluid_stationair", key: "Geluidsniveau stationair", value: "\(v) dB")) }
        return list
    }
    
    func generateKeyValueArray() -> [KeyValuePair] {
        var list: [KeyValuePair] = []
        if let vermogen = getVermogen() { list.append(vermogen) }
        list += getBrandstofVerbruik()
        list += getEmissieExtra()
        return list
    }
}

struct CarrosserieGegevens: Decodable {
    let id: Int
    let gekentekende_voertuig_id: Int
    let carrosserie_volgnummer: String
    let carrosserietype: String
    let type_carrosserie_europese_omschrijving: String
}

struct Image: Decodable {
    let file_path: String
}

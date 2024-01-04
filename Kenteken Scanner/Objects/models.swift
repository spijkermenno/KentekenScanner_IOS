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
    
    func getKenteken() -> KeyValuePair {
        return KeyValuePair(
            id: "kenteken",
            key: "kenteken",
            value: kenteken
        )
    }
    
    func getEngineSpecifics() -> [KeyValuePair] {
        var list: [KeyValuePair] = []
        var cilinderInhoud: Double?
        
        if let unwrapped = cilinderinhoud {
            cilinderInhoud = unwrapped
            list.append(KeyValuePair(id: "cilinderinhoud", key: "Cilinderinhoud", value: "\(Int(unwrapped))cc"))
        }
        
        if let unwrapped = aantal_cilinders {
            if let unwrappedCilinderInhoud = cilinderInhoud {
                if unwrapped > 1 {
                    let calculation = Int(unwrappedCilinderInhoud) / unwrapped
                    list.append(KeyValuePair(id: "inhoud_per_cilinder", key: "Inhoud per cilinder (berekend)", value: "\(calculation)cc"))
                }
            }
            
            list.append(KeyValuePair(id: "aantal_cilinders", key: "Aantal cilinders", value: "\(unwrapped)"))
        }
        
        return list
    }
    
    func getEmissieGegevens() -> [KeyValuePair] {
        var list: [KeyValuePair] = []
        
        emissie_gegevens?.forEach { gegevens in
            gegevens.generateKeyValueArray().forEach { item in
                list.append(item)
            }
        }
        
        return list
    }
    
    func getCarInformation() -> [KeyValuePair] {
        func formatNumberToEuro(_ amount: Int) -> String? {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .currency
            numberFormatter.currencyCode = "EUR"

             numberFormatter.locale = Locale(identifier: "nl_NL")

            let formattedAmount = numberFormatter.string(from: NSNumber(value: amount))
            return formattedAmount
        }
        
        func formatNumberToEuro(_ amount: Double) -> String? {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .currency
            numberFormatter.currencyCode = "EUR"

            numberFormatter.locale = Locale(identifier: "nl_NL")

            let formattedAmount = numberFormatter.string(from: NSNumber(value: amount))
            return formattedAmount
        }
        
        var list: [KeyValuePair] = []
        
        if let unwrapped = merk {
            list.append(KeyValuePair(id: "merk", key: "Merk", value: unwrapped))
        }
        
        if let unwrapped = handelsbenaming {
            list.append(KeyValuePair(id: "handelsbenaming", key: "Handelsbenaming", value: unwrapped))
        }
        
        var unwrappedType = type ?? "N/A"
        var unwrappedVariant = variant ?? "N/A"
        var unwrappedUitvoering = uitvoering ?? "N/A"
        
        if type != nil || variant != nil || uitvoering != nil {
            list.append(KeyValuePair(id: "type_variant_uitvoering", key: "Type, Variant & Uitvoering", value: "\(unwrappedType), \(unwrappedVariant) & \(unwrappedUitvoering)"))
        }
        
        if let unwrapped = eerste_kleur {
            list.append(KeyValuePair(id: "eerste_kleur", key: "Eerste kleur", value: unwrapped))
        }
        
        if let unwrapped = tweede_kleur {
            list.append(KeyValuePair(id: "tweede_kleur", key: "Tweede kleur", value: unwrapped))
        }
        
        if let unwrapped = catalogusprijs {
            if unwrapped > 0.0 {
                let value = formatNumberToEuro(unwrapped) ?? "Niet beschikbaar"
                list.append(KeyValuePair(id: "catalogusprijs", key: "Catalogusprijs", value: "\(value)"))
            }
        }
        
        if let unwrapped = aantal_deuren {
            if unwrapped > 0 {
                list.append(KeyValuePair(id: "aantal_deuren", key: "Aantal deuren", value: "\(unwrapped)"))
            }
        }
        
        if let unwrapped = aantal_wielen {
            if unwrapped > 0 {
                list.append(KeyValuePair(id: "aantal_wielen", key: "Aantal wielen", value: "\(unwrapped)"))
            }
        }
        
        if let unwrapped = lengte {
            if unwrapped > 0 {
                list.append(KeyValuePair(id: "lengte", key: "Lengte", value: "\(Int(unwrapped)) cm"))
            }
        }
        
        if let unwrapped = breedte {
            if unwrapped > 0 {
                list.append(KeyValuePair(id: "breedte", key: "Breedte", value: "\(Int(unwrapped)) cm"))
            }
        }
        
        if let unwrapped = tellerstandoordeel {
            list.append(KeyValuePair(id: "tellerstandoordeel", key: "Tellerstandoordeel", value: unwrapped))
        }
        
        if let unwrapped = zuinigheidsclassificatie {
            var value = "Klasse \(unwrapped)"
            
            if let emissieGegevens = emissie_gegevens {
                if !emissieGegevens.isEmpty {
                    let uitlaatemissieniveau = emissieGegevens.first?.uitlaatemissieniveau
                    
                    if let unwrappedUitlaatemissieniveau = uitlaatemissieniveau {
                        value += " - \(unwrappedUitlaatemissieniveau)"
                    }
                }
            }
            
            list.append(KeyValuePair(id: "zuinigheidsclassificatie", key: "Energie klasse (zuinigheidsclassificatie)", value: value))
        }
        
        return list
    }
    
    func getDates() -> [KeyValuePair] {
        var list: [KeyValuePair] = []
        
        if let unwrapped = vervaldatum_apk {
            var datum = formatDate(String(unwrapped)) ?? "N/A"
            
            list.append(KeyValuePair(id: "vervaldatum_apk", key: "Verval datum APK", value: datum))
        }
        
        if let unwrapped = vervaldatum_tachograaf {
            var datum = formatDate(String(unwrapped)) ?? "N/A"
            
            list.append(KeyValuePair(id: "vervaldatum_tachograaf", key: "Verval datum tachograaf", value: datum))
        }
        
        if let unwrapped = datum_tenaamstelling {
            var datum = formatDate(String(unwrapped)) ?? "N/A"
            
            list.append(KeyValuePair(id: "datum_tenaamstelling", key: "Datum tenaamstelling", value: datum))
        }
        
        var datumEersteToelating: String?
        var datumEersteTenaamstellingInNederland: String?
        
        if let unwrapped = datum_eerste_toelating {
            datumEersteToelating = String(unwrapped)
            
            var datum = formatDate(datumEersteToelating!) ?? "N/A"
            
            list.append(KeyValuePair(id: "datum_eerste_toelating", key: "Datum eerste toelating", value: datum))
        }
        
        if let unwrapped = datum_eerste_tenaamstelling_in_nederland {
            datumEersteTenaamstellingInNederland = String(unwrapped)
            
            var datum = formatDate(datumEersteTenaamstellingInNederland!) ?? "N/A"
            
            list.append(KeyValuePair(id: "datum_eerste_tenaamstelling_in_nederland", key: "Datum eerste tenaamstelling in Nederland", value: datum))
            
            if datumEersteToelating != nil {
                if isDateBefore(datumEersteToelating!, before: datumEersteTenaamstellingInNederland!) {
                    list.append(KeyValuePair(id: "geimporteerd", key: "Geïmporteerd", value: "Ja, op \(datum)"))
                } else {
                    list.append(KeyValuePair(id: "geimporteerd", key: "Geïmporteerd", value: "Nee"))
                }
            }
        }
        
        return list
    }
    
    func isDateBefore(_ dateStr1: String, before dateStr2: String, format: String = "yyyyMMdd") -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format

        if let date1 = dateFormatter.date(from: dateStr1),
           let date2 = dateFormatter.date(from: dateStr2) {
            return date1 < date2
        }

        return false // Return false if there are any issues with date conversion
    }
    
    func generateKeyValueArray() -> [KeyValuePair] {
        var list: [KeyValuePair] = []
        
        list.append(getKenteken())
        
        list += getCarInformation()
        list += getEngineSpecifics()
        list += getEmissieGegevens()
        list += getDates()
        
        return list
    }
    
    func formatDate(_ inputDateString: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyyMMdd"

        if let date = inputFormatter.date(from: inputDateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd MMMM yyyy"
            outputFormatter.locale = Locale(identifier: "nl_NL")

            return outputFormatter.string(from: date)
        }

        return nil
    }
}

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
    
    func getVermogen() -> KeyValuePair? {
        let id = "vermogen \(brandstof_omschrijving)"
        
        if let unwrapped = nettomaximumvermogen {
            var pk: Double = 0.0
            var kw: Double = 0.0
            
            if let unwrappedKW = Double(unwrapped) {
                pk = unwrappedKW * 1.35962
                kw = unwrappedKW
            }
            return KeyValuePair(id: id, key: "\(brandstof_omschrijving) vermogen", value: "\(Int(kw)) KW / \(Int(pk.rounded())) PK")
        }
        
        if let unwrapped = netto_max_vermogen_elektrisch {
            var pk: Double = 0.0
             
            pk = unwrapped * 1.35962
            
            return KeyValuePair(id: id, key: "\(brandstof_omschrijving) vermogen", value: "\(Int(unwrapped)) KW / \(Int(pk.rounded())) PK")
        }
        
        
        return nil
    }
    
    func getBrandstofVerbruik() -> [KeyValuePair] {
        func calculate(fuelUsageValue: String) -> String {
            let fuelUsageDouble = Double(fuelUsageValue)
            
            var fuelUsage: String = "\(fuelUsageValue) liter op 100 kilometer"
            
            if let unwrappedFuelUsage = fuelUsageDouble {
                let fuelUsageCalculated = 100 / unwrappedFuelUsage
                fuelUsage += " / 1 liter op \(Int(fuelUsageCalculated.rounded())) kilometer"
            }
            
            return fuelUsage.replacingOccurrences(of: ".", with: ",")
        }
        
        var list: [KeyValuePair] = []
        
        if let unwrapped = brandstofverbruik_stad {
            list.append(KeyValuePair(id: "brandstofverbruik_stad", key: "Brandstof verbruik stadsverkeer", value: calculate(fuelUsageValue: unwrapped)))
        }
        
        if let unwrapped = brandstofverbruik_buiten_de_stad {
            list.append(KeyValuePair(id: "brandstofverbruik_buiten_de_stad", key: "Brandstof verbruik buiten de stad", value: calculate(fuelUsageValue: unwrapped)))
        }
        
        if let unwrapped = brandstofverbruik_gecombineerd {
            list.append(KeyValuePair(id: "brandstofverbruik_gecombineerd", key: "Brandstof verbruik gecombineerd", value: calculate(fuelUsageValue: unwrapped)))
        }
        
        return list
    }
    
    func generateKeyValueArray() -> [KeyValuePair] {
        var list: [KeyValuePair] = []
        
        // region nullables
        if let unwrapped = getVermogen() { list.append(unwrapped) }
        
        // region lists
        list += (getBrandstofVerbruik())
        
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

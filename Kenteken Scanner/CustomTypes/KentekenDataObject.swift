//
//  KentekenDataObject.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 16/03/2021.
//

import Foundation

struct kentekenDataObject: Decodable {
    // voertuig algemeen
    // https://opendata.rdw.nl/resource/m9d7-ebf2.json
    
    var kenteken: String!
    var voertuigsoort: String!
    var merk: String!
    var handelsbenaming: String!
    var inrichting: String!
    var eerste_kleur: String!
    var tweede_kleur: String!
    var zuinigheidslabel: String!
    var wacht_op_keuren: String!
    var wam_verzekerd: String!
    var europese_voertuigcategorie: String!
    var europese_voertuigcategorie_toevoeging: String!
    var europese_uitvoeringcategorie_toevoeging: String!
    var plaats_chassisnummer: String!
    var type: String!
    var type_gasinstallatie: String!
    var typegoedkeuringsnummer: String!
    var variant: String!
    var uitvoering: String!
    var export_indicator: String!
    var openstaande_terugroepactie_indicator: String!
    var api_gekentekende_voertuigen_assen: String!
    var api_gekentekende_voertuigen_brandstof: String!
    var api_gekentekende_voertuigen_carrosserie: String!
    var api_gekentekende_voertuigen_carrosserie_specifiek: String!
    var api_gekentekende_voertuigen_voertuigklasse: String!

    // number values stored in strings.
    var vervaldatum_apk: String!
    var datum_tenaamstelling: String!
    var bruto_bpm: String!
    var aantal_zitplaatsen: String!
    var aantal_cilinders: String!
    var cilinderinhoud: String!
    var massa_ledig_voertuig: String!
    var toegestane_maximum_massa_voertuig: String!
    var massa_rijklaar: String!
    var maximum_massa_trekken_ongeremd: String!
    var maximum_trekken_massa_geremd: String!
    var datum_eerste_toelating: String!
    var datum_eerste_afgifte_nederland: String!
    var catalogus_prijs: String!
    var maximale_constructiesnelheid_brom_snorfiets: String!
    var laadvermogen: String!
    var oplegger_geremd: String!
    var aanhangwagen_autonoom_geremd: String!
    var aanhangwagen_middenas_geremd: String!
    var vermogen_brom_snorfiets: String!
    var aantal_staanplaatsen: String!
    var aantal_deuren: String!
    var aantal_wielen: String!
    var afstand_hart_koppeling_tot_achterzijde_voertuig: String!
    var afstand_voorzijde_voertuig_tot_hart_koppeling: String!
    var afwijkende_maximum_snelheid: String!
    var lengte: String!
    var breedte: String!
    var technische_max_massa_voertuig: String!
    var volgnummer_wijziging_eu_typegoedkeuring: String!
    var vermogen_massarijklaar: String!
    var wielbasis: String!
    var vervaldatum_tachograaf: String!
    var taxi_indicator: String!
    var maximum_massa_samenstelling: String!
    var aantal_rolstoelplaatsen: String!
    var maximum_ondersteunende_snelheid: String!
    
    // voertuig assen
    // https://opendata.rdw.nl/resource/3huj-srit.json
    
    var as_nummer: String!
    var aantal_assen: String!
    var aangedreven_as: String!
    var hefas: String!
    var plaatscode_as: String!
    var spoorbreedte: String!
    
    // voertuig brandstof
    // https://opendata.rdw.nl/resource/8ys7-d773.json
    
    var brandstof_volgnummer: String!
    var brandstof_omschrijving: String!
    var brandstofverbruik_buiten: String!
    var brandstofverbruik_gecombineerd: String!
    var brandstofverbruik_stad: String!
    var co2_uitstoot_gecombineerd: String!
    
    // voertuig carrosserie
    // https://opendata.rdw.nl/resource/vezc-m2t6.json
    
    var carrosserie_volgnummer: String!
    var carrosserietype: String!
    var type_carrosserie_europese_omschrijving: String!
    
    // voertuig carrosserie specifiek
    // https://opendata.rdw.nl/resource/jhie-znh9.json
    
    var carrosserie_voertuig_nummer_code_volgnummer: String!
    var carrosseriecode: String!
    var carrosserie_voertuig_nummer_europese_omschrijving: String!
    
    // voertuig voertuigklasse
    // https://opendata.rdw.nl/resource/kmfi-hrps.json
    
    var carrosserie_klasse_volgnummer: String!
    var voertuigklasse: String!
    var voertuigklasse_omschrijving: String!
}

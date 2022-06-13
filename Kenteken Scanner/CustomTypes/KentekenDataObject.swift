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
    
    var imageURL: String!
    var kenteken: String!
    var merk: String!
    var handelsbenaming: String!
    var vermogen_PK: String!
    var vermogen_KW: String!
    var aantal_cilinders: String!
    var cilinderinhoud: String!
    var vervaldatum_apk: String!
    var vervaldatum_tachograaf: String!
    var datum_tenaamstelling: String!
    var datum_eerste_toelating: String!
    var datum_eerste_afgifte_nederland: String!
    var voertuig_geimporteerd: String!
    var catalogus_prijs: String!
    var laadvermogen: String!
    var lengte: String!
    var breedte: String!
    var brandstof_omschrijving: String!
    var brandstofverbruik_buiten: String!
    var brandstofverbruik_gecombineerd: String!
    var brandstofverbruik_stad: String!

    var voertuigsoort: String!
    var inrichting: String!
    var eerste_kleur: String!
    var tweede_kleur: String!
    var zuinigheidslabel: String!
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

    // number values stored in strings.
    var bruto_bpm: String!
    var aantal_zitplaatsen: String!

    var massa_ledig_voertuig: String!
    var toegestane_maximum_massa_voertuig: String!
    var massa_rijklaar: String!
    var maximum_massa_trekken_ongeremd: String!
    var maximum_trekken_massa_geremd: String!
    var maximale_constructiesnelheid_brom_snorfiets: String!
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
    var technische_max_massa_voertuig: String!
    var vermogen_massarijklaar: String!
    var wielbasis: String!
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
    
    var co2_uitstoot_gecombineerd: String!
    
    // voertuig carrosserie
    // https://opendata.rdw.nl/resource/vezc-m2t6.json
    
    var carrosserietype: String!
    var type_carrosserie_europese_omschrijving: String!
    
    // voertuig carrosserie specifiek
    // https://opendata.rdw.nl/resource/jhie-znh9.json
    
    var carrosseriecode: String!
    var carrosserie_voertuig_nummer_europese_omschrijving: String!
    
    // voertuig voertuigklasse
    // https://opendata.rdw.nl/resource/kmfi-hrps.json
    
    var voertuigklasse: String!
    var voertuigklasse_omschrijving: String!
}

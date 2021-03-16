//
//  KentekenDataObject.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 16/03/2021.
//

import Foundation

struct kentekenDataObject: Decodable {
    var kenteken: String?
    var voertuigsoort: String?
    var merk: String?
    var handelsbenaming: String?
    var inrichting: String?
    var eerste_kleur: String?
    var tweede_kleur: String?
    var zuinigheidslabel: String?
    var wacht_op_keuren: String?
    var wam_verzekerd: String?
    var europese_voertuigcategorie: String?
    var europese_voertuigcategorie_toevoeging: String?
    var europese_uitvoeringcategorie_toevoeging: String?
    var plaats_chassisnummer: String?
    var type: String?
    var type_gasinstallatie: String?
    var typegoedkeuringsnummer: String?
    var variant: String?
    var uitvoering: String?
    var export_indicator: String?
    var openstaande_terugroepactie_indicator: String?
    var api_gekentekende_voertuigen_assen: String?
    var api_gekentekende_voertuigen_brandstof: String?
    var api_gekentekende_voertuigen_carrosserie: String?
    var api_gekentekende_voertuigen_carrosserie_specifiek: String?
    var api_gekentekende_voertuigen_voertuigklasse: String?
    
    // number values stored in strings.
    var vervaldatum_apk: String?
    var datum_tenaamstelling: String?
    var bruto_bpm: String?
    var aantal_zitplaatsen: String?
    var aantal_cilinders: String?
    var cilinderinhoud: String?
    var massa_ledig_voertuig: String?
    var toegestane_maximum_massa_voertuig: String?
    var massa_rijklaar: String?
    var maximum_massa_trekken_ongeremd: String?
    var maximum_trekken_massa_geremd: String?
    var datum_eerste_toelating: String?
    var datum_eerste_afgifte_nederland: String?
    var catalogus_prijs: String?
    var maximale_constructiesnelheid_brom_snorfiets: String?
    var laadvermogen: String?
    var oplegger_geremd: String?
    var aanhangwagen_autonoom_geremd: String?
    var aanhangwagen_middenas_geremd: String?
    var vermogen_brom_snorfiets: String?
    var aantal_staanplaatsen: String?
    var aantal_deuren: String?
    var aantal_wielen: String?
    var afstand_hart_koppeling_tot_achterzijde_voertuig: String?
    var afstand_voorzijde_voertuig_tot_hart_koppeling: String?
    var afwijkende_maximum_snelheid: String?
    var lengte: String?
    var breedte: String?
    var technische_max_massa_voertuig: String?
    var volgnummer_wijziging_eu_typegoedkeuring: String?
    var vermogen_massarijklaar: String?
    var wielbasis: String?
    var vervaldatum_tachograaf: String?
    var taxi_indicator: String?
    var maximum_massa_samenstelling: String?
    var aantal_rolstoelplaatsen: String?
    var maximum_ondersteunende_snelheid: String?
}

//
//  KentekenDataObject.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 16/03/2021.
//

import Foundation

struct PowerData: Decodable {
    var brandstofOmschrijving: String!
    var key: String!
    var vermogen_kw: Double!
}

struct KentekenDataObject: Decodable {
    var imageURL: String?
    var asNummer: String?
    var aantalAssen: String?
    var aangedrevenAs: String?
    var plaatscodeAs: String?
    var spoorbreedte: String?
    var vermogen: [PowerData]?
    var wettelijkToegestaneMaximumAslast: String?
    var technischToegestaneMaximumAslast: String?
    var afstandTotVolgendeAsVoertuig: String?
    var carrosserieVolgnummer: String?
    var carrosserietype: String?
    var typeCarrosserieEuropeseOmschrijving: String?
    var kenteken: String?
    var voertuigsoort: String?
    var merk: String?
    var handelsbenaming: String?
    var vervaldatumApk: String?
    var datumTenaamstelling: String?
    var brutoBpm: String?
    var inrichting: String?
    var aantalZitplaatsen: String?
    var eersteKleur: String?
    var tweedeKleur: String?
    var aantalCilinders: String?
    var cilinderinhoud: String?
    var massaLedigVoertuig: String?
    var toegestaneMaximumMassaVoertuig: String?
    var massaRijklaar: String?
    var datumEersteToelating: String?
    var datumEersteTenaamstellingInNederland: String?
    var wachtOpKeuren: String?
    var catalogusprijs: String?
    var wamVerzekerd: String?
    var maximaleConstructiesnelheid: String?
    var aantalDeuren: String?
    var aantalWielen: String?
    var lengte: String?
    var breedte: String?
    var europeseVoertuigcategorie: String?
    var technischeMaxMassaVoertuig: String?
    var type: String?
    var typegoedkeuringsnummer: String?
    var variant: String?
    var uitvoering: String?
    var volgnummerWijzigingEuTypegoedkeuring: String?
    var vermogenMassarijklaar: String?
    var wielbasis: String?
    var exportIndicator: String?
    var openstaandeTerugroepactieIndicator: String?
    var taxiIndicator: String?
    var jaarLaatsteRegistratieTellerstand: String?
    var tellerstandoordeel: String?
    var codeToelichtingTellerstandoordeel: String?
    var tenaamstellenMogelijk: String?
    var vervaldatumApkDt: String?
    var datumTenaamstellingDt: String?
    var datumEersteToelatingDt: String?
    var datumEersteTenaamstellingInNederlandDt: String?
    var hoogteVoertuig: String?
    var zuinigheidsclassificatie: String?
    var registratieDatumGoedkeuringAfschrijvingsmomentBpm: String?
    var registratieDatumGoedkeuringAfschrijvingsmomentBpmDt: String?
}

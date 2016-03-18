require 'fileutils'
require 'open-uri'
require 'json'
require 'nokogiri'
require 'byebug'

entry = File.open("zip.csv")
content = entry.read
puts "Unzipped !"
titles = content.split("\n")[0].split(";").map { |title| title.tr("\"", "") }
puts "Column titles extracted !"
puts "Preparing to work on data."
raw_data = content.split("\n")[1..-1].map { |e| e.split(";").map { |e| e.tr("\"", "") } }
puts "Selecting pharmacists only..."
pharmacians = raw_data.select { |e| e[titles.index("Libellé profession")] == "Pharmacien" }
puts "Selecting pharmacists with email addresses only..."
pharmacians_with_addresses = pharmacians.select{ |e| e[titles.index("Adresse e-mail (coord. structure)")] != ""}

p pharmacians_with_addresses.length

=begin
api_data = {
  version: "yolo",
  data: pharmacians.map do |p|
    {
      rpps_id: p[titles.index("Identifiant PP")],
      first_name: p[titles.index("Prénom d'exercice")],
      last_name: p[titles.index("Nom d'exercice")],
      siret: p[titles.index("Numéro SIRET site")],
      siren: p[titles.index("Numéro SIREN site")],
      finess: p[titles.index("Numéro FINESS site")],
      address: {
        number: p[titles.index("Numéro Voie (coord. structure)")],
        repeat: p[titles.index("Indice répétition voie (coord. Structure)")],
        street_type: p[titles.index("Libellé type de voie (coord. structure)")],
        street_name: p[titles.index("Libellé Voie (coord. structure)")],
        distribution: p[titles.index("Mention distribution (coord. structure)")],
        cedex: p[titles.index("Bureau cedex (coord. structure)")],
        zipcode: p[titles.index("Code postal (coord. structure)")],
        city_name: p[titles.index("Libellé commune (coord. structure)")],
        country_name: p[titles.index("Libellé pays (coord. structure)")],
        phone_number: p[titles.index("Téléphone (coord. structure)")],
        email_address: p[titles.index("Adresse e-mail (coord. structure)")]
     }
    }
  end
}
=end

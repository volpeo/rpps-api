require 'fileutils'
require 'open-uri'
require 'json'
require 'zipruby'
require 'nokogiri'
require './models/pharmacist'
require './models/version'


def refresh_ids

  puts "Currently using : DBv#{Version.first.number}."

  url =  Nokogiri::HTML.parse(open("https://annuaire.sante.fr/web/site-pro/extractions-publiques")).css(".col_4a a")[0]["href"]
  version = url.split(".zip")[0].split("_")[-1]
  puts "Most recent version on Annuaire.Sante.fr : v#{version}."

  return version if Version.first.number == version

  puts "Fetching DBv#{version}..."

  zipfile = open('/tmp/zip', 'w')
  zipfile << open(url).read
  puts "DBv#{version} fetched !"

  Zip::Archive.open('/tmp/zip') do |archive|
    puts "Unzipping..."
    archive.map do |entry|
      content = entry.read.tr("\"", "").force_encoding("utf-8").split("\n").map { |e| e.split(";") }
      puts "Unzipped !"
      puts "Column titles extracted !"
      puts "Preparing to work on data."
      raw_data = content[1..-1]
      puts "Selecting pharmacists only..."
      raw_data.select! { |e| e[content[0].index("Libellé profession")] == "Pharmacien" }
      puts "Constructing JSON objects from data..."

      raw_data.each do |p|
        Pharmacist.find_or_initialize_by(rpps_id: p[content[0].index("Identifiant PP")]).
          update_attributes!(
            first_name: p[content[0].index("Prénom d'exercice")],
            last_name: p[content[0].index("Nom d'exercice")],
            email_address: p[content[0].index("Adresse e-mail (coord. structure)")],
            siret: p[content[0].index("Numéro SIRET site")],
            siren: p[content[0].index("Numéro SIREN site")],
            finess: p[content[0].index("Numéro FINESS site")],
            number: p[content[0].index("Numéro Voie (coord. structure)")],
            repeat: p[content[0].index("Indice répétition voie (coord. Structure)")],
            street_type: p[content[0].index("Libellé type de voie (coord. structure)")],
            street_name: p[content[0].index("Libellé Voie (coord. structure)")],
            distribution: p[content[0].index("Mention distribution (coord. structure)")],
            cedex: p[content[0].index("Bureau cedex (coord. structure)")],
            zipcode: p[content[0].index("Code postal (coord. structure)")],
            city_name: p[content[0].index("Libellé commune (coord. structure)")],
            country_name: p[content[0].index("Libellé pays (coord. structure)")],
            phone_number: p[content[0].index("Téléphone (coord. structure)")]
          )
      end
      Version.first.update!(number: version)
    end
  end
end

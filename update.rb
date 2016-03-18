require 'fileutils'
require 'open-uri'
require 'json'
require 'zipruby'
require 'nokogiri'


def refresh_ids(current)

  puts "Currently using : DBv#{current[:version]}."

  url =  Nokogiri::HTML.parse(open("https://annuaire.sante.fr/web/site-pro/extractions-publiques")).css(".col_4a a")[0]["href"]
  version = url.split(".zip")[0].split("_")[-1]
  puts "Most recent version on Annuaire.Sante.fr : v#{version}."

  return current if current[:version] == version
  puts "Fetching DBv#{version}..."

  zipfile = open('/tmp/zip', 'w')
  zipfile << open(url).read
  puts "DBv#{version} fetched !"

  Zip::Archive.open('/tmp/zip') do |archive|
    puts "Unzipping..."
    archive.map do |entry|
      content = entry.read
      puts "Unzipped !"
      titles = content.split("\n")[0].split(";").map { |title| title.tr("\"", "").force_encoding("utf-8") }
      puts "Column titles extracted !"
      puts "Preparing to work on data."
      raw_data = content.split("\n")[1..-1].map { |e| e.split(";").map { |e| e.tr("\"", "").force_encoding("utf-8") } }
      puts "Selecting pharmacists only..."
      pharmacians = raw_data.select { |e| e[titles.index("Libellé profession")] == "Pharmacien" }
      puts "Constructing JSON objects from data..."

      api_data = {
        version: version,
        data: pharmacians.map do |p|
          {
            rpps_id: p[titles.index("Identifiant PP")],
            first_name: p[titles.index("Prénom d'exercice")],
            last_name: p[titles.index("Nom d'exercice")],
            email_address: p[titles.index("Adresse e-mail (coord. structure)")],
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
              phone_number: p[titles.index("Téléphone (coord. structure)")]
           }
          }
        end
      }
      return api_data
    end
  end
end

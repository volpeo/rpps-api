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
    content = ""
    archive.map do |entry|
      content = entry.read.tr("\"", "").force_encoding("utf-8").split("\n")
    end
    GC.start
    puts "Unzipped !"
    puts "Column titles extracted !"
    titles = content[0].split(";")
    puts "Preparing to work on data."
    raw_data = content[1..-1]
    GC.start
    puts "Selecting pharmacists only..."
    raw_data.select! { |e| e.split(";", -1)[titles.index("Libellé profession")] == "Pharmacien" }
    puts "Constructing JSON objects from data..."

    raw_data.each_with_index do |p, index|
      p = p.split(";", -1)
      Pharmacist.find_or_initialize_by(rpps_id: p[titles.index("Identifiant PP")]).
        update_attributes!(
          first_name: p[titles.index("Prénom d'exercice")],
          last_name: p[titles.index("Nom d'exercice")],
          email_address: p[titles.index("Adresse e-mail (coord. structure)")],
          siret: p[titles.index("Numéro SIRET site")],
          siren: p[titles.index("Numéro SIREN site")],
          finess: p[titles.index("Numéro FINESS site")],
          finess_judicial: p[titles.index("Numéro FINESS établissement juridique")]
        )
      print "\r#{(100*index/content.length).round}%" if (100*index/content.length).round == (100*index/content.length)
    end
    Version.first.update!(number: version)
  end
end

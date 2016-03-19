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
      content = entry.read.tr("\"", "").force_encoding("utf-8").split("\n").map { |e| e.split(";") }[1..-1]
      puts "Unzipped !"
      puts "Preparing to work on data."
      raw_data = content[1..-1]
      puts "Selecting pharmacists only..."
      raw_data.select! { |e| e[8] == "Pharmacien" }
      to_save = [1,5,6,15,16,17,18,39] # Def not future proof but I was forced by Heroku.
      raw_data = raw_data.delete_if.with_index { |_, index| !to_save.include?(index) }
      puts "Constructing JSON objects from data..."

      raw_data.each do |p|
        Pharmacist.find_or_initialize_by(rpps_id: p[0]).
          update_attributes!(
            last_name: p[1],
            first_name: p[2],
            siret: p[3],
            siren: p[4],
            finess: p[5],
            finess_judicial: p[6]
            email_address: p[7],
          )
      end
      Version.first.update!(number: version)
    end
  end
end

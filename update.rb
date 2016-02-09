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
      return {
          version: version,
          ids: entry.read
                    .split("\n")
                    .select { |e| e.split(";")[8].tr("\";", "") == "Pharmacien"}
                    .map { |e| e.split(";")[1].tr("\",", "").to_i }
         }
    end
  end


end

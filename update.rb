require 'fileutils'
require 'open-uri'
require 'json'
require 'zipruby'
require 'nokogiri'


def refresh_ids(current)

  puts current[:version]

  url =  Nokogiri::HTML.parse(open("https://annuaire.sante.fr/web/site-pro/extractions-publiques")).css(".col_4a a")[0]["href"]
  version = url.split(".zip")[0].split("_")[-1]

  return current if current[:version] == version

  csv_file = []
  Zip::Archive.open_buffer(open(url).read) do |archive|
    archive.map do |entry|
      csv_file << entry.read
    end
  end

  identifiants = csv_file[0].tr(";",",")
                        .split("\n")
                        .map {|e|
                          [e.split(",")[8].tr("\",", ""), e.split(",")[1]]
                          }
                        .select { |e| e[0] == :Pharmacien}
                        .map { |e| e[1].tr("\",", "").to_i }
  return {
          version: version,
          ids: identifiants
         }
end

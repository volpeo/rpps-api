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

  Zip::Archive.open_buffer(open(url).read) do |archive|
    archive.map do |entry|
      return {
          version: version,
          ids: entry.read
                        .split("\n")
                        .select { |e| e[8].split(";")[8].tr("\",", "") == "Pharmacien"}
                        .map { |e| e.split(";")[1].tr("\",", "").to_i }
         }
    end
  end


end

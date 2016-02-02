require 'fileutils'
require 'open-uri'
require 'json'
require 'zipruby'

URL = "https://annuaire.sante.fr/web/site-pro/extractions-publiques;jsessionid=696D7C19063EA11C1C7FAB3FFFC050A1?p_p_id=abonnementportlet_WAR_Inscriptionportlet_INSTANCE_3ok508MqmVaG&p_p_lifecycle=2&p_p_state=normal&p_p_mode=view&p_p_cacheability=cacheLevelPage&p_p_col_id=column-1&p_p_col_pos=2&p_p_col_count=3&_abonnementportlet_WAR_Inscriptionportlet_INSTANCE_3ok508MqmVaG_nomFichier=ExtractionMonoTable_CAT18_ToutePopulation_201602020849.zip"

def refresh_ids


  csv_file = []
  puts "Fetching file from national database."
  Zip::Archive.open_buffer(open(URL).read) do |archive|
    puts "Unzipping file..."
    archive.map do |entry|
      csv_file << entry.read
    end
  end

  # puts "Formatting text before parsing..."

  puts "Parsing resulting CSV..."
  identifiants = csv_file[0].tr(";",",")
                        .split("\n")
                        .map {|e|
                          [e.split(",")[8].tr("\",", ""), e.split(",")[1]]
                          }
                        .select { |e| e[0]=="Pharmacien"}
                        .map { |e| e[1].tr("\",", "").to_i }

  puts "#{identifiants.length} pharmacists loaded."
  puts "Returning data as Hash."
  return {
          last_updated: Date.today,
          ids: identifiants
         }
end

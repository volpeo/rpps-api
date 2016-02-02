require 'fileutils'
require 'open-uri'
require 'json'
require 'excelsior' # DONT CHANGE TO CSV - Perf related
require 'zipruby'

URL = "https://annuaire.sante.fr/web/site-pro/extractions-publiques;jsessionid=696D7C19063EA11C1C7FAB3FFFC050A1?p_p_id=abonnementportlet_WAR_Inscriptionportlet_INSTANCE_3ok508MqmVaG&p_p_lifecycle=2&p_p_state=normal&p_p_mode=view&p_p_cacheability=cacheLevelPage&p_p_col_id=column-1&p_p_col_pos=2&p_p_col_count=3&_abonnementportlet_WAR_Inscriptionportlet_INSTANCE_3ok508MqmVaG_nomFichier=ExtractionMonoTable_CAT18_ToutePopulation_201602020849.zip"

def refresh_ids


  csv_file = []
  Zip::Archive.open_buffer(open(URL).read) do |archive|
    archive.each do |entry|
      puts "Hey"
      csv_file << entry.read
    end
  end

  # puts "Formatting text before parsing..."
  puts "Parsing resulting CSV..."
  csv_list = []

  Excelsior::Reader.rows(csv_file[0]) { |row| csv_list << row }
  puts "Parsed !"

  identifiants = []

  puts "Selecting Pharmacists..."
  count = 0
  csv_list.each do |entry|
    if entry[8] == "\"Pharmacien\""
      identifiants << entry[1].tr(",\"", "").to_i
      count += 1
      puts "#{count} pharmacists selected." if count%100 == 0
    end
  end

  {
    last_updated: Date.today,
    ids: identifiants
  }
end

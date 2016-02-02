require 'fileutils'
require 'open-uri'
require 'json'
require 'ccsv' # DONT CHANGE TO CSV - Perf related
require 'zip'

URL = "https://annuaire.sante.fr/web/site-pro/extractions-publiques;jsessionid=696D7C19063EA11C1C7FAB3FFFC050A1?p_p_id=abonnementportlet_WAR_Inscriptionportlet_INSTANCE_3ok508MqmVaG&p_p_lifecycle=2&p_p_state=normal&p_p_mode=view&p_p_cacheability=cacheLevelPage&p_p_col_id=column-1&p_p_col_pos=2&p_p_col_count=3&_abonnementportlet_WAR_Inscriptionportlet_INSTANCE_3ok508MqmVaG_nomFichier=ExtractionMonoTable_CAT18_ToutePopulation_201602020849.zip"

def refresh_ids
  puts "Getting file..."
  file = open(URL)

  open("ids.zip", 'w') << file.read
  puts "File saved."

  # Zip.on_exists_proc = true
  Zip::File.open('ids.zip') do |zip_file|
    puts "Unzipping..."
    zip_file.each do |entry|
      puts "Extracting #{entry.name}"
      entry.extract("ids.csv") {true}
    end
    puts "Unzipping done!"
  end

  # puts "Formatting text before parsing..."
  puts "Parsing resulting CSV..."
  csv_list = []
  Ccsv.foreach("ids.csv", ";") { |row| csv_list << row }
  puts "Parsed !"

  identifiants = File.open("identifiants", "w")

  puts "Selecting Pharmacists..."
  count = 0
  csv_list.each do |entry|
    if entry[8] == "\"Pharmacien\""
      identifiants << entry[1].tr(",\"", "")+"\n"
      count += 1
      puts "#{count} pharmacists selected." if count%100 == 0
    end
  end

  {
    last_updated: Date.today,
    ids: open("identifiants", "r").read.split()
  }
end

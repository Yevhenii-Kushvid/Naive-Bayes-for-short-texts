require File.dirname(__FILE__) + "/lib/Parser.rb"
require File.dirname(__FILE__) + "/lib/Helper.rb"
require File.dirname(__FILE__) + "/lib/Classifier.rb"

file_name = "data/SMSSpamCollection.txt"
file_name = "data/input1.csv"

parser      = Parser.new
helper      = Helper.new
classifier  = Classifier.new

#records = parser.read_csv(file_name, 1, "\t", 0)
records = parser.read_csv(file_name, 0, "," , 1)

# total words
ham = records.select{|hash|  hash[:class] == "false"}.count
spam = records.select{|hash| hash[:class] == "true" }.count

puts records.count
puts ham.to_f / (records.count) * 100

# normalizing and cleaning of records
records = helper.normalize(records, "true", "false")
records = helper.clear(records)

spam = records.select{|hash| hash[:class] == "true" }.count
ham  = records.select{|hash| hash[:class] == "false"}.count

puts records.count
puts ham.to_f / records.count * 100

# Load stop words
stop_words_file_name = "data/stop-words-english.txt"
stop_words = parser.read_stop_words_from(stop_words_file_name)
stop_words = helper.clear(stop_words)

# split records to words and clear them from stop words 
records = helper.clear_stop_words(records, stop_words)

# delete all nonuniq records
records.uniq!

spam = records.select{|hash| hash[:class] == "true" }.count
ham  = records.select{|hash| hash[:class] == "false"}.count

puts records.count
puts ham.to_f / records.count * 100

training, validation, test = helper.create_sets_of_records(records, 0.7, 0.2, 0.1)

puts classifier
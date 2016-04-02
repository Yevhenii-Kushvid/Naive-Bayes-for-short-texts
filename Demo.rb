require File.dirname(__FILE__) + "/lib/Parser.rb"
require File.dirname(__FILE__) + "/lib/Helper.rb"
require File.dirname(__FILE__) + "/lib/Classifier.rb"

stop_words_file_name = "data/stop-words-english.txt"

file_name = "data/SMSSpamCollection.txt"
classes   = ["spam", "ham"]
separator = "\t"
text_col  = 1
class_col = 0

=begin
file_name = "data/input1.csv"
file_name = "data/input2.csv"
classes   = ["true", "false"]
separator = ","
text_col  = 0
class_col = 1
=end

parser      = Parser.new
helper      = Helper.new
classifier  = Classifier.new

records = parser.read_csv(file_name, text_col, separator, class_col)
puts "\nLoaded from file\n\n"

# total words
spam = records.select{|hash| hash[:class] == classes[0] }.count
ham  = records.select{|hash| hash[:class] == classes[1] }.count

puts records.count
puts ham.to_f / (records.count) * 100

# normalizing and cleaning of records
records = helper.normalize(records, *classes)
puts "\nNormalized\n"

records = helper.clear(records)
puts "\nCleaned\n\n"

spam = records.select{|hash| hash[:class] == classes[0] }.count
ham  = records.select{|hash| hash[:class] == classes[1] }.count

puts records.count
puts ham.to_f / records.count * 100

# Load stop words
stop_words = parser.read_stop_words_from(stop_words_file_name)
stop_words = helper.clear(stop_words)
puts "\nLoaded stop words\n"

# split records to words and clear them from stop words
records = helper.clear_stop_words(records, stop_words)
puts "\nCleaned from stop words\n"

# delete all nonuniq records
records.uniq!
puts "\nDeleted duplicates\n\n"

spam = records.select{|hash| hash[:class] == classes[0] }.count
ham  = records.select{|hash| hash[:class] == classes[1] }.count

puts records.count
puts ham.to_f / records.count * 100

training_set, validation_set, test_set = helper.create_sets_of_records(records, 0.7, 0.2, 0.1)
puts "\nCreated sets for classifier study\n\n"

class_list = []
records.each{|hash| class_list << hash[:class] }
class_list.uniq!

classifier.obtain_valid_classes(class_list)
classifier.study_by training_set


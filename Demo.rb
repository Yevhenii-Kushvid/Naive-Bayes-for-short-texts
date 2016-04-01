require File.dirname(__FILE__) + "/lib/Parser.rb"
require File.dirname(__FILE__) + "/lib/Helper.rb"

file_name = "data/SMSSpamCollection.txt"

parser = Parser.new
records = parser.read_csv(file_name, 1, "\t", 0)

helper = Helper.new

print records.join("\n")

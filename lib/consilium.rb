require File.dirname(__FILE__) + "/parser.rb"
require File.dirname(__FILE__) + "/helper.rb"
require File.dirname(__FILE__) + "/classifier.rb"

class Consilium
  @parser
  @helper

  @classifiers

  @stop_words

  @records

  @classes

  @best_cleaning_options

  def initialize(count_of_classifiers: 3)
    @parser = Parser.new
    @helper = Helper.new

    # initialize classifiers
    @classifiers = []
    count_of_classifiers.times do |i|
      @classifiers << Classifier.new
    end

    @best_cleaning_options = {
        first_last_spaces: true,
        downcase: true,
        link: true,
        domain: true,
        numbers: true,
        noncharacter: true,
        symbols: true,
        spaces: true,
        english: true,
        russian: true
    }
  end

  def load_stop_words(file_name)
    @stop_words = @parser.read_stop_words_from(file_name)
    @stop_words = @helper.clear(@stop_words)
    @stop_words.each { |stop_word|
      stop_word = (@helper.split_record(stop_word) - [""])
    }
    @stop_words = @stop_words.compact
  end

  def load_classes(classes)
    @classes = classes
  end

  def load_data(file_name, text_col, separator, class_col)
    @records = @parser.read_csv(file_name, text_col, separator, class_col)

    # prepare data classes
    @records = @helper.normalize(@records, *@classes)

    # clear different symbols from input records
    @records = @helper.clear @records
    @records = @helper.clear_stop_words(@records, @stop_words)

    # load classes from input records
    class_list = []
    @records.each { |hash| class_list << hash[:class] }
    class_list.uniq!

    @classifiers.count.times do |i|
      @classifiers[i].obtain_valid_classes(class_list)
    end

    @records
  end

  # only 10 records for test
  def autocleaner(records, options = {
      first_last_spaces: true,
      downcase: true,
      link: true,
      domain: true,
      numbers: true,
      noncharacter: true,
      symbols: true,
      spaces: true,
      english: true,
      russian: true
  })
    if options
      # delete first and last spaces
      if :first_last_spaces
        text.strip!
        print :first_last_spaces
      end

      # downcase
      if :downcase
        text.downcase!
        print :downcase
      end

      # link
      if :link
        text.gsub!(/(https|http):\/\/\S+\/(\w)?(.\S+)?/, " link ")
        print :link
      end

      # domain
      if :domain
        text.gsub!(/(https|http):\/\/\S+\/(\w)?(.\S+)?/, " link ")
      end

      # numbers
      if :numbers
        text.gsub!(/[0-9]+/, " 0 ")
      end

      # noncharacter symbols
      if :noncharacter
        text.split(/[\W]+/)
      end

      # symbols
      if :symbols
        text.gsub!(/[.,-?!;:*+=@"'\t]+/, " ")
        text.gsub!(/[^A-Za-zА-Яа-я0-9\- \r\n\']+/, " ")
      end

      # nonenglish
      if :english
        text.gsub!(/[^A-Za-z]+/, " ")
      end

      # nonrussian
      if :russian
        text.gsub!(/[^А-Яа-я]+/, " ")
      end

      # spaces
      if :spaces
        text.gsub!(/[ ]+/, " ")
      end
    else
      # experiments


    end

    # vector of best cleaning choosing
  end



  def study_self
    result = 1
    @classifiers.count.times do |i|
      # make in smaller
      result = []
      spam_records = @records.select { |hash| hash[:class] == @classes[0] }
      ham_records = @records.select { |hash| hash[:class] == @classes[1] }

      puts spam_records.count
      puts ham_records.count

      2_000.times do
        index = Random.rand(spam_records.count)
        result << spam_records.slice!(index)
      end
      8_000.times do
        index = Random.rand(ham_records.count)
        result << ham_records.slice!(index)
      end
      records = result


      # generate sets for classifier stydy
      training_set, validation_set, test_set = @helper.create_sets_of_records(records, 0.8, 0.1, 0.1)

      @classifiers[i].study_by training_set
      # @classifiers[i].crossvalidation_by validation_set

      result *= @classifiers[i].test_by test_set

      @classifiers[i].save_to "#{@classifiers[i]}-#{i}"
    end
    result
  end

  def study_by(records)

    result = 1
    @classifiers.count.times do |i|
      # generate sets for classifier stydy
      training_set, validation_set, test_set = @helper.create_sets_of_records(records, 0.7, 0.2, 0.1)

      @classifiers[i].study_by training_set
      @classifiers[i].crossvalidation_by validation_set

      result *= @classifiers[i].test_by test_set

      @classifiers[i].save_to "#{@classifiers[i]}-#{i}"
    end
    result

  end

  def test_by(records)
    fails = 0
    records.each do |record|
      class_of_record = take_desicion_about_record(record[:text])
      unless record[:class] == class_of_record
        fails += 1
      end
    end
    # 100 - fails.to_f / records.count * 100
    fails.to_f / records.count
  end

  def test_self
    fails = 0
    @records.each do |record|
      class_of_record = take_desicion_about_record(record[:text])
      unless record[:class] == class_of_record
        fails += 1
      end
    end
    # 100 - fails.to_f / records.count * 100
    fails.to_f / @records.count
  end

  def crossvalidate_by(records)
    @classifiers.count.times do |i|
      @classifiers[i].crossvalidation_by records
    end
  end

  def take_desicion_about(input)

    if input.kind_of?(Array)
      answer_list = []
      input.each { |record|
        answer_list << take_desicion_about_record(record[])
      }
      answer_list
    else
      if input.kind_of?(Hash)
        answer_list = []
        input.each { |record|
          answer_list << take_desicion_about_record(record[:text])
        }
        answer_list
      else
        take_desicion_about_record(input)
      end
    end

  end

  def take_desicion_about_record(text)
    answers = []
    @classifiers.count.times do |i|
      answers << @classifiers[i].classify(text)
    end

    final_answer_hash = {}
    answers.each { |answer|
      if final_answer_hash[answer]
        final_answer_hash[answer] += 1
      else
        final_answer_hash[answer] = 1
      end
    }

    puts "==============================="
    p text
    puts final_answer_hash

    final_answer = "IDK"
    v_max = 0
    final_answer_hash.each { |k, v|
      if v > v_max
        final_answer = k
        v_max = v
      end
    }

    final_answer
  end

end
stop_words_file_name = "../data/stop-words-english.txt"

=begin
file_name = "../data/SMSSpamCollection.txt"
classes = ["spam", "ham"]
separator = "\t"
text_col = 1
class_col = 0
=end

file_name = "../data/input2.csv"
# file_name = "data/input1.csv"
classes = ["true", "false"]
separator = ","
text_col = 0
class_col = 1

consilium = Consilium.new(count_of_classifiers: 1)

puts "\n Consilium created."

classes = consilium.load_classes(classes)
stop_words = consilium.load_stop_words(stop_words_file_name)
input = consilium.load_data(file_name, text_col, separator, class_col)

puts "\n All data is loaded.\n\n"

puts consilium.study_self

puts "\n Get knowledge about input data."

# make in smaller
result = []
spam_records = input.select { |hash| hash[:class] == classes[0] }
ham_records = input.select { |hash| hash[:class] == classes[1] }

# records_for_cleaner_study = []
# 1_000.times do
#   index = Random.rand(input.count)
#   records_for_cleaner_study << input.slice!(index)
# end
# consilium.autocleaner(records_for_cleaner_study)
#
# puts "===================================================="

2_000.times do
  index = Random.rand(spam_records.count)
  result << spam_records.slice!(index)
end
8_000.times do
  index = Random.rand(ham_records.count)
  result << ham_records.slice!(index)
end
records = result

puts consilium.test_by records

puts "\n Get real test accuracy"

parser = Parser.new
helper = Helper.new
print "\n  Hello, please write down the message you want to classify.\n  Enter 'exit' to leave me.\n\n"
while true
  print "\n #: "
  message = gets.chomp

  break if message == "exit"

  message = helper.clear([message])
  message = helper.clear_stop_words(message, stop_words)

  message = message.first

  p message

  class_name = consilium.take_desicion_about_record message

  print " class: #{class_name}"
end

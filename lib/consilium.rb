require File.dirname(__FILE__) + "/parser.rb"
require File.dirname(__FILE__) + "/helper.rb"
require File.dirname(__FILE__) + "/classifier.rb"

class Consilium
  @parser
  @helper

  @classifiers

  @stop_words1

  @records

  @classes

  def initialize(count_of_classifiers: 3)
    @parser      = Parser.new
    @helper      = Helper.new

    # initialize classifiers
    @classifiers = []
    count_of_classifiers.times do |i|
      @classifiers << Classifier.new
    end
  end

  def load_stop_words(file_name)
    @stop_words = @parser.read_stop_words_from(file_name)
    @stop_words = @helper.clear(@stop_words)
    @stop_words.each{|stop_word|
      stop_word = (@helper.split_record(stop_word) - [""])
    }
    @stop_words = @stop_words.compact
  end

  def load_classes(classes)
    @classes = classes.deep_dup
  end

  def load_data(file_name, text_col, separator, class_col)
    @records = @parser.read_csv(file_name, text_col, separator, class_col)

    # prepare data classes
    @records = @helper.normalize(@records, *@classes)

    # clear different symbols from input records
    @records = @helper.clear_stop_words(@records, @stop_words)

    # load classes from input records
    class_list = []
    records.each{|hash| class_list << hash[:class] }
    class_list.uniq!

    @classifiers.count.times do |i|
      @classifiers[i].obtain_valid_classes(class_list)
    end
  end

  def study_by(records)

    result = 1
    @classifiers.count.times do |i|
      # generate sets for classifier stydy
      training_set, validation_set, test_set = @helper.create_sets_of_records(@records, 0.7, 0.2, 0.1)

      @classifiers[i].study_by training_set
      @classifiers[i].crossvalidation_by validation_set

      result *= @classifiers[i].test_by  test_set

      @classifiers[i].save_to "#{@classifiers[i]}-#{i}"
    end
    result

  end

  def test_by(records)
    result = 1
    @classifiers.count.times do |i|
      result *= @classifiers[i].test_by records
    end
    result
  end

  def crossvalidate_by(records)
    @classifiers.count.times do |i|
      @classifiers[i].crossvalidation_by records
    end
  end

  def take_desicion_about(input)

    if input.kind_of?(Array)
      answer_list = []
      input.each {|record|
        answer_list << take_desicion_about_record(input)
      }
      answer_list
    else
      take_desicion_about_record(input)
    end
  end

  def take_desicion_about_record(text)
    answers = []
    @classifiers.count.times do |i|
      answers << @classifiers[i].classify(text)
    end

    final_answer_hash = {}
    answers.each{ |answer|
      if final_answer_hash[answer]
        final_answer_hash[answer] += 1
      else
        final_answer_hash[answer]  = 1
      end
    }

    final_answer = "IDK"
    v_max       = 0
    final_answer_hash.each { |k, v|
      if v > v_max
        final_answer = k
        v_max        = v
      end
    }

    final_answer
  end

end
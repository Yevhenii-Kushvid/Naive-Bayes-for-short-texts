class Classifier
  # initialize memory by memory file
  def initialize(memory = nil)
    unless memory
      @total_words  = {}  # { "word"      : word_count, ... }
      @class_list  = []  # { "class_name": uniq_id, ... }
      @class_list_words  = {}  # { "class_id"  : {"word": word_count}, ...}
      @laplas_factor       = 10
    else
      puts "#initialize by memory"
    end
  end

  # creating and load memory file of classifier
  def self.load
    self.load_from("nb.memory")
  end

  def self.load_from(file_name)

  end

  def save
    save_to "nb.memory"
  end

  def save_to(file_name)

  end
  
  # load classes
  def obtain_valid_classes(list)
    list.each{ |class_name|
      @class_list_words[class_name] = {}
    }  
    @class_list = list.clone
  end

  # study by
  def study_by(input)   
    # if input is words array
    if input.kind_of?(Array)
      input.each { |record|
        if @class_list.include? record[:class]
          words_hash = count_words(record[:text])
          
          merge(words_hash, record[:class])
          merge(words_hash)
        
        end
      }
    end
    # if input is text messages
  end

  # classification
  def classify(input)
  
    # declare hash counter for each class
    @class_votes = {}
    @class_list.each{|class_name|
      class_list_votes[class_name] = 0.0    
    }
  
    if input.kind_of?(Array)
      # if input is words vector
      @class_list.each{|class_name|
        total_class_words_count = @class_list_words[class_name].count.to_f  
        total_words_count       = @total_words.count == 0 ? 1 : @total_words.count
          
        class_voices = total_class_words_count / total_words_count
        class_voices = 1 if class_voices == 0

        class_list_votes[class_name] = Math.log(class_voices)

        input.each{|word|
          if (@class_list_words[word])
            word_class_count = (@class_votes[class_name][word] ? @class_votes[class_name][word] : 0 ).to_f
            class_list_votes[class_name] += Math.log( (word_class_count + @laplas_factor) / ( words_class_count + @laplas_factor * @total_words.count ) )
          else
            @class_list.each{|non_class_name|
              if class_name != non_class_name
                word_non_class_count = (@class_votes[non_class_name].count == 0 ? @class_votes[non_class_name].count : 0 ).to_f
                class_list_votes[non_class_name] += Math.log( @laplas_factor / ( word_non_class_count + @laplas_factor * @total_words.count ) )
              end
            }
          end
        }
      }
      # choose best match
      result_class_name = 0
      @class_list.each{ |class_name|
        if class_list_votes[result_class_name] < class_list_votes[class_name]
          result_class_name == class_name 
        end
      }
      result_class_name            
    else
      # if input is text messages
      "IDK"      
    end
  end

  # testing of classifier
  def test_by(records)

  end

  # choosing of the best laplas factor in intervar with step
  def crossvalidation_by(records)
    crossvalidation_by(records, 1..10)
  end

  def crossvalidation_by(records, interval)
    crossvalidation_by(records, interval, 0.1)
  end

  def crossvalidation_by(records, interval, step)

  end
  
  private
  
  # count words in input record words list
  def count_words(words_list)
    words_hash = {}

    words_list.count.times {|i|
      if words_hash[words_list[i]]
      words_hash[words_list[i]] += 1
      else
      words_hash[words_list[i]] = 1
      end
    }
    
    words_hash
  end
  
  # merge words hash into class hash
  def merge(input, class_name = nil)
    
    unless class_name
      input.each{ |key, value|
        if @total_words[key]
          @total_words[key] += value
        else
          @total_words[key]  = value
        end  
      }
    else
      input.each{ |key, value|
        if @class_list_words[class_name][key]
          @class_list_words[class_name][key] += value
        else
          @class_list_words[class_name][key]  = value
        end  
      }
    end
    
  end
  
end
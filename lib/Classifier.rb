class Classifier
  def initialize
    @ham_words    = {}
    @spam_words   = {}
    @total_words  = {}
    @class_names  = {} # { "class_name": uniq_id }
    @laplas       = 0
  end
  
  # initialize memory by memory file
  def initialize(memory_file)
    
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

  # study by
  def study_by(input)
    # if input is words vector

    # if input is text messages
  end

  # classification
  def classify(input)
    # if input is words vector

    # if input is text messages
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
end
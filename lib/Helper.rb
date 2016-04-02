# Text processing
class Helper
  def clear(records)
    records.each { |record|
      if record.kind_of?(Hash)
        # clear record[:text] (text position in record hash)
        record = clear_text(record[:text])
      else
      # clear text
        clear_text record
      end
    }
  end

  def clear_text(text)
    text.downcase!

    # from linkshash
    text.gsub!(/(https|http):\/\/\S+\/(\w)?(.\S+)?/, " link ")

    # from emails
    #text.gsub!(/\A([\w+\-]\.?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i, " email ")

    # from numbers
    text.gsub!(/[0-9]+/, " 0 ")

    # from symbols
    text.gsub!(/[\r\n"'()\[\]@\/&#]+/, "")

  end

  def split_record(text)
    text.split(/[, \.?!%>\/*;&:#\n]+/)
    #text.split(/[\W]+/)
  end

  # split record into words
  # clear words array from stop words
  def clear_stop_words(records, stop_words)

    records.each{ |record|
      if record.kind_of?(Hash)
        record[:text]  = split_record(record[:text])
        record[:text] -= stop_words
      else
        record         = split_record(record)
      record        -= stop_words
      end

    }

    records
  end

  def normalize(records, *valid_classes)
    # if not all records have classes

    # if classes are symbolic

    # if classes are not in range
    if valid_classes
      # clear records with nonvalid classes
      records = records.delete_if{ |hash|
        !valid_classes.include? hash[:class]
      }
    end

    # if have duplicates in records[:text]
    records
  end

  # create sets of records for classifier study
  def create_sets_of_records(records)
    create_sets_of_records(records, 0.7, 0.1)
  end

  def create_sets_of_records(records, training)
    create_sets_of_records(records, training, (1 - training))
  end

  def create_sets_of_records(records, training, test)
    create_sets_of_records(records, training, (1 - training - test), test)
  end

  def create_sets_of_records(records, training, validation, test)
    records_dup = records.clone

    training_set = []
    (records_dup.count * training).floor.times do
      index = Random.rand(records_dup.count)
      training_set << records_dup.slice!(index)
    end

    validation_set = []
    (records_dup.count * validation).floor.times do
      index = Random.rand(records_dup.count)
      validation_set << records_dup.slice!(index)
    end

    test_set = []
    (records_dup.count * test).floor.times do
      index = Random.rand(records_dup.count)
      test_set << records_dup.slice!(index)
    end

    [training_set, validation_set, test_set]
  end
end
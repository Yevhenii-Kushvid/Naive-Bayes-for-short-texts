# Text processing 
class Helper
  def clear(records)
    records.each { |record|
      if recored.kind_of?(Array)
        # clear record[1] (text position in record array)
        
      else
        # clear text
        
      end
    }
  end

  def clear_text(text)
    # if text.kind_of?(Array)
    
    # from numbers
    
    # from symbols
    
    # from links
    
    # from emails
    
    # from stop words 
    
  end

  def normalize_data
    # if classes are symbolic
    
    # if not all records have classes
    
  end

  # create sets of records for classifier study
  def create_sets_of_records(records)
    create_sets_of_records(records, 0.7, 0.1)
  end
  
  def create_sets_of_records(records, training, test)
    create_sets_of_records(records, training, (1 - training - test), test)
  end
  
  def create_sets_of_records(records, training, validation, test)
    
  end
end
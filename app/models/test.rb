class Test < ApplicationRecord
  self.table_name = "tests"
  
  belongs_to :test_type, class_name: 'TestType', foreign_key: "test_type_id"
  belongs_to :visit, class_name: 'Visit', foreign_key: "visit_id"
  belongs_to :specimen, class_name: 'Specimen', foreign_key: "specimen_id"

  def name
    self.test_type.name rescue nil
  end
  def short_name
    self.test_type.short_name rescue nil
  end
end

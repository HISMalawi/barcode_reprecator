require 'auto12epl'
module BarcodeGeneratorService
  def self.generate_specimen_label(accession_number, acc_number)
    settings = YAML.load_file("#{Rails.root}/config/application.yml")
    if settings['query']
      specimen = Specimen.find_by(accession_number: accession_number)
      puts specimen
      if specimen.nil?
        return nil
      end
      tests = specimen.tests
      patient = tests.first.visit.patient
      npid = patient.external_patient_number
      npid = "-" if npid.blank?
      name = patient.name
      date = tests.first.time_created.strftime("%d-%b-%Y %H:%M")

      test_names = []
      panels = []
      tests.each do |t|
        next if !t.panel_id.blank?  and panels.include?(t.panel_id)
        if t.panel_id.blank?
          test_names << t.short_name || t.name
        else
          test_names << TestPanel.find(t.panel_id).panel_type.short_name || TestPanel.find(t.panel_id).panel_type.name
        end

      end

      tname = test_names.uniq.join(', ')
      first_name = name.strip.scan(/^\w+/).first.strip rescue ""
      last_name = name.strip.scan(/\w+$/).last.strip rescue ""
      middle_initial = name.strip.scan(/\s\w+\s/).first.strip[0 .. 2] rescue ""
      dob = patient.dob.to_date.strftime("%d-%b-%Y")
      age = patient.age
      gender = patient.gender == 0 ? "M" : "F"
      col_datetime = date
      col_by = User.find(tests.first.created_by).username
      formatted_acc_num = format_ac(specimen.accession_number)
      stat_el = specimen.priority.downcase.to_s == "stat" ? "STAT" : nil
      numerical_acc_num = numerical_ac(specimen.accession_number)
      auto = Auto12Epl.new
      auto.generate_epl(last_name.to_s, first_name.to_s, middle_initial.to_s, npid.to_s, dob, age.to_s,
                      gender.to_s, col_datetime, col_by.to_s, tname.to_s,
                      stat_el, formatted_acc_num.to_s, numerical_acc_num
                    )
    else
      generate_epl(accession_number, acc_number)
    end
  end

  def self.format_ac(num)
    num = num.insert(3, '-')
    num = num.insert(-9, '-')
    num
  end

  def self.numerical_ac(num)
    settings = YAML.load_file("#{Rails.root}/config/application.yml")
    code = settings['facility_code']
    num = num.sub(/^#{code}/, '')
    num
  end


  def self.generate_epl(accession_number, acc_number)
    "\nN\nR216,0\nZT\nS2\nA51,6,0,1,1,1,N,\nA51,29,0,1,1,1,N,\nB51,51,0,1A,2,2,56,N,\"#{acc_number}\"\nA51,111,0,1,1,1,N,\"#{format_ac(accession_number)} * #{acc_number}\"\nA51,130,0,1,1,1,N,\nA51,152,0,1,1,1,N,\nP2"
  end
end
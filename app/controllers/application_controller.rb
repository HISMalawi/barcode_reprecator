class ApplicationController < ActionController::Base
  def print_and_redirect(print_url, redirect_url, message = "Printing, please wait...")
    acc_number = params[:accession_number].include?('$') ? params[:accession_number].delete_suffix('$') : params[:accession_number]
    settings = YAML.load_file("#{Rails.root}/config/application.yml")
    accession_number = settings['facility_code'].to_s + acc_number.to_s
    if settings['query']
      if acc_number.to_s.length < 8
        flash[:alert] = "Accession number must be atleast 8 characters long"
        redirect_to '/'
        return
      end
    else
      specimen = Specimen.find_by(accession_number: accession_number)
      if specimen.nil?
        flash[:alert] = "Order for accession number: #{accession_number} not found"
        redirect_to '/'
        return
      end 
    end
    @print_url = print_url
    @redirect_url = redirect_url
    @message = message
    render :template => 'home/print', :layout => nil
  end
end

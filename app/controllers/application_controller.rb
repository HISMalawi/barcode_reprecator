class ApplicationController < ActionController::Base
  def print_and_redirect(print_url, redirect_url, message = "Printing, please wait...")
    accession_number = params[:accession_number].include?('$') ? params[:accession_number].delete_suffix('$') : params[:accession_number]
    specimen = Specimen.find_by(accession_number: accession_number)
    if specimen.nil?
      flash[:alert] = "Order for accession number: #{accession_number} not found"
      redirect_to '/'
      return
    end
    @print_url = print_url
    @redirect_url = redirect_url
    @message = message
    render :template => 'home/print', :layout => nil
  end
end

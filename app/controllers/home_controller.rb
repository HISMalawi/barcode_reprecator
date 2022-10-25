require 'barcode_generator'

class HomeController < ApplicationController

  def index
    render 'index'
  end

  def print
    print_and_redirect("/print_barcode?accession_number=#{params[:accession_number]}", '/')
  end

  def print_barcode
    accession_number = params[:accession_number].include?('$') ? params[:accession_number].delete_suffix('$') : params[:accession_number]
    unless accession_number.nil?
      specimen_label = BarcodeGeneratorService.generate_specimen_label(accession_number)
      filename = accession_number.to_s + rand(1000).to_s << '.lbl'
      if specimen_label.nil?
        flash[:alert] = "Order for accession number: #{accession_number} not found"
      else
        flash[:notice] = "#{accession_number} printed successfully"
        send_data(
          specimen_label,
          type: 'application/label; charset=utf-8',
          stream: false,
          filename: filename,
          disposition: 'inline'
        )
      end
    end
  end
end

class PagesController < ApplicationController
  def home
    puts "HOME"
    if @@first_execution
      puts "YA SE EJECUTO"
    else
      @@first_execution = true
      handler = Handler.new
      handler.empty_reception
      handler.check_inventory
      handler.final_products_inventory
      handler.ordenes_de_compra_ftp
    end

  end

end

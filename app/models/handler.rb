class Handler < CheckController

  def empty_reception
    puts "------------- Empty Reception job ------------"
    contador = 0
    for i in sku_with_stock(@@recepcion, @@api_key)[0]
      lista_productos = request_product(@@recepcion, i["_id"], @@api_key)[0]
      for j in lista_productos
        if contador <= 12
          move_product_almacen(j["_id"], @@despacho)
          move_product_almacen(j["_id"], @@pulmon)
          contador += 1
        end
      end
    end
    self.empty_reception()
  end
  handle_asynchronously :empty_reception, :run_at => Proc.new {2.minutes.from_now}

  def oc_pendientes
    puts "------------- Ordenes Pendientes job ------------"
    pendientes()
    self.oc_pendientes()
  end
  handle_asynchronously :oc_pendientes, :run_at => Proc.new {16.minutes.from_now}

  def ordenes_de_compra_ftp
    puts "------------- Buscar Ordenes de Compra job ------------"
    execute_ftp
    self.ordenes_de_compra_ftp
  end
  handle_asynchronously :ordenes_de_compra_ftp, :run_at => Proc.new {3.minutes.from_now}

  def satisfy_inventory_level1_groups_job
    puts "------------- Satisfy Inventory Level 1 Groups job ------------"
    satisfy_inventory_level1_groups()
    self.satisfy_inventory_level1_groups_job()
  end
  handle_asynchronously :satisfy_inventory_level1_groups_job, :run_at => Proc.new {4.minutes.from_now}

  def satisfy_inventory_level1_job}
    puts "------------- Satisfy Inventory Level job ------------"
    satisfy_inventory_level1()
    self.satisfy_inventory_level1_job
  end
  handle_asynchronously :satisfy_inventory_level1_job, :run_at => Proc.new {30.minutes.from_now}

  def satisfy_inventory_level2_job
    puts "------------- Satisfy Inventory Level 2 job ------------"
    satisfy_inventory_level2()
    self.satisfy_inventory_level2_job
  end
  handle_asynchronously :satisfy_inventory_level2_job, :run_at => Proc.new {9.minutes.from_now}

  def arrocero
    puts "------------- Arrocero job ------------"
    fabricar_producto(10, 1101, 'despacho')
    self.arrocero
  end
  handle_asynchronously :arrocero, :run_at => Proc.new {6.minutes.from_now}

end

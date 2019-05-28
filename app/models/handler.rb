class Handler < CheckController

  '''Debo poner docker-compose run web rake jobs:work para comenzar los jobs'''
  def empty_reception
    puts "RECEPCION"
    '''Primero los productos importantes'''
    productos_pulmon = sku_with_stock(@@pulmon, @@api_key)[0]
    if productos_pulmon.length > 0
      for producto in productos_pulmon
        if producto["_id"].to_i > 10000
          move_sku_almacen(@@pulmon, @@cocina, producto["_id"])
        end
      end
    end
    '''Productos con stock en rececpcion'''
    productos = sku_with_stock(@@recepcion, @@api_key)[0]
    '''Por cada producto en la recepcion, moverlo a cocina'''
    if productos.length > 0
      for prod in productos
       move_sku_almacen(@@recepcion, @@cocina, prod["_id"])
      end
    '''Se creo una columna llamada incoming en el modelo de productos, cada vez
    que se pide un producto, este producto tiene un tiempo de demora en llegar a
    la recepcion. Una vez que este llega debemos restarlo de la columna incoming
    que se utiliza para calcular el inventario mínimo del producto'''
      actualizar_incoming(productos)
      puts "RECEPCION VACIADA"
    else
      puts "RECEPCION VACIA"
    end
    self.empty_reception
  end
  handle_asynchronously :empty_reception, :run_at => Proc.new {10.minutes.from_now }

  '''La idea es mantener un inventario minimo de materias primas y tambien de productos finales'''

  def check_inventory
    puts "INVENTARIO"
    '''1. Encontramos los productos que debemos mantener en un mínimo'''
    lista_sku1 = skus_monitorear()
    '''2. Encontramos el mínimo para cada producto. Esta funcion nos devuelve una
    lista de lista con cada elemento de la forma [sku, inventario minimo]'''
    lista_sku2 = encontar_minimos(lista_sku1)
    '''3. Para cada uno de los productos debo encontrar su inventario'''
    '''3.1 Encuentro los productos con stock en cocina'''
    productos1 = sku_with_stock(@@cocina, @@api_key)[0]
    '''3.2 Encuentro el inventario incoming de los productos. Puede ser que ya
    hayamos pedido producto y no queremos ser redundantes. Productos2 es una lista
    de listas donde cada elemento tiene el formato [sku, inventario total, inventario minimo].
    Inventario total es inventario incoming + inventario en cocina'''
    @lista_final, @lista_productos = encontrar_incoming(lista_sku2, productos1)
    '''4. Analizar el tema de inventario'''
    inventario_minimo(@lista_productos)
    self.check_inventory
  end
  handle_asynchronously :check_inventory, :run_at => Proc.new {15.minutes.from_now }

  def final_products_inventory(lista_productos)
    @lista_final, @lista_productos = encontrar_incoming(lista_sku2, productos1)
    inventario_productos_finales(@lista_final)
    self.final_products_inventory(lista_productos)
  end
  handle_asynchronously :final_products_inventory, :run_at => Proc.new {20.minutes.from_now }


  '''Esto es en el caso que aceptemos ordenes que dejamos pendientes'''
  def ordenes_de_compra_ftp
    puts "REVISANDO ORDENES"
    ftp = Ftp.new
    ftp.execute
    self.ordenes_de_compra_ftp
  end
  handle_asynchronously :ordenes_de_compra_ftp, :run_at => Proc.new {12.minutes.from_now }

end

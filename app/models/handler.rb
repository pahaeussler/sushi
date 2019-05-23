class Handler < CheckController

  '''Debo poner docker-compose run web rake jobs:work para comenzar los jobs'''
  def empty_reception
    puts "RECEPCION"
    '''Productos con stock en rececpcion'''
    productos = sku_with_stock(@@recepcion, @@api_key)[0]
    puts productos
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
  handle_asynchronously :empty_reception, :run_at => Proc.new {45.minutes.from_now }

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
    self.final_products_inventory(@lista_final)
    self.check_inventory
  end
  handle_asynchronously :check_inventory, :run_at => Proc.new {30.minutes.from_now }

  def final_products_inventory(lista_productos)
    inventario_productos_finales(lista_productos)
    self.final_products_inventory(lista_productos)
  end
  handle_asynchronously :final_products_inventory, :run_at => Proc.new {80.minutes.from_now }


  '''Esto es en el caso que aceptemos ordenes que dejamos pendientes'''
  def despachar_orden
    puts "REVISANDO ORDENES"

    '''1. Revisar sku with stock en cocina'''
    '''2. Revisar sku with stock en pulmos'''
    '''3. Comparar con @@pedidos_pendientes'''
    '''4. Si el pedido está, despacharlo con el metodo de la API'''
  end

end

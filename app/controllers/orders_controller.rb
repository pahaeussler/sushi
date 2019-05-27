
class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  helper_method :order_request, :create_oc
  require 'securerandom'
  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  def evaluar_pedido(cantidad, sku)
    stock = sku_with_stock(@@cocina, @@api_key)[0]
    stock = stock[0]["total"].to_i
    #Encontrar el find by sku
    min = 0
    minimo = MinimumStock.all
    minimo.each do |m|
      if m["sku"] == sku.to_i
        min = m["minimum_stock"]
        break
      end
      end
    cantidad = cantidad.to_i
    if stock - cantidad < min
      return false
    else
      return true
    end
  end

 #Retorna true si el sku es producido por nosotros
  def check_sku(sku)
    listas_sku = []
    productos = Product.all
    productos.each do |product|

    if product["groups"].split(",")[0] == "1"
        listas_sku << product["sku"]
      end
    end



    if  listas_sku.include?(sku.to_i)
      return true
    else
      return false
    end
  end

  def evaluar_orden_ftp(orden)
    '''Aqui hay que hacer el get OC'''
    puts "Evaluando Orden"
    sku = orden["sku"]
    cantidad = orden["cantidad"].to_i
    '''1. Consultar inventario '''
    inventario = get_inventories
    stock = 0
    for producto in inventario
      if producto[:sku] == sku
        stock = producto[:total].to_i
      end
    end
    '''2. Acepto o Rechazo'''
    '''Ojo que acá se puede hacer algo más avanzado como revisar si tengo los ingredientes para fabricar y mandar a fabricar'''
    if stock - cantidad > 0
      return true
    else
      return false
    end
  end

  # POST /orders
  # POST /orders.json
  def create
    @grupo = request.headers["group"]
    @sku = params[:sku]
    @almacenId = params[:almacenId]
    @cantidad = params[:cantidad]
    @id = params[:_id]
    puts "LLEGA ORDEN"
    '''1. Con la Id voy a buscar al FTP'''
    orden = obtener_oc(@id)[0]
    evaluacion = false
    '''2. Evaluar Orden'''
    evaluacion = evaluar_orden_ftp(orden)
    if evaluacion
      '''Notificar aceptacion'''
      recepcionar_oc(orden)
      despachar_productos_sku(orden)
   else
      rechazar_oc(orden)
      '''Notificar rechazo'''
    end



    # if @cantidad.blank? || @grupo.blank? || @sku.blank? || @almacenId.blank?
    #
    #   res = "No se creó el pedido por un error del cliente en la solicitud.
    #         Por ejemplo, falta un parámetro obligatorio"
    #         render json: res, :status => 400
    #
    # elsif !check_sku(@sku)
    #   res = "No tenemos ese sku"
  	# 	render json: res, :status => 404
    # end
    #
    #
    # if evaluar_pedido(@cantidad, @sku)
    #
    #   res = {
    #     "sku": @sku,
    #     "cantidad": @cantidad,
    #     "almacenId": @almacenId,
    #     "grupoProveedor": 1,
    #     "aceptado": true,
    #     "despachado": true
    #   }
    #   render json: res, :status => 201
    #   # primero movemos producto de cosina a despacho
    #   move_q_products_almacen(@@cocina, @@despacho, @sku, @cantidad)
    #   request_system("almacenes", "GET", @@api_key )
    #   # ahora despachamos producto a bodega del grupo
    #   move_q_products_bodega(@@despacho, @almacenId, @sku, @cantidad)
    # else
    #   res = "No es posible la solicitud"
		# 	render json: res, :status => 404
    # end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end


    def order_params
      # params.require(:almacenId, :sku, :cantidad)
      params.permit(:almacenId, :sku, :cantidad)
      # params.fetch(:order, {}).permit(:almacenId, :sku, :cantidad)
    end
    # # Never trust parameters from the scary internet, only allow the white list through.
    # def order_params
    #   params.fetch(:order, {})

    # end


  '''Generar el Id de la orden de compra y retorna la OC completa'''
  def orden_de_compra_id
    id = SecureRandom.hex
    return id
  end

  '''Pedir productos por la casilla ftp a otros grupos'''
  def pedir_productos_ftp(sku, cantidad)
    puts "PIDIENDO PRODUCTO FTP A OTRO GRUPO"

  end

  

  end

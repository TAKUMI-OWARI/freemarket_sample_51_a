class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :toggle_status, :pay, :buy, :destroy, :edit, :update]
  before_action :authenticate_user! , only: [:new, :buy] 
  before_action :set_exhibit , only: [:new, :create, :edit] 
  before_action :product_protect , only: [:edit, :destroy, :update] 
  skip_before_action :authenticate_user! , only: [:index, :show, :search] 

  def index
    @ladies_products = Product.ladies_products
    @mens_products = Product.mens_products
    @babys_and_kids_products = Product.babys_and_kids_products
    @cosmetics_and_perfume_and_beauty_products = Product.cosmetics_and_perfume_and_beauty_products
    @chanel_products = Product.chanel_products
    @louis_vuitton_products = Product.louis_vuitton_products
    @supreme_products = Product.supreme_products
    @nike_products = Product.nike_products
  end

  def destroy
    if @product.destroy
      redirect_to mypage_index_path(current_user.id), notice: '商品を削除しました'
    else
      render @product
    end
  end

  def show
    @random_products = Product.where(status: 0).order("RAND()").limit(2)
    @same_brand_products = Product.where(brand_id: @product.brand_id, status: 0).where.not(id: params[:id]).order("RAND()").limit(6)
    @exhibitor_related_products = Product.where(user_id: @product.user_id, status: 0).where.not(id: params[:id]).order("RAND()").limit(6)
    if user_signed_in?
      @like = Like.find_by(user_id: current_user.id, product_id: @product.id)
    end
  end

  def new
    @product = Product.new
    @product.product_images.build
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to @product, notice: '出品が完了しました'
    else
      render 'new'
    end
  end

  def edit
    @children = @product.category.parent.parent.children
    @grandchildren = @product.category.parent.children
    @image_count = @product.product_images.length
    @product.product_images.build
  end

  def update
    if @product.update(update_params)
      redirect_to @product, notice: '編集が完了しました'
    else
      render 'edit'
    end
  end

  def buy
    @user_card = current_user.card
    if @user_card.present?
      card = Card.where(user_id: current_user.id).first
      Payjp::api_key = ENV['PAYJP_SECRET_KEY']
      customer = Payjp::Customer.retrieve(card.customer_id)
      @default_card_information = customer.cards.retrieve(card.card_id)
      # 登録しているカード会社のブランドアイコンを表示する
      @card_brand = @default_card_information.brand
      case @card_brand
      when "Visa"
        @card_src = "visa.png"
      when "JCB"
        @card_src = "JCB.png"
      when "MasterCard"
        @card_src = "mastercard.png"
      when "American Express"
        @card_src = "americanExpress.jpg"
      when "Diners Club"
        @card_src = "dinersClub.jpg"
      when "Discover"
        @card_src = "discover.png"
      end
    end
    # 出品者が自身の出品商品の購入確認ページに遷移できないようにする
    if user_signed_in? && current_user.id == @product.user_id
      # 直前の画面に戻る
      return_back and return
    end
    # 購入者が購入した商品の購入確認ページに再度遷移できないようにする
    if @product.exhibit_trading? || @product.exhibited?
      # 直前の画面に戻る
      return_back and return
    end
  end

  def pay
    Payjp::api_key = ENV['PAYJP_SECRET_KEY']
    charge = Payjp::Charge.create(
      amount: params[:price],
      card: params['payjp-token'],
      currency: 'jpy'
    )
    product = Product.find(params[:id])
    product.exhibit_trading!
    order = Order.new(product_id: params[:id], buyer_id: current_user.id)
    if order.save
      redirect_to controller: :orders, action: :show, id: order.product_id
    else
      redirect_to action: :buy
    end  
  end

  def search
    @products = Product.all.search(params[:name])
    @exhibit_products = Product.exhibit_products
  end
  
  def category
    respond_to do |format|
      format.html
      format.json do
       @children = Category.find(params[:parent_id]).children
       #親ボックスのidから子ボックスのidの配列を作成してインスタンス変数で定義
      end
    end
  end

  def toggle_status
    @product.toggle_status!
    redirect_to @product
  end

  private

  def product_params
    params.require(:product).permit(:name, :detail, :price, :category_id, :brand_id, :state, :delivery_burden, :delivery_from, :delivery_way, :delivery_time, :size, product_images_attributes: :image ).merge(user_id: current_user.id)
  end

  def update_params
    params.require(:product).permit(:name, :detail, :price, :category_id, :brand_id, :state, :delivery_burden, :delivery_from, :delivery_way, :delivery_time, :size, product_images_attributes: [:image, :id, :_destroy] ).merge(user_id: current_user.id)
  end

  def set_product
    @product = Product.find(params[:id] || params[:product_id])
  end

  def set_exhibit
    @parents = Category.order("id ASC").limit(13)
    @brands = Brand.all
  end
  
  def product_protect
    if user_signed_in? && @product.user_id == current_user.id
    else
      redirect_to root_path, alert: '編集権限がありません'
    end    
  end
end
class MypageController < ApplicationController
  before_action :set_user
  before_action :like_products, only: :like
  before_action :purchase_products, only: [:index, :purchase, :purchased]

  def index
    # 他のユーザーのページに遷移できないようにする
    unless current_user.id == @user.id
      # 直前の画面に戻る
      return_back and return
    end
  end

  def notification
    unless current_user.id == @user.id
      return_back and return
    end
  end
  
  def todo
    unless current_user.id == @user.id
      return_back and return
    end
  end
  
  def like
    unless current_user.id == @user.id
      return_back and return
    end
  end
  
  def exhibit_trading
    unless current_user.id == @user.id
      return_back and return
    end
  end
  
  def exhibiting
    unless current_user.id == @user.id
      return_back and return
    end
  end
  
  def exhibit
    unless current_user.id == @user.id
      return_back and return
    end
  end
  
  def purchase
    unless current_user.id == @user.id
      return_back and return
    end
  end
  
  def purchased
    unless current_user.id == @user.id
      return_back and return
    end
  end
  
  def news
    unless current_user.id == @user.id
      return_back and return
    end
  end
  
  def review
    unless current_user.id == @user.id
      return_back and return
    end
  end
  
  def contact
    unless current_user.id == @user.id
      return_back and return
    end
  end
  
  def sales
    unless current_user.id == @user.id
      return_back and return
    end
  end
  
  def point
    unless current_user.id == @user.id
      return_back and return
    end
  end
  
  def profile
    unless current_user.id == @user.id
      return_back and return
    end
  end
  
  def delivery_address
    unless current_user.id == @user.id
      return_back and return
    end
  end

  def card
    unless current_user.id == @user.id
      return_back and return
    end

    card = Card.where(user_id: current_user.id).first
    if card.blank?
      redirect_to card_create_mypage_index_path
    else
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
  end

  def card_create
    unless current_user.id == @user.id
      return_back and return
    end

    card = Card.where(user_id: current_user.id)
    redirect_to card_mypage_index_path if card.exists?
  end
    
  def email_password
    unless current_user.id == @user.id
      return_back and return
    end
  end
  
  def identification
    unless current_user.id == @user.id
      return_back and return
    end
  end
  
  def sms_confirmation
    unless current_user.id == @user.id
      return_back and return
    end
  end

  private
  # ユーザーが購入した商品を表示できるようにする
  def purchase_products
    @orders = Order.where(buyer_id: current_user.id)
    @purchase_products = []
    @purchased_products = []
    @orders.each do |order|
      product = Product.find_by(id: order.product_id)
      if product.exhibit_trading?
        @purchase_products << product
      elsif product.exhibited?
        @purchased_products << product
      end
    end
  end

  def like_products
    @likes = Like.where(user_id: current_user.id)
    @like_products = []
    @likes.each do |like|
      product = Product.find_by(id: like.product_id)
      @like_products << product
    end
  end

  def set_user
    @user = User.find(params[:id])
  end
end

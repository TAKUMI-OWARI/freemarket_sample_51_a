class CardsController < ApplicationController
  require "payjp"

  def pay
    Payjp::api_key = ENV['PAYJP_SECRET_KEY']
    if  params['payjp-token'].blank?
      redirect_to card_create_mypage_index_path
    else
      customer = Payjp::Customer.create(
        description: 'test',
        email: current_user.email,
        card:  params['payjp-token'],
        metadata: {user_id: current_user.id}
      )
      @card = Card.new(user_id: current_user.id, customer_id: customer.id, card_id: customer.default_card)
      if @card.save
        redirect_to card_mypage_index_path(@card.user_id)
      else
        redirect_to action: "pay"
      end
    end
  end

  def delete
    card = Card.where(user_id: current_user.id).first
    if card.blank?
    else
      Payjp::api_key = ENV['PAYJP_SECRET_KEY']
      customer = Payjp::Customer.retrieve(card.customer_id)
      customer.delete
      card.delete
    end
    redirect_to card_create_mypage_index_path(current_user.id)
  end

end

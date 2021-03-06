class ChargesController < ApplicationController
  before_action :amount_to_be_charged, :set_description, :authenticate_user!

  def new
  end

  def create
    customer = StripeTool.create_customer(email: params[:stripeEmail],
                                          stripe_token: params[:stripeToken])

    charge = StripeTool.create_charge(customer_id: customer.id,
                                      amount: (@amount.round) * 100,
                                      description: @description)
  current_order.update(:status => 'pending')
  session[:order_id] = nil
  UserMailer.checkout_confirmation(customer).deliver
  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_charge_path
  end

  private

    def amount_to_be_charged
      @amount = current_order.total_price
    end

    def set_description
      @description = "Some amazing product"
    end
end

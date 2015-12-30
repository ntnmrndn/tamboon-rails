class WebsiteController < ApplicationController
  before_action :set_token
  before_action :set_charity!, :only => [:donate]

  def index
    @token = nil
  end

  def donate
    unless @charity.nil? || @token.nil? || params[:amount].blank? || params[:amount].to_i <= 20
      amount = (params[:amount].to_f * 100).to_i
      if Rails.env.test?
        charge = OpenStruct.new({
                                  amount: amount,
                                  paid: (params[:amount].to_i != 999),
                                  currency: "THB",
                                  card: params[:omise_token],
                                  description: "Donation to #{@charity.name} [#{@charity.id}]",
                                })
      else
        charge = Omise::Charge.create({
                                        amount: amount,
                                        currency: "THB",
                                        card: params[:omise_token],
                                        description: "Donation to #{@charity.name} [#{@charity.id}]",
                                      })
      end
      if charge.paid
        @charity.credit_amount(charge.amount)
        flash.notice = t(".success")
        redirect_to root_path
        return
      end
    end
    flash.now.alert = t(".failure")
    render :index
  end

  private

  def set_charity!
    @charity = Charity.find_by(id: params[:charity])
  end

  def set_token
    if params[:omise_token].blank?
      @token = nil
    elsif Rails.env.test?
      @token = OpenStruct.new({
        id: "tokn_X",
        card: OpenStruct.new({
          name: "J DOE",
          last_digits: "4242",
          expiration_month: 10,
          expiration_year: 2020,
          security_code_check: false,
        }),
      })
    else
      @token = Omise::Token.retrieve(token)
    end
  end
end

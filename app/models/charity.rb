class Charity < ActiveRecord::Base
  validates :name, presence: true

  def credit_amount(amount)
    lock! #Depending on usecase, optimistic locking might be better
    new_total = Charity.where(:id => id).select(:total).first.total + amount
    update_attribute :total, new_total
  end
end

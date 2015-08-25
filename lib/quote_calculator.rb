require 'csv'

class QuoteCalculator
  MAX_VALUE = 15000
  MIN_VALUE = 100
  TERM = 36 # 36 months
  
  class PrincipleOutOfRange < StandardError;end
  class QuoteUnavailable < StandardError;end
  
  def initialize(market_filepath)
    @market = CSV.table(market_filepath).entries.sort_by{ |lender| lender[:rate] }
    @market_value = BigDecimal.new(@market.map{|l| l[:available].to_i }.reduce(:+))
  end
  
  def quote(principle, term = TERM)
    principle = BigDecimal.new(principle.to_i).round(-2, :up)
    fail PrincipleOutOfRange unless (MIN_VALUE..MAX_VALUE).include?(principle)
    fail QuoteUnavailable if principle > @market_value
    
    loans = []
    @market.reduce(0) do |value, lender|
      amount = [(principle - value), BigDecimal.new(lender[:available])].min
      loans << TableLoan.new(lender[:rate], amount, term)
      break if value + amount >= principle
      value + amount
    end
    
    { request: principle.to_i,
      term: term,
      rate_pct: (approximate_rate(principle, loans) * 100).to_f.round(1),
      monthly_payment: loans.map(&:monthly_payment).reduce(:+).to_f,
      total_payment: loans.map(&:total_payment).reduce(:+).to_f.round(2) }
  end
  
  private
  def approximate_rate(principle, loans)
    true_monthly_payment = loans.map(&:monthly_payment).reduce(:+)
    hi, lo = loans.max_by(&:apr).apr, 0
    current_guess = lo + ((hi - lo) / 2) # in case hi is 0.001 or below
    
    while (hi - lo) > 0.001
      current_guess = lo + ((hi - lo) / 2)
      current_loan = TableLoan.new(current_guess, principle, TERM)
      
      if current_loan.monthly_payment > true_monthly_payment
        hi = current_guess
      elsif current_loan.monthly_payment < true_monthly_payment
        lo = current_guess
      else
        break
      end
    end
    
    current_guess
  end
end

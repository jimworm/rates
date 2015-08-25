require 'bigdecimal'

class TableLoan
  attr_reader :apr
  attr_reader :monthly_rate
  # Ye olde table loan formula
  # Payment = (Principle * PeriodRate) / (1 - (1 + PeriodRate)^(-Periods))
  
  def initialize(apr, principle, months)
    @apr = BigDecimal.new(apr, 14)
    @monthly_rate = apr / BigDecimal.new(12)
    @principle = BigDecimal.new(principle)
    @months = months.to_i
  end
  
  def monthly_payment
    @monthly_payment ||= (@principle * @monthly_rate / (1 - (1 + @monthly_rate)**(-@months))).round(2)
  end
  
  def total_payment
    @total_payment ||= monthly_payment * @months
  end
end

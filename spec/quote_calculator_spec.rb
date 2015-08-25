require 'spec_helper'

describe "QuoteCalculator" do
  describe "#quote" do
    let(:csv_path)    { 'spec/market.csv' }
    let(:calculator)  { QuoteCalculator.new(csv_path) }
    
    it "returns the correct values" do
      expect(calculator.quote(1000)).
        to eq({ request: 1000,
                term: 36,
                rate_pct: 7.0,
                monthly_payment: 30.78,
                total_payment: 1108.10 })
    end
    
    it "rounds principles up to the nearest 100" do
      expect(calculator.quote(1001)).to include({ request: 1100 })
    end
    
    it "does not accept principles smaller than 100 or larger than 15000 after rounding" do
      expect{calculator.quote(0)}.to raise_error(QuoteCalculator::PrincipleOutOfRange)
      expect{calculator.quote(15001)}.to raise_error(QuoteCalculator::PrincipleOutOfRange)
    end
    
    it "does not accept principles larger than the total value of the market" do
      expect{calculator.quote(3000)}.to raise_error(QuoteCalculator::QuoteUnavailable)
    end
  end
end

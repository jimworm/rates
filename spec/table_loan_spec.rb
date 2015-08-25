require 'spec_helper'

describe "TableLoan" do
  let(:loan_one)      { TableLoan.new(12.0, 300, 1) }
  let(:loan_two)      { TableLoan.new(12.0, 300, 2) }
  
  describe "#monthly_payment" do
    it "returns the correct value" do
      expect(loan_one.monthly_payment).to eq(600)
      expect(loan_two.monthly_payment).to eq(400)
    end
  end
  
  describe "#total_payment" do
    it "returns the correct value" do
      expect(loan_one.total_payment).to eq(600)
      expect(loan_two.total_payment).to eq(800)
    end
  end
end

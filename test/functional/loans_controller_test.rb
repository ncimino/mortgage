require 'test_helper'

class LoansControllerTest < ActionController::TestCase
  setup do
    @loan = loans(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:loans)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create loan" do
    assert_difference('Loan.count') do
      post :create, loan: { asset_price: @loan.asset_price, downpayment: @loan.downpayment, escrow_payment: @loan.escrow_payment, first_payment: @loan.first_payment, interest_rate: @loan.interest_rate, payments_per_year: @loan.payments_per_year, planned_payment: @loan.planned_payment, years: @loan.years }
    end

    assert_redirected_to loan_path(assigns(:loan))
  end

  test "should show loan" do
    get :show, id: @loan
    assert_response :success
  end

  test "should get calculator" do
    get :calculator, id: @loan
    assert_response :success
  end

  test "should update loan" do
    put :update, id: @loan, loan: { asset_price: @loan.asset_price, downpayment: @loan.downpayment, escrow_payment: @loan.escrow_payment, first_payment: @loan.first_payment, interest_rate: @loan.interest_rate, payments_per_year: @loan.payments_per_year, planned_payment: @loan.planned_payment, years: @loan.years }
    assert_redirected_to loan_path(assigns(:loan))
  end

  test "should destroy loan" do
    assert_difference('Loan.count', -1) do
      delete :destroy, id: @loan
    end

    assert_redirected_to loans_path
  end
end

require 'test_helper'
require 'curb'

class PurchasesControllerTest < ActionController::TestCase
  test "the truth" do
    http = Curl.post('http://localhost:3000/purchase',{"sid"=>"202864835", "middle_initial"=>"", "li_0_name"=>"Advanced plan subscription", "key"=>"5A618F76EF2F0A7B6088D5B540944A02", "state"=>"", "email"=>"mikhail.chuprynski@gmail.com", "li_0_type"=>"product", "li_0_duration"=>"Forever", "order_number"=>"105892769814", "lang"=>"en", "currency_code"=>"USD", "invoice_id"=>"105892769826", "li_0_price"=>"99.00", "total"=>"99.00", "credit_card_processed"=>"Y", "zip"=>"43228", "li_0_quantity"=>"1", "cart_weight"=>"0", "fixed"=>"Y", "submit"=>"Choose advanced", "last_name"=>"Chuprynski", "li_0_product_id"=>"", "street_address"=>"Mayakovskogo 49a", "city"=>"Mogilev", "li_0_tangible"=>"N", "li_0_description"=>"", "ip_country"=>"Russian Federation", "country"=>"BLR", "merchant_order_id"=>"", "demo"=>"Y", "pay_method"=>"CC", "cart_tangible"=>"N", "phone"=>"+375296502498 ", "li_0_recurrence"=>"1 Month", "li_0_uid"=>"102594557413371756317", "street_address2"=>"", "first_name"=>"Mikhail", "card_holder_name"=>"Mikhail Chuprynski"})
    assert http.body_str.present?
  end
end

require "test_helper"

class ShoppingListsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get shopping_lists_index_url
    assert_response :success
  end

  test "should get create" do
    get shopping_lists_create_url
    assert_response :success
  end

  test "should get update" do
    get shopping_lists_update_url
    assert_response :success
  end

  test "should get destroy" do
    get shopping_lists_destroy_url
    assert_response :success
  end

  test "should get reset" do
    get shopping_lists_reset_url
    assert_response :success
  end
end

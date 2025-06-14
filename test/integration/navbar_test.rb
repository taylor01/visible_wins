require "test_helper"

class NavbarTest < ActionDispatch::IntegrationTest
  test "navbar shows user profile dropdown when logged in" do
    user = users(:alice)
    sign_in_as(user)

    get root_path
    assert_response :success

    # Check that profile dropdown button is present (desktop)
    assert_select "[data-controller='dropdown']", count: 2 # desktop + mobile

    # Check that user initials are displayed
    assert_select "div", text: user.first_name.first.upcase + user.last_name.first.upcase

    # Check that profile links are present in dropdown
    assert_select "a[href='#{profile_edit_path}']", text: "Edit Profile"

    # Check that logout link is present
    assert_select "a[href='#{logout_path}']", text: "Sign out"

    # Check that user info is displayed in dropdown
    assert_select "p", text: user.full_name
  end

  test "navbar shows mobile menu on small screens" do
    user = users(:alice)
    sign_in_as(user)

    get root_path
    assert_response :success

    # Check that mobile menu button exists
    assert_select "button svg[aria-hidden='true']" # hamburger menu icon

    # Check that navigation links are in mobile dropdown
    assert_select ".md\\:hidden [role='menu']" do
      assert_select "a", text: "Schedule"
      assert_select "a", text: "Update My Schedule"
      assert_select "a", text: "Edit Profile"
      assert_select "a", text: "Sign out"
    end
  end

  test "navbar shows admin link for admin users" do
    admin_user = users(:admin)
    sign_in_as(admin_user)

    get root_path
    assert_response :success

    # Check admin link is present in desktop nav
    assert_select ".hidden.md\\:flex a[href='#{admin_root_path}']", text: "Admin"

    # Check admin link is present in mobile nav
    assert_select ".md\\:hidden a[href='#{admin_root_path}']", text: "Admin"
  end

  test "navbar does not show admin link for regular users" do
    user = users(:alice)
    sign_in_as(user)

    get root_path
    assert_response :success

    # Check admin link is not present
    assert_select "a[href='#{admin_users_path}']", count: 0
  end
end

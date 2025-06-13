ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module ActionDispatch
  class IntegrationTest
    # Helper method to simulate OIDC authentication for tests
    def sign_in_as(user)
      post "/test_login", params: { user_id: user.id }
    end

    # Helper method to simulate logout
    def sign_out
      delete logout_path
    end
  end
end

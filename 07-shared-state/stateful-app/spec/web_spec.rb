require "web"

require "rack/test"

require "ipaddr"

RSpec.describe Web do
  include Rack::Test::Methods

  def app
    @app ||= Web.new
  end

  describe "GET /" do
    let(:home_page) {
      get "/"
      last_response.body
    }

    it "app instance index" do
      expect(home_page).to match( /Hi, I'm app instance \d+/)
    end

    it "running at" do
      expect(home_page).to include("at example.org:80")
    end

    it "total instance responses" do
      expect(home_page).to match(/\d+ times through this app instance/)
    end

    it "total app responses" do
      expect(home_page).to match(/\d+ times in total/)
    end
  end
end

require 'mechanize'
module Elastix
  attr_accessor :elastix
  class Base
    def self.establish_connection( ip, username, password)
      @@elastix = Mechanize.new
      @@elastix.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      @@base_address = "https://#{ip}"
      @@elastix.get(@@base_address) 
      login_form = @@elastix.page.forms[0]
      login_form.input_user = username
      login_form.input_pass = password
      @@elastix.submit(login_form,login_form.button_with("submit_login"))
    end

    def self.close_connection
      @@base_address = nil
      @@elastix = nil
    end

    def self.reload
      @@elastix.get("#{@@base_address}/config.php?handler=reload")
    end
  end
end

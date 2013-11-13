require 'mechanize'
module Elastix
  class Base
    def self.establish_web_connection host, username, password
      @@elastix = Mechanize.new
      @@elastix.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      @@base_address = "https://#{host}"
      login username, password
    end
    

    def self.establish_db_connection(host, username, password)
      ActiveRecord::Base.establish_connection(
        :adapter  => "mysql2",
        :host     => host,
        :database => "asterisk",
        :username => username,
        :password => password,
      )
    end

    def self.establish_connection(web_options={}, db_options={})
      establish_web_connection(web_options[:host], web_options[:username], web_options[:password])
      establish_db_connection(db_options[:host], db_options[:username], db_options[:password])
    end

    def self.close_db_connection
      ActiveRecord::Base.connection.close
    end

    def self.use_existing_db_connection connection
      ActiveRecord::Base.establish_connection connection
    end

    def self.close_db_connection
      @@base_address = nil
      @@elastix = nil
    end

    def self.reload
      @@elastix.get("#{@@base_address}/config.php?handler=reload")
    end

    private
      def self.login username, password
        @@elastix.get(@@base_address) 
        login_form = @@elastix.page.forms[0]
        login_form.input_user = username
        login_form.input_pass = password
        @@elastix.submit(login_form,login_form.button_with("submit_login"))
      end
  end
end

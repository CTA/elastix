module Elastix
  class User < ActiveRecord::Base
    def self.use_existing_db_connection connection
      establish_connection connection
    end
  end
end

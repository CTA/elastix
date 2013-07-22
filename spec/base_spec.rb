require 'spec_helper'

describe Base do
  describe ".establish_connection" do
    before { Base.establish_connection $auth_options[:ip], $auth_options[:username], $auth_options[:password] }
    it "should assign an address to $base_address" do
      $base_address.should eq "https://192.168.1.237"
    end

    it "should assign a mechanize agent to $elastix" do
      $elastix.class.should eq Mechanize
    end

    it "should log into the webform" do
      $elastix.page.title.should eq "Elastix"
    end
  end
  
  describe ".close_connection" do
    before{ Base.close_connection }
    it "should assign $base_address to nil" do
      $base_address.should be_nil
    end

    it "should assign $elastix to nil" do
      $elastix.should be_nil
    end
  end

  pending "it should apply the configuration changes"
end

require 'spec_helper'

describe Extension do
  let(:params) {
      {
        "extension" => "4555", "sipname" => "3333",
        "outboundcid" => "3333333333", "name" => "David Hahn", "devinfo_secret" => "secret"
      }
  }

  before { Base.establish_connection $auth_options[:ip], $auth_options[:username], $auth_options[:password] }
  after(:all){ Base.close_connection }
  after(:each) do
    Extension.new(params).destroy if Extension.find(params["extension"])
  end

  describe ".initialize" do
    it "should assign all params to their attribute equivalents" do
      e = Extension.new(params)
      params.each_pair {|key,value| e.send(key).should eq value}
    end
  end
  
  describe ".create" do
    it "should create an extension" do
      e = Extension.create(params) 
      Extension.find(params["extension"]).to_hash.should eq e.to_hash
    end

    it "should return an Extension object" do
      Extension.create(params).class.should eq Elastix::Extension
    end
  end
  
  describe ".save" do
    it "should create an extension" do
      e = Extension.new(params)
      e.save
      Extension.find(params["extension"]).should_not be_nil
    end

    it "should raise error if extension already exists" do
      Extension.create(params)
      Extension.new(params)
      expect{Extension.save(params)}.to raise_error
    end
  end
  
  describe ".find" do
    it "should return nil if extension doesn't exist" do
      Extension.find("-9999999").should be_nil
    end

    it "should return the extension object if extension does exist" do
      e = Extension.new(params)
      e.save
      Extension.find(params["extension"]).to_hash.should eq e.to_hash
    end
  end
  
  describe ".destroy" do
    it "should remove the extension from the interface" do
      e = Extension.create(params)
      e.destroy
      Extension.find(params["extension"]).should be_nil
    end
  end
  
  describe ".all" do
    it "should return all extensions" do
      e = Extension.create(params)
      Extension.all.should include e
    end
  end

  describe ".==" do
    it "should return true if method contain the same attributes" do
      e = Extension.new(params)
      e2 = Extension.new(params)
      (e == e2).should be_true
    end

    it "should return true if method contain the same attributes" do
      e = Extension.new(params)
      e2 = Extension.new({"extension" => "333333"})
      (e == e2).should be_false
    end
  end
  
  describe ".to_hash" do
    it "should output the attributes of an extension to a hash" do
      e = Extension.create(params)
      e.to_hash.should eq params
    end
  end

  describe ".update_attributes" do
    it "should only update the attributes that are input" do
      e = Extension.create(params)
      e.update_attributes!("sipname" => "testing")
      new_ext = Extension.find(e.extension)
      e.to_hash.should eq new_ext.to_hash
    end
  end
end

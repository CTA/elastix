# Elastix

This rubygem is an integration of the Elastix Call Center Module. So far it only includes functionality for managing extensions. It was built on top of ruby mechanize and for some reason I was having issues with symbols in the hashes so in the meantime you must use strings in the hashes passed into these methods. I apologize if this is inconvenient.

## Installation

Add this line to your application's Gemfile:

    gem 'elastix'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install elastix

## Usage

This gem models the Active Record implementation. If you are familiar with Active Record
this gem should come pretty easy to you. For instance:

    options = {
        "extension" => "4555", "sipname" => "3333",
        "outboundcid" => "3333333333", "name" => "David Hahn", "devinfo_secret" => "secret"
      }
    Elastix::Base.establish_connection "192.168.1.253", "user", "password"
    ext = Elastix::Extension.new options
    ext.save
    e = Elastix::Extension.find options["extension"]
    e.destroy
    Elastix::Base.close_connection

Here is a list of methods that have been implemented:
  * create
  * save
  * find
  * destroy
  * all
  * ==
  * to\_hash
  * update\_attributes

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

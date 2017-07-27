require 'spec_helper'

module LogInterceptor
  @@intercepted_request = ""
  def self.debug(message)
    # save only the first XMLly message
    if message.include? "xml version"
      @@intercepted_request = message if @@intercepted_request == ""
    end
  end

  def self.info(message)
  end

  def self.get_intercepted_request
    @@intercepted_request
  end

  def self.reset_intercepted_request
    @@intercepted_request = ""
  end
end

describe 'rubyntlm side-effects' do
  it "works with the default adapter" do
    LogInterceptor.reset_intercepted_request

    HTTPI.adapter = :httpclient
  
    client = Savon.client(
      :wsdl => "http://www.webservicex.net/ConvertTemperature.asmx?WSDL",
      :logger => LogInterceptor
    )

    ops = client.operations
    expect(ops).to include(:convert_temp)
  end

  # NOTE: This works unless 'mechanize' is loaded in the Gemfile, otherwise it fails with
  #  1) rubyntlm side-effects should work with the net_http adapter as well
  #     Failure/Error: ops = client.operations
  #     ArgumentError:
  #       Invalid version of rubyntlm. Please use v0.3.2+.
  #     # ./lib/savon/client.rb:28:in `operations'
  #     # ./spec/integration/ntlm_example_spec.rb:51:in `block (2 levels) in <top (required)>'
  it "should work with the net_http adapter as well" do
    LogInterceptor.reset_intercepted_request

    HTTPI.adapter = :net_http

    client = Savon.client(
      :wsdl => "http://www.webservicex.net/ConvertTemperature.asmx?WSDL",
      :logger => LogInterceptor
    )

    ops = client.operations
    expect(ops).to include(:convert_temp)
  end

end

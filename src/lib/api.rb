require 'net/http'
require 'uri'
require 'json'

module Api
  @@auth_key = (File.read(__dir__ + "/auth_key.txt").chomp + "vpsH1H")
  @@host = "http://icfpc2013.cloudapp.net"

  module_function
  def train(size: nil, operators: [])
    post('train', JSON.generate(size: size.to_i, operators: operators))
  end

  def guess(id: nil, program: nil)
    if id.nil? && program.nil?
      raise "You should set both"
    end

    res = post('guess', JSON.generate(id: id, program: program))
    if ['win', 'mismatch'].include?(res['status'])
      return res
    else
      raise "ServerSideError: status=<#{res['status']}>, message=<#{res['message']}>"
    end
  end

  def myproblems
    post('myproblems')
  end

  def status
    post('status')
  end

  def eval(id: nil, program: nil, inputs: [])
    if (id.nil? && program.nil?) || (id && program)
      raise "You must set either id or program"
    end

    arguments = inputs.map{|arg| "0x" + arg.to_s(16) }
    res = post('eval', JSON.generate(id: id, program: program, arguments: arguments))
    if res['status'] == 'ok'
      return res
    else
      raise "ServerSideError: status=<#{res['status']}>, message=<#{res['message']}>"
    end
  end

  private
  module_function
  def uri(path)
    URI.parse("#{@@host}/#{path}?auth=#{@@auth_key}")
  end

  def post(path, body=nil)
    puts "--> POST: #{path} #{body}"
    url = uri(path)
    req = Net::HTTP::Post.new("#{url.path}?#{url.query}")
    req.body = body
    res = Net::HTTP.start(url.host){|http| http.request(req) }
    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      json = JSON.parse(res.body)
      puts "<-- POST: #{path} #{json}"
      return json
    else
      return res.value
    end    
  end
end

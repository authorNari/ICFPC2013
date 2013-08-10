require 'net/http'
require 'uri'
require 'json'

module Api
  @@auth_key = (File.read(__dir__ + "/auth_key.txt").chomp + "vpsH1H")
  @@host = "http://icfpc2013.cloudapp.net"

  module_function
  def train
    post('train')
  end

  def guess(id: nil, program: nil)
    if id.nil? && program.nil?
      raise "You should set both"
    end

    post('guess', JSON.generate(id: id, program: program))
  end

  def myproblems
    post('myproblems')
  end

  def status
    post('status')
  end

  def eval(id: nil, program: nil, arguments: [])
    if (id.nil? && program.nil?) || (id && program)
      raise "You must set either id or program"
    end

    arguments.map!{|arg| "0x" + arg.to_s(16) }
    post('eval', JSON.generate(id: id, program: program, arguments: arguments))
  end

  private
  module_function
  def uri(path)
    URI.parse("#{@@host}/#{path}?auth=#{@@auth_key}")
  end

  def post(path, body=nil)
    url = uri(path)
    req = Net::HTTP::Post.new("#{url.path}?#{url.query}")
    req.body = body
    res = Net::HTTP.start(url.host){|http| http.request(req) }
    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      return JSON.parse(res.body)
    else
      return res.value
    end    
  end
end

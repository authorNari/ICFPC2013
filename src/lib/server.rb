base_dir = File.expand_path(__dir__)
top_dir = File.expand_path(File.join(base_dir, ".."))
$LOAD_PATH.unshift(File.join(top_dir, "lib"))
require "bundler"
Bundler.require(:server)

require 'uri'
require 'solver'
require 'sinatra'
require 'haml'

get '/' do
  @title = 'myprombels'
  # @json = [Api.myprombels]
  @json = [
    {"id"=>"018s6MMIauABBz1XPkfbsgtN",
      "size"=>12,
      "operators"=>["and", "if0", "plus", "shl1", "shr16", "tfold"]},
    {"id"=>"01GSoTCyBHP5IBuUpKwj268K",
      "size"=>23,
      "operators"=>
      ["and", "if0", "not", "or", "plus", "shl1", "shr1", "shr4", "xor"]}]
  index
end


get '/train' do
  @title = 'train'
  @json = []
  5.times{ @json << Api.train }
  index
end

get '/solve' do
  @title = 'solved'
  @json = JSON.parse(params[:json])
  solver = Solver.new
  @res = solver.solve(@json['id'], @json['size'], @json['operators'])
  haml :solve
end

def index
  haml :index
end

__END__

@@ layout
%html
  %title
    = @title
  :css
    table {
      border-width: thin; border-style: solid;
      border-collapse: collapse;
    }
    table td {
      border-width: thin;
      border-style: solid;
      padding: 7px;
    }
    table tbody tr.chance td {
      background-color: #66cccc;
    }
    table tbody tr.done td {
      background-color: sliver;
    }
  %body
    = yield

@@ index
%a{:href => '/'}
  myproblems
&nbsp;|&nbsp;
%a{href: '/train'}
  train
%table
  %thead
    %tr
      %td= "ID"
      %td size
      %td operators
      %td solved?
      %td timeLeft
      %td= " "
  %tbody
    - @json.each do |json|
      - tr_klass = []
      - tr_klass << (json['timeLeft?'] ? 'done' : nil)
      - tr_klass << ((json['size'].to_i <= 12) ? 'chance' : nil)
      - tr_klass = tr_klass.compact.join(",")
      %tr{class: tr_klass}
        %td= json['id']
        %td= json['size']
        %td= json['operators']
        %td= json['solved?']
        %td= json['timeLeft?']
        %td
          %a{href: URI.escape("/solve?json=#{JSON.generate(json)}")}
            solve!

@@ solve
%a{:href => '/'}
  myproblems
&nbsp;|&nbsp;
%a{href: '/train'}
  train
%p
  solved? : 
  = @res
%p
  size :
  = @json['size']
%p
  operators :
  = @json['operators']
- if @json['challenge']
  %p
    challenge :
    = @json['challenge']

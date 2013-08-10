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
  @title = 'myproblems'
  @json = Api.myproblems
  index
end


get '/train' do
  @title = 'train'
  @json = []
  5.times{ @json << Api.train }
  sleep 10
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
      background-color: gray;
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
      %td challenge
      %td= " "
  %tbody
    - @json.each do |json|
      - tr_klass = []
      - tr_klass = 'chance' if json['size'].to_i <= 10
      - tr_klass = 'done' if json['solved']
      %tr{class: tr_klass}
        %td= json['id']
        %td= json['size']
        %td= json['operators']
        %td= json['solved'].to_s
        %td= json['timeLeft'].to_s
        %td= json['challenge'].to_s
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

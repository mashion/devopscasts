require 'bundler'
Bundler.require

use Rack::Static, :urls => ['/css', '/js', '/images', '/favicon.ico'], :root => 'public'
use Rack::CommonLogger

if ENV['RACK_ENV'] == 'development'
  use Rack::ShowExceptions
end

toto = Toto::Server.new do
  set :author,    'Mat Schaffer'
  set :title,     'DevOpsCasts'
  set :url,       'http://devops.mashion.net'
  set :disqus,    'devopscasts'
  set :ext,       'md'
  set :date,      lambda {|now| now.strftime("%B #{now.day.ordinal} %Y") }

  # set :root,      "index"                                   # page to load on /
  # set :date,      lambda {|now| now.strftime("%d/%m/%Y") }  # date format for articles
  # set :markdown,  :smart                                    # use markdown + smart-mode
  # set :summary,   :max => 150, :delim => /~/                # length of article summary and delimiter
  # set :cache,      28800                                    # cache duration, in seconds
end

run toto

require 'sinatra'
require 'erb'

module EventChopper

class Server < Sinatra::Base
  include EventChopper

  set :port, 5000
  set :static, true
  set :public_folder, File.dirname(__FILE__) + '/server'

  def reporter_name
    params[:reporter]
  end

  def reporter
    Object.const_get('EventChopper').const_get(reporter_name).new
  end

  def timekey param, size = :minute
    TimeKey.from_string param, size
  end

  def from
    timekey params[:from], params[:period].to_sym
  end

  def to
    timekey params[:to]
  end

  def period
    params[:period].nil? ? :hour : params[:period].to_sym
  end

  def single
    reporter.fetch(from)
  end

  def csv
    r = reporter
    r.csv(r.fetch(from))
  end

  def range
    from.till(to, period).inject({}) do |acc, key|
      acc[key] = reporter.fetch key
      acc
    end
  end

  get '/json' do
    content_type 'application/json'
    encode(params.has_key?('to') ? range : single)
  end

  get '/csv' do
    content_type 'text/csv'
    attachment "#{reporter_name}_#{from.to_s}.csv"
    csv
  end


end

end

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
    reporter.get(from)
  end

  def range
    from.till(to, period).inject({}) do |acc, key|
      acc[key] = reporter.get key
      acc
    end
  end

  get '/json' do
    content_type 'application/json'
    encode(params.has_key?('to') ? range : single)
  end

end

end

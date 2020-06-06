#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'

set :database, "sqlite3:barbershop.db"

# Классы объектов

class Client < ActiveRecord::Base
  validates :name,      presence: true, length: { minimum: 3 }
  validates :phone,     presence: true
  validates :datestamp, presence: true
  validates :color,     presence: true
end

class Barber < ActiveRecord::Base
end

class Feedback < ActiveRecord::Base
end

# Events

before do
	@barbers = Barber.all
end

# Routes

get '/' do
  erb :index
end

get '/contacts' do
  erb :contacts
end

get '/visit' do
  @newcl = Client.new
  erb :visit
end

get '/barber/:id' do
  @barber = Barber.find params[:id]
  erb :barber
end

get '/clients' do
  @clients = Client.order('created_at DESC').where('NOT datestamp IS NULL')
  erb :clients
end

get '/client/:id' do
  @client = Client.find params[:id]
  erb :client
end

post '/visit' do
  @newcl = Client.new params[:client]
  if @newcl.save
    @message = 'Спасибо. Вы записались!'
    erb :message
  else
    @error = @newcl.errors.full_messages.first
    erb :visit
  end
end

post '/contacts' do
  @content = params[:content]

  if @content == ''
    @error = 'Не введен текст сообщения!'
    return erb :contacts
  end

  if write_feedback(@content)
    @message = 'Спасибо. Ваш отзыв очень важен для нас'
    erb :message
  else
    @error = 'Ошибка записи. Попробуйте еще раз.'
    erb :contacts
  end
end

# DB writing

def write_client(username,phone,datestamp,barber,color)
  Client.create  :name      => username, 
                 :phone     => phone,
                 :datestamp => datestamp,
                 :barber    => barber,
                 :color     => color;
    true
end

def write_feedback(content)
  Feedback.create :content => content
  true
end
#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'

set :database, "sqlite3:barbershop.db"

class Client < ActiveRecord::Base
end

class Barber < ActiveRecord::Base
end

class Feedback < ActiveRecord::Base
end

before do
	@barbers = Barber.all
end

get '/' do
	erb :index			
end

get '/contacts' do
	erb :contacts
end

get '/visit' do
    erb :visit
end

post '/visit' do
    @username  = params[:username]; 
    @phone     = params[:phone];
	@datetime  = params[:datetime];
    @master    = params[:master];
    @color     = params[:color];

    @title     = 'Thanks you!';
    @message   = "Dear #{@username}, we'll be waiting for you at #{@datetime}. Master: #{@master}. Color: #{@color}";

   # Проверка заполнения
   errPattern = {
        :username   => 'Введите имя',
        :phone      => 'Укажите телефон',
        :datetime   => 'Не правильная дата визита'
    };

    @error = errPattern.select {|key,_| params[key] == ''}.values.join(", "); 

    if @error != '' 
        return erb :visit 
    end;

    # Запись в файл
    if write_client(@username,@phone,@datetime,@master,@color) 
        erb :message 
    else
        @error = 'Ошибка записи. Попробуйте еще раз.';
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
#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

get '/' do
  erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School!!!!!!!!!!!!!!</a>"
end
get '/about' do
  @error
  erb :about
end

get '/writeof' do
  erb :visit
end

post '/writeof' do
  @user_name = params[:user_name]
  @user_phone = params[:user_phone]
  @user_time = params[:user_time]
  @user_master = params[:user_master]
  @user_color = params[:color]
  @title = 'Thank you'
  @message = "#{@user_name}, вы записаны к #{@user_master} на #{@user_time}"
  hh = {
      :user_name => 'Введите имя',
      :user_phone => 'Введите телефон',
      :user_time => 'Введите время'
  }
  @error = hh.select { |key, _| params[key] == "" }.values.join("</br>")
  if @error != ""
    return erb :visit
  end
  f = File.open "./public/users.txt", "a"
  f.write "\n #{@user_master} \n #{@user_time} -- #{@user_phone} -- #{@user_name} -- #{@user_color} \n"
  f.close
  erb :message
end


get '/contacts' do
  erb :contacts
end

post '/contacts' do
  require "pony"
  @user_email = params[:user_email]
  @user_message = params[:user_message]
  my_mail = "kegz@mail.ru"
  password ="dshjljr" #неотображать вводимые символы
  sent_to = "kegz@mail.ru"
  message = @user_email + "\n \n" + @user_message

  hh = {
      :user_email => 'Введите правильный e-mail',
      :user_message => 'Введите текст сообщения',
  }
  @error = hh.select { |key, _| params[key] == "" }.values.join("</br>")
  if @error > ""
    erb :contacts

    else

  begin #обработка ошибок
    Pony.mail(
        {
            :subject => "С сайта BARBERSHOP",
            :body => message,
            :to => sent_to,
            :from => my_mail,

            :via => :smtp,
            :via_options => {
                :address => 'smtp.mail.ru',
                :port => '465',
                :tls => true,
                :user_name => my_mail,
                :password => password,
                :authentication => :plain
            }
        }
    )
    @message = "Успешно отправлено"
  rescue Net::SMTPAuthenticationError => error
    @message = " Ошибка аутентификации " + error.message.to_s
  rescue Net::SMTPFatalError => error
    @message = " Проверьте данные адресата " + error.message
      # puts "Не удалось отправить письмо"
  ensure
    #puts "Попытка отправки письма закончена"
  end #обработка ошибок
  erb :message
  end
end


get '/login' do
  erb :login
end

post '/login/attempt' do
  @username = params[:username]
  @pass = params[:pass]
  if @username == "admin" && @pass == "secret"
    session[:identity] = params['username']
    where_user_came_from = session[:previous_url] || '/'
    redirect to where_user_came_from
  else
    where_user_came_from = session[:previous_url] || '/login/attempt'
    redirect to where_user_came_from
    @message = "Доступ запрещён"
  end
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

if (Gem.win_platform?)
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

def is_barber_exists? db, name
 db.execute('select * from Master where name=?', [name]).length > 0
end

def seed_db db, master

  master.each do |masters|
    if !is_barber_exists? db, masters
      db.execute 'insert into Master (Name) values (?)', [masters]
    end
  end

end

def get_db_bs
  db = SQLite3::Database.new (Dir.pwd + '/bd/bs.db')
  db.results_as_hash = true
  return db
end

before do
  db = get_db_bs
  @master = db.execute 'select * from Master'
end



configure do

  db = get_db_bs

  db.execute 'CREATE TABLE IF NOT EXISTS
  "Users"
  (
  "Id"
  INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
  "Name" TEXT,
  "Phone" TEXT,
  "DateStamp" TEXT,
  "Barber" TEXT,
  "Color" TEXT
  );'

  db.execute 'CREATE TABLE IF NOT EXISTS
  "Contacts"
  (
  "Id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
  "Email" TEXT,
  "Message" TEXT
  );'

  db.execute 'CREATE TABLE IF NOT EXISTS
  "Master"
  (
  "Id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
  "Name" TEXT
  );'

  seed_db db, ['keGZ', 'Ronaldo', 'Suka','Suka', 'Suka', 'Tvarit Dobro']



  db.close
end



get '/' do
  erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School!!!!!!!!!!!!!!</a>"
end
get '/about' do
  @error
  erb :about
end


# запись к парихмехеру
get '/writeof' do
  spisok_masters
  erb :visit

end

post '/writeof' do

  spisok_masters
  #erb :visit

  @user_name = params[:user_name]
  @user_phone = params[:user_phone]
  @user_time = params[:user_time]
  @user_master = params[:user_master]
  @user_color = params[:color]
  @title = 'Thank you'

  hh = {
      :user_name => 'Введите имя',
      :user_phone => 'Введите телефон',
      :user_time => 'Введите время'
  }
  @error = hh.select { |key, _| params[key] == "" }.values.join("</br>")
  if @error != ""
    return erb :visit
  end
  db = get_db_bs
  db.execute 'INSERT INTO
  "Users"
  (
  "Name",
  "Phone",
  "DateStamp",
  "Barber",
  "Color"
  )
  VALUES
(
?, ?, ?, ?, ?
)', [@user_name, @user_phone, @user_time, @user_master, @user_color]

  @message = "#{@user_name}, вы записаны к #{@user_master} на #{@user_time}"

  f = File.open "./public/users.txt", "a"
  f.write "\n #{@user_master} \n #{@user_time} -- #{@user_phone} -- #{@user_name} -- #{@user_color} \n"
  f.close
  erb :message
end
#=============================================================================================


# написать письмо
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

#==============================================================================


get '/login' do
  erb :login
end

post '/login/attempt' do
  @username = params[:username]
  @pass = params[:pass]
  if @username == "admin" && @pass == "secret"
    db = get_db_bs
    @result = db.execute 'select * from Users order by DateStamp'
    erb :db_writer
  else
    where_user_came_from = session[:previous_url] || '/login'
    redirect to where_user_came_from
    @message = "Доступ запрещён"
  end
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end








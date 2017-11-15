if (Gem.win_platform?)
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end
require 'sqlite3'
bd = SQLite3::Database.new (Dir.pwd + '/bd/bs.db')
@print_vibor = '<select name="user_master" class="form-group" type="text">'+"\n"
@data_db = []
bd.execute 'select Name from Master' do |row|
  row.each { |value| @print_vibor = @print_vibor + '<option <%={@user_master == ' + "#{value.to_s}" + ' ? "selected" : '' %> >'+"#{value.to_s}"+'</option>'+"\n"}
end
@print_vibor = @print_vibor + '</select>'
print @print_vibor

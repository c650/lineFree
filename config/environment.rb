require 'bundler'
require 'Indirizzo'
Bundler.require

configure :development do
  set :database, "sqlite3:db/database.db"
end
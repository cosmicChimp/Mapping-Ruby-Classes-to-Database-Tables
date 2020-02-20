# -Creating the Database
#     Before we can create a songs table we need to create our music database. 
#     Whose responsibility is it to create the database? It is not the responsibility of our Song class. 
#     Remember, classes are mapped to tables inside a database, not to the database as a whole. 
#     We may want to build other classes that we equate with other database tables later on.

#     It is the responsibility of our program as a whole to create and establish the database. 
#     Accordingly, you'll see our Ruby programs set up such that they have a config directory that contains an environment.rb file.
#     This file will look something like this:

require 'sqlite3'
require_relative '../lib/song.rb'

DB = {:conn => SQLite3::Database.new('db/music.db')}
# -CREATING THE TABLE
#     According to the ORM convention in which a class is mapped to or equated with a database table, we need to create a songs table. 
#     We will accomplish this by writing a class method in our Song class that creates this table.
#     To "map" our class to a database table, we will create a table with the same name as our class and give that table column names that match the attr_accessors of our class.


class Song
    attr_accessor :name, :album, :id

    def initialize (name, album, id=nil)
        @id = id
        @name = name
        @album = album
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS songs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                album TEXT
            )
            SQL
        DB[:conn].execute(sql)
    end
    # This approach still leaves a little to be desired, however. Here, we have to first create the new song and then save it, every time we want to create and save a song. 
    # This is repetitive and tedious. As programmers (you might remember), we are lazy. If we can accomplish something with fewer lines of code we do it. 
    # Any time we see the same code being used again and again, we think about abstracting that code into a method.
    # Since first creating an object and then saving a record representing that object is so common, let's write a method that does just that.
        
        # Song.create_table
        # hello = Song.new("Hello", "25")
        # ninety_nine_problems = Song.new("99 Problems", "The Black Album")
     
        # hello.save
        # ninety_nine_problems.save

            # ****The .create Method****
            # This method will wrap the code we used above to create a new Song instance and save it.
        
        
    def self.create(name, album)
        song = Song.new(name, album)
        somg.save
        song
    end
    # Here, we use keyword arguments to pass a name and album into our .create method. We use that name and album to instantiate a new song. 
    # Then, we use the #save method to persist that song to the database.
    # Notice that at the end of the method, we are returning the song instance that we instantiated. The return value of .create should always be the object that we created.
    
    def save
        sql = <<-SQL
            INSERT INTO songs (name, album)
            VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.album)
        # We want our hello instance to completely reflect the database row it is associated with so that we can retrieve it from the table later on with ease.
        # So, once the new row with hello's data is inserted into the table, let's grab the ID of that newly inserted row and assign it to be the value of hello's id attribute.
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]

    end
end
********************************************************************************************************************************************************************************
********************************************************************************************************************************************************************************

class Song
    attr_accessor :title, :length, :id

    def initialize (title, length, id=nil)
        @id = id
        @title = title
        @length = length
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS songs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                album TEXT
            )
            SQL
        DB[:conn].execute(sql)
    end

    def self.create(title, length)
        song = Song.new(title, length)
        somg.save
        song
    end

    def save
        sql = <<-SQL
            INSERT INTO songs (title, length)
            VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.title, self.length)

        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]

    end

# Imagine we already have a database with 1 million songs. We need to build three methods to access all of those songs and convert them to Ruby objects.

# ******.new_from_db******
# The first thing we need to do is convert what the database gives us into a Ruby object. We will use this method to create all the Ruby objects in our next two methods.
# The first thing to know is that the database, SQLite in our case, will return an array of data for each row. For example, a row for Michael Jackson's "Thriller" (356 seconds long) that has a db id of 1 would look like this: [1, "Thriller", 356].

    def self.new_from_db(row)
        new_song = self.new  # self.new is the same as running Song.new
        new_song.id = row[0]
        new_song.name =  row[1]
        new_song.length = row[2]
        new_song  # return the newly created instance
    end

    #******Song.all******
    # Now we can start writing our methods to retrieve the data. To return all the songs in the database we need to execute the following SQL query: SELECT * FROM songs.
    # Let's store that in a variable called sql using a heredoc (<<-) since our string will go onto multiple lines:
    
    def self.all
        sql = <<-SQL
            SELECT * FROM songs
         SQL
        DB[:conn].execute(sql).map do |row|
            self.new_from_db(row)
        end
        # ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        
        # This will return an array of rows from the database that matches our query. 
        # Now, all we have to do is iterate over each row and use the self.new_from_db method to create a new Ruby object for each row:
                
    end

    # Next, we will make a call to our database using DB[:conn]. This DB hash is located in the config/environment.rb file: DB = {:conn => SQLite3::Database.new("db/songs.db")}. 
    # Notice that the value of the hash is actually a new instance of the SQLite3::Database class. This is how we will connect to our database. 
    # Our database instance responds to a method called execute that accepts raw SQL as a string. Let's pass in that SQL we stored above:

    
# ****Song.find_by_name****
#     This one is similar to Song.all with the small exception being that we have to include a name in our SQL statement. 
#     To do this, we use a question mark where we want the name parameter to be passed in, and we include name as the second argument to the execute method:
#     Don't be freaked out by that .first method chained to the end of the DB[:conn].execute(sql, name).map block. 
#     The return value of the .map method is an array, and we're simply grabbing the .first element from the returned array. Chaining is cool!

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM songs
            WHERE name = ?
            LIMIT 1
        SQL
 
        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end





end

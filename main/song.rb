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
        song.save
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

********************************************************************************************************************************************************************************
********************************************************************************************************************************************************************************


# UPDATING RECORDS IN RUBY ORM

class Song
 
    attr_accessor :name, :album
    attr_reader :id
     
      def initialize(id=nil, name, album)
        @id = id
        @name = name
        @album = album
      end
     
      def self.create_table
        sql =  <<-SQL
          CREATE TABLE IF NOT EXISTS songs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            album TEXT
            )
            SQL
        DB[:conn].execute(sql)
      end
     
      def save
        sql = <<-SQL
          INSERT INTO songs (name, album)
          VALUES (?, ?)
        SQL
     
        DB[:conn].execute(sql, self.name, self.album)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]
      end
     
      def self.create(name:, album:)
        song = Song.new(name, album)
        song.save
        song
      end
     
      def self.find_by_name(name)
        sql = "SELECT * FROM songs WHERE name = ?"
        result = DB[:conn].execute(sql, name)[0]
        Song.new(result[0], result[1], result[2])
      end
    end

end
    # With the Song class as defined above, we can create new Song instances, 
    # save them to the database and retrieve them from the database:
    
    
    ninety_nine_problems = Song.create(name: "99 Problems", album: "The Blueprint")
 
    Song.find_by_name("99 Problems")
    => #<Song:0x007f94f2c28ee8 @id=1, @name="99 Problems", @album="The Blueprint">
    
    # Now that we've seen how to create a Song instance, save its attributes to the database, 
    # retrieve those attributes and use them to re-create a Song instance, let's move on to updating records and objects.

    
    Updating Songs
    In order to update a record, we must first find it:
    ninety_nine_problems = Song.find_by_name("99 Problems")
    ninety_nine_problems.album
    # => "The Blueprint"
    # Uh-oh, 99 Problems is off The Black Album, as we all know. Let's fix this.
    ninety_nine_problems.album = "The Black Album"
    ninety_nine_problems.album
    # => "The Black Album"
    Much better. Now we need to save this record back into the database:
    
    # To do so, we'll need to use an UPDATE SQL statement. That statement would look something like this:

        UPDATE songs
        SET album="The Black Album"
        WHERE name="99 Problems";
        
    # Let's put it all together using our SQLite3-Ruby gem magic. Remember, in this example, we assume our database connection is stored in DB[:conn].

        sql = "UPDATE songs SET album = ? WHERE name = ?"
        DB[:conn].execute(sql, ninety_nine_problems.album, ninety_nine_problems.name)
        

        Here we've updated the album of a given song. What happens when we want to update some other attribute of a song?

        Let's take a look:
         
        Song.create(name: "Hella", album: "25")
        # Let's correct the name of the above song from "Hella" to "Hello".
         
        hello = Song.find_by_name("Hella")
          
        sql = "UPDATE songs SET name='Hello' WHERE name = ?"
          
        DB[:conn].execute(sql, hello.name)

        # This code is almost exactly the same as the code we used to update the album of the first song. 
        # The only difference is in the particular attribute we wanted to update. In the first case, we were updating the album. In this case, we updated the name. 
        # Repetitious code has a smell. 
        # Let's extract this functionality of updating a record into a method, #update.

        <<<<<The "#update" Method>>>>>
    # How will we write a method that will allow us to update any attributes of any song? How will we know which attributes have been recently updated and which will remain the same?
    # The best way for us to do this is to simply update all the attributes whenever we update a record. That way, we will catch any changed attributes, while the un-changed ones will simply remain the same.

    For example:

    hello = Song.find_by_name("Hella")
 
    sql = "UPDATE songs SET name = 'Hello', album = ? WHERE name = ?"
        
    DB[:conn].execute(sql, hello.album, hello.name)

    # Here we update both the name and album attribute of the song, even though only the name attribute is actually different.

        def update
            sql = "Update songs SET name = ?, album = ? WHERE name = ?"
            DB[:conn].execute(sql, self.name, self.album, self.name)
        end

        # Now we can update a song with the following:

        hello = Song.create(name: "Hella", album: "25")
        hello.name = "Hello"
        hello.update

        def save
            if self.id    #<<<<<<<<<<Refactoring our #save Method to Avoid Duplication**************
                self.update
            else
                sql = <<-SQL
                INSERT INTO songs (name, album)
                VALUES (?, ?)
                SQL
         
                DB[:conn].execute(sql, self.name, self.album)
                @id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]
            end
        end

          <<<<<Using id to Update Records>>>>>
            # Our #update method should identify the correct record to update based on the unique ID that both the song Ruby object and the songs table row share:

        def update
            sql = "UPDATE songs SET name = ?, album = ? WHERE id = ?"
            DB[:conn].execute(sql, self.name, self.album, self.id)
        end

        # Now we will never have to worry about accidentally updating the wrong record, or being unable to find a record once we change its name.


    end



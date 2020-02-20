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

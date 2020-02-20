# Mapping-Ruby-Classes-to-Database-Tables

-In order to "map" this Song class to a songs database table, 
    we need to create our database, then we need to create our songs table. 
    In building an ORM, it is conventional to pluralize the name of the class to create the name of the table. 
    Therefore, the Song class equals the "songs" table.

--CREATING THE DATABASE--
    Before we can create a songs table we need to create our music database. 
    Whose responsibility is it to create the database? It is not the responsibility of our Song class. 
    Remember, classes are mapped to tables inside a database, not to the database as a whole. 
    We may want to build other classes that we equate with other database tables later on.

    It is the responsibility of our program as a whole to create and establish the database. 
    Accordingly, you'll see our Ruby programs set up such that they have a config directory that contains an environment.rb file.
    This file will look something like this:

-This object is created for us by the code provided by the SQLite-Ruby gem. 
    Don't worry too much about what is going on under the hood. 
    The important thing to understand is that this is the object that connects the rest of our Ruby program, i.e. any code we write to create artists, songs and genres, to our SQL database.

    Note: There are a number of methods available to us, that are provided by the SQLite-Ruby gem, 
    that we can call on the above object to execute commands against our database.

    Here, we also set up a constant, DB, that is equal to a hash that contains our connection to the database. 
    In our lib/song.rb file, we can therefore access the DB constant and the database connection it holds like this:
    DB[:conn]

    So, as we move through this reading, let's assume that our hypothetical program has a config/environment.rb file and that the DB[:conn] constant refers to our connection to the database.
    Now that our hypothetical database is set up in our hypothetical program, let's move on to our Song class and its equivalent database table.

--CREATING THE TABLE--
    According to the ORM convention in which a class is mapped to or equated with a database table, we need to create a songs table. 
    We will accomplish this by writing a class method in our Song class that creates this table.
    To "map" our class to a database table, we will create a table with the same name as our class and give that table column names that match the attr_accessors of our class.

-The id Attribute
    Notice that we are initializing an individual Song instance with an id attribute that has a default value of nil. 
    Why are we doing this? First of all, songs need an id attribute only because they will be saved into the database and we know that each table row needs an id value which is the primary key.

    When we create a new song with the Song.new method, we do not set that song's id. A song gets an id only when it gets saved into the database (more on inserting songs into the database later). 
    We therefore set the default value of the id argument that the #initialize method takes equal to nil, so that we can create new song instances that *do not have an id value. 
    We'll leave that up to the database to handle later on. Why leave it up to the database? Remember that in the world of relational database, the id of a given record must be unique. 
    If we could replicate a record's id, we would have a very disorganized database. Only the database itself, through the magic of SQL, can ensure that the id of each record is unique.

--THE .create_table METHOD--
    Above, we created a class method, .create_table, that crafts a SQL statement to create a songs table and give that table column names that match the attributes of an individual instance of Song. 
    Why is the .create_table method a class method? Well, it is not the responsibility of an individual song to create the table it will eventually be saved into. 
    It is the job of the class as a whole to create the table that it is mapped to.
-------------------------------------------------------------------------------------------------------------------------------------------------------
>>>>>Top-Tip: For strings that will take up multiple lines in your text editor, use a heredoc to create a string that runs on to multiple lines.<<<<  |
|   <<- + special word meaning "End of Document" + the string, on multiple lines + special word meaning "End of Document".                            |
|   You don't have to use a heredoc, it's just a helpful tool for crafting long strings in Ruby. Back to our regularly scheduled programming...       |
|   Now that our songs table exists, we can learn how to save data regarding individual songs into that table.                                        |
-------------------------------------------------------------------------------------------------------------------------------------------------------
require 'pry'

class Dog

    attr_accessor :name, :breed, :id

    #starts with these 3 attributes: id, name, breed
    def initialize(name:, breed:, id: nil)
        @id = id
        @name = name
        @breed = breed
    end

    #table gets created
    def self.create_table
            sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
          DROP TABLE dogs;
        SQL
    
        DB[:conn].execute(sql)
      end
    
    #given an instance of a dog, simply calling save will insert a new record into the database and return the instance.
    # def save
    #   #take into account of no values
    #   #if truthy, do nothing
    #   if self.id

    #   #otherwise, create net new row
    #   else 
    #   sql = <<-SQL
    #     INSERT INTO dogs (name, breed)
    #     VALUES (? , ?)
    #   SQL

    #   DB[:conn].execute(sql, self.name, self.breed)

    #   @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]


    #   # end 
      
    #   self
    # end 

    def save
      if self.id
        self.update
      else
        sql = <<-SQL
          INSERT INTO dogs (name, breed)
          VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      end
      self
    end

    def self.create(name:, breed:)
      dog = Dog.new(name: name, breed: breed)
      dog.save
    end

    def self.new_from_db(row)
      self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.all
      sql = <<-SQL
        SELECT *
        FROM dogs
      SQL

      DB[:conn].execute(sql).map do |doggo|
        self.new_from_db(doggo)
    end 
  end 

    def self.find_by_name(name)
      sql = <<-SQL
       SELECT *
       FROM dogs
       WHERE name = ?

      SQL

      DB[:conn].execute(sql, name).map do |row|
        self.new_from_db(row)
      end.first
    end 

    def self.find(id)
      sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
      SQL

      DB[:conn].execute(sql, id).map do |row|
        self.new_from_db(row)
      end.first

    end 
end

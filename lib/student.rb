require_relative "../config/environment.rb"
require 'pry'

# Remember, you can access your database connection anywhere in this class
#  with DB[:conn]
class Student
  attr_accessor :id, :name, :grade

  # attributes=》
  #     has a name and a grade
  #     has an id that defaults to `nil` on initialization
  def initialize(name, grade, id=nil)
      @id = id
      @name = name
      @grade = grade
  end

  # .create_table=>creates the students table in the database
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

#.create_table=>creates the students table in the DB
  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end


# #save
# updates a record if called on an object that is already persisted
  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]

    end
  end

#.create=>creates a student with two attributes, name and grade, and saves it into the students table.
  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

#  .new_from_db=>creates an instance with corresponding attribute values
  def self.new_from_db(row)
    # create a new Student object given a row from the database
    new_student = self.new(row[1], row[2], row[0])
    new_student.id = row[0]
    new_student.name = row[1]
    new_student.grade = row[2]
    new_student
  end

#  .find_by_name=>returns an instance of student that matches the name from the DB
  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

#update=>updates the record associated with a given instance
  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end

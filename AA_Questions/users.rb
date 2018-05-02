require_relative 'questions'
require_relative 'replies'
require_relative 'questionfollows'
require_relative 'questionlikes'

class Users

  attr_accessor :fname, :lname
  attr_reader :id


  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM users")
    data.map { |datum| Users.new(datum) }
  end

  def self.find_by_id(id)
    user = QuestionsDB.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    return nil if user.empty?

    Users.new(user.first)
  end

  def self.find_by_name(fname, lname)
    user = QuestionsDB.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    return nil if user.empty?

    Users.new(user.first)
  end

  def authored_questions
    Questions.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollows.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLikes.liked_questions_for_user_id(@id)
  end

  def average_karma
    karma = QuestionsDB.instance.execute(<<-SQL, @id)
      SELECT
        COUNT(*) / CAST(COUNT(DISTINCT questions.id) AS FLOAT)
      FROM
        questions
      LEFT OUTER JOIN
        question_likes
      ON
        questions.id = question_likes.questions_id
      WHERE
        questions.author_id = ?
    SQL

    karma.first.values.first
  end

  def create
    QuestionsDB.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO
        users (fname, lname)
      VALUES
        (?, ?)
    SQL
    @id = QuestionsDB.instance.last_insert_row_id
  end

  def update
    QuestionsDB.instance.execute(<<-SQL, @fname, @lname, @id)
      UPDATE
        plays
      SET
        fname = ?, lname = ?
      WHERE
        id = ?
    SQL
  end

  def save
    id ? self.update : self.create
  end
end

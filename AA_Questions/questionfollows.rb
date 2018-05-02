require_relative 'questions'
require_relative 'users.rb'

class QuestionFollows

  attr_accessor :users_id, :questions_id
  attr_reader :id


  def initialize(options)
    @id = options['id']
    @users_id = options['users_id']
    @questions_id = options['questions_id']
  end

  def self.find_by_id(id)
    follows = QuestionsDB.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = ?
    SQL
    return nil if follows.empty?

    QuestionFollows.new(follows.first)
  end

  def self.followers_for_question_id(questions_id)
    followers = QuestionsDB.instance.execute(<<-SQL, questions_id)
      SELECT
        users.id, users.fname, users.lname
      FROM
        question_follows
      JOIN
        users
      ON
        question_follows.users_id = users.id
      WHERE
        questions_id = ?
    SQL
    return nil if followers.empty?

    followers.map {|user| Users.new(user)}
  end

  def self.followed_questions_for_user_id(users_id)
    followers = QuestionsDB.instance.execute(<<-SQL, users_id)
      SELECT
        questions.id, questions.title, questions.body, questions.author_id
      FROM
        question_follows
      JOIN
        questions
      ON
        question_follows.questions_id = questions.id
      WHERE
        users_id = ?
    SQL
    return nil if followers.empty?

    followers.map {|question| Questions.new(question)}
  end

  def self.most_followed_questions(n)
    followers = QuestionsDB.instance.execute(<<-SQL, n)
      SELECT
        questions.id, questions.title, questions.body, questions.author_id
      FROM
        question_follows
      JOIN
        questions
      ON
        question_follows.questions_id = questions.id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(questions.id) DESC
      LIMIT
        ?
    SQL

    followers.map {|question| Questions.new(question)}
  end

  def save 

  end

end

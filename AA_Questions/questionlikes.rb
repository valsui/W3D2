require_relative 'questions'

class QuestionLikes

  attr_accessor :users_id, :questions_id
  attr_reader :id


  def initialize(options)
    @id = options['id']
    @users_id = options['users_id']
    @questions_id = options['questions_id']
  end

  def self.find_by_id(id)
    question = QuestionsDB.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        id = ?
    SQL
    return nil if question.empty?

    QuestionLikes.new(question.first)
  end

  def self.likers_for_question_id(questions_id)
    likers = QuestionsDB.instance.execute(<<-SQL, questions_id)
      SELECT
        users.id, users.fname, users.lname
      FROM
        question_likes
      JOIN
        users
      ON
        question_likes.users_id = users.id
      WHERE
        questions_id = ?
    SQL
    return nil if likers.empty?

    likers.map {|user| Users.new(user)}
  end

  def self.num_likes_for_question_id(questions_id)
    likers = QuestionsDB.instance.execute(<<-SQL, questions_id)
      SELECT
        COUNT(question_likes.questions_id)
      FROM
        question_likes
      JOIN
        users
      ON
        question_likes.users_id = users.id
      WHERE
        questions_id = ?
    SQL

    return likers.first.values.first
  end

  def self.liked_questions_for_user_id(users_id)
    questions = QuestionsDB.instance.execute(<<-SQL, users_id)
      SELECT
        questions.id, questions.title, questions.body, questions.author_id
      FROM
        question_likes
      JOIN
        questions
      ON
        question_likes.questions_id = questions.id
      WHERE
        users_id = ?
    SQL
    return nil if questions.empty?

    questions.map {|question| Questions.new(question)}
  end

  def self.most_liked_questions(n)
    most_liked = QuestionsDB.instance.execute(<<-SQL, n)
      SELECT
        questions.id, questions.title, questions.body, questions.author_id
      FROM
        question_likes
      JOIN
        questions
      ON
        question_likes.questions_id = questions.id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(questions.id) DESC
      LIMIT
        ?
    SQL

    return nil if most_liked.empty?

    most_liked.map { |liked| Questions.new(liked) }
  end

  def save

  end
end

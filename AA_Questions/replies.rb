require_relative 'questions'
require_relative 'users.rb'

class Reply

  attr_accessor :users_id, :questions_id, :body, :reply_id
  attr_reader :id


  def initialize(options)
    @id = options['id']
    @users_id = options['users_id']
    @questions_id = options['questions_id']
    @body = options['body']
    @reply_id = options['reply_id']
  end

  def self.find_by_user_id(users_id)
    reply = QuestionsDB.instance.execute(<<-SQL, users_id)
      SELECT
        *
      FROM
        replies
      WHERE
        users_id = ?
    SQL
    return nil if reply.empty?

    Reply.new(reply.first)
  end

  def self.find_by_question_id(question_id)
    reply = QuestionsDB.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    return nil if reply.empty?

    Reply.new(reply.first)
  end

  def self.find_by_id(id)
    reply = QuestionsDB.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    return nil if reply.empty?

    Reply.new(reply.first)
  end

  def author
    Users.find_by_id(@users_id)
  end

  def question
    Questions.find_by_id(@questions_id)
  end

  def parent_reply
    # return nil if @reply_id == 'NULL'
    reply = QuestionsDB.instance.execute(<<-SQL, @reply_id)
    SELECT
      *
    FROM
      replies
    WHERE
      id = ?
    SQL
    return nil if reply.empty?

    Reply.new(reply.first)
  end

  def child_replies
    child_reply = QuestionsDB.instance.execute(<<-SQL, @id)
    SELECT
      *
    FROM
      replies
    WHERE
      reply_id = ?
    SQL
    return nil if child_reply.empty?

    Reply.new(child_reply.first)
  end

  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM replies")
    data.map { |datum| Reply.new(datum) }
  end

  def save

  end
end

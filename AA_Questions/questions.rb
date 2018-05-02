require 'singleton'
require 'sqlite3'
require_relative 'users.rb'
require_relative 'replies.rb'
require_relative 'questionfollows'


class QuestionsDB < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end


class Questions

  attr_accessor :title, :body, :author_id
  attr_reader :id

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def self.find_by_author_id(author_id)
    question = QuestionsDB.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL
    return nil if question.empty?

    question.map { |q| Questions.new(q)}
  end

  def self.find_by_id(id)
    question = QuestionsDB.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    return nil if question.empty?

    Questions.new(question.first)
  end

  def author
    Users.find_by_id(@author_id)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM questions")
    data.map { |datum| Questions.new(datum) }
  end

  def followers
    QuestionFollows.followers_for_question_id(@id)
  end

  def self.most_followed(n)
    QuestionFollows.most_followed_questions(n)
  end

  def likers
    QuestionLikes.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLikes.num_likes_for_question_id(@id)
  end

  def self.most_liked(n)
    QuestionLikes.most_liked_questions(n)
  end

  def save

  end
end

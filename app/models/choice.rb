class Choice < ActiveRecord::Base
  belongs_to :poll
  has_many :replies
  acts_as_list :scope => :poll
  validates_presence_of :poll_id, :body

  def total
    read_attribute(:total) || self.replies.count
  end

  class << self
    def stats_by_poll(poll)
      find_by_sql ['SELECT c.*, COUNT(r.id) total
        FROM polls p INNER JOIN choices c ON c.poll_id = p.id
        LEFT OUTER JOIN replies r on c.id = r.choice_id
        WHERE p.id = ? GROUP BY c.id ORDER BY c.position', poll.id]
    end
  end
end

class Reply < ActiveRecord::Base
  belongs_to :poll
  belongs_to :user
  belongs_to :choice
  
  validates_uniqueness_of :poll_id, :scope => :user_id

  # piggy backing properties
  [:user_id, :user_login, :choice_id, :choice_body, :poll_id, :poll_title].each do |attr|
    instance_eval do
      "def #{attr}
        read_attribute('#{attr}') || self.#{attr.to_s.sub(/_/, '.')}
      end"
    end
  end
    
  class << self
    # uses piggy backing to stop dreaded (n*2) + 1 query issue!
    def find_recent(options = {})
      find_by_sql([create_piggybacked_query] + get_limit_and_offset(options))
    end
    
    def find_by_poll(poll, options = {})
      find_by_sql([create_piggybacked_query('p.id = ?'), poll.id] + get_limit_and_offset(options))
    end
    
    def find_by_user(user, options = {})
      find_by_sql([create_piggybacked_query('u.id = ?'), user.id] + get_limit_and_offset(options))
    end

    def find_by_friends_of(user, options = {})
      find_by_sql([create_piggybacked_query('u.id = ?', true), user.id] + get_limit_and_offset(options))
    end

    private
    def create_piggybacked_query(conditions = '', find_by_friend = false)
      user_join = find_by_friend ? "INNER JOIN users_friends uf ON uf.friend_id = r.user_id
        INNER JOIN users f ON f.id = uf.friend_id
        INNER JOIN users u ON u.id = uf.user_id" :
        "INNER JOIN users u ON u.id = r.user_id"
      user_prefix = find_by_friend ? 'f' : 'u'
      conditions = "WHERE #{conditions}" if conditions and conditions.to_s.length > 0
      "SELECT r.*, #{user_prefix}.id AS user_id, #{user_prefix}.login AS user_login, 
        c.id AS choice_id, c.body AS choice_body, p.id as poll_id, p.title as poll_title
        FROM polls p 
        INNER JOIN choices c ON p.id = c.poll_id 
        INNER JOIN replies r ON c.id = r.choice_id
        #{user_join} #{conditions}
        ORDER BY r.updated_at DESC
        LIMIT ? OFFSET ?"
    end
    
    def get_limit_and_offset(options)
      [(options[:limit] || 20), (options[:offset] || 0)]
    end
  end
  
  protected
  after_create :set_poll_replied_on_at
  def set_poll_replied_on_at
    poll.update_attribute(:replied_on_at,Time.now)
  end
  
  def validate
    self.errors.add_to_base('Choice was not found in this Poll.') unless self.choice.poll_id == self.poll.id
  end
end

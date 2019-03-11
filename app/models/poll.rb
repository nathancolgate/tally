class Poll < ActiveRecord::Base
  belongs_to :author, :class_name => "User", :foreign_key => "author_id"
  has_many :choices, :order => 'position'
  has_many :replies
  has_and_belongs_to_many :tags

  validates_presence_of :title

  class << self
    def find_first_user_has_not_taken(user)
      find(:first,:conditions => ["id not in (select poll_id from replies where user_id=?)",user.id])
    end
    
    def find_with_tags(*tags)
      options = {}
      options = tags.pop if tags.last.is_a?(Hash)
      tags = [tags].flatten.map {|tag| Tag.fix_tag(tag) }
      return [] if tags.empty?

      sql = "select p.*,u.id as author_id,u.login as author_login from polls p,tags t,polls_tags pt,users u where pt.poll_id=p.id and pt.tag_id=t.id and t.tag in (?) and p.author_id=u.id group by p.id having count(p.id)=?"
      sql << " order by #{options[:order]} " if options[:order]
      add_limit!(sql,options)

      find_by_sql([sql,tags,tags.length])
    end

    def find_by_author(author, options = {})
      limit = options[:limit] || 20
      offset = options[:offset] || 0
      find_by_sql [create_piggybacked_query('u.id = ?'), author.id, limit, offset]
    end
    
    def find_recent(options = {})
      limit = options[:limit] || 20
      offset = options[:offset] || 0
      find_by_sql [create_piggybacked_query('1=1'),limit,offset]
    end

    private
    def create_piggybacked_query(conditions)
      "SELECT p.*, u.id AS author_id, u.login AS author_login, 
        p.id as poll_id, p.title as poll_title
        FROM polls p 
        INNER JOIN users u   ON u.id = p.author_id
        WHERE #{conditions}
        ORDER BY p.updated_at DESC
        LIMIT ? OFFSET ?"
    end
  end
end

class Tag < ActiveRecord::Base
  has_and_belongs_to_many :polls
  
  validates_presence_of :tag
  validates_format_of :tag, :with => /^[\w]+$/

  class << self
    def fix_tag(tag)
      tag.downcase.gsub(/\W/,"")
    end
    
    def find_or_create(tag)
      find_by_tag(tag) || create(:tag => tag)
    end
    
    def find_by_tag(tag)
      find(:first,:conditions => ["tag=?",fix_tag(tag)])
    end
  end
  
  before_validation_on_create :fix_tag
  
  protected

  def fix_tag
    self.tag = self.class.fix_tag(tag)
  end
end

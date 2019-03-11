require File.dirname(__FILE__) + '/../test_helper'

# Set salt to 'change-me' because thats what the fixtures assume. 
User.salt = 'change-me'

class UserTest < Test::Unit::TestCase
  
  fixtures :users, :users_friends
    
  def test_auth
    assert_equal  @bob, User.authenticate("bob", "test")    
    assert_nil    User.authenticate("nonbob", "test")
  end
  
  def test_user_is_valid
    assert @rick.valid?
  end
  
  def test_set_password
    assert_equal  @bob, User.authenticate("bob", "test")  
    @bob.set_password('test2', 'test2')
    assert_equal  @bob, User.authenticate("bob", "test2")  
  end
  
  def test_types
    assert @rick.admin?
    assert @rick.visitor?
    assert !@dan.admin?
    assert @dan.visitor?
    assert !@longbob.admin?
    assert !@longbob.visitor?
    
    assert !Admin.new.admin?
    assert !Visitor.new.visitor?
  end

  def test_disallowed_passwords
    
    u = User.new    
    u.login = "nonbob"

    u.password = u.password_confirmation = "tiny"
    assert !u.save     
    assert u.errors.invalid?('password')

    u.password = u.password_confirmation = "hugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehuge"
    assert !u.save     
    assert u.errors.invalid?('password')
        
    u.password = u.password_confirmation = ""
    assert !u.save    
    assert u.errors.invalid?('password')
        
    u.password = u.password_confirmation = "bobs_secure_password"
    assert u.save     
    assert u.errors.empty?
        
  end
  
  def test_bad_logins

    u = User.new  
    u.password = u.password_confirmation = "bobs_secure_password"

    u.login = "x"
    assert !u.save     
    assert u.errors.invalid?('login')
    
    u.login = "hugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhug"
    assert !u.save     
    assert u.errors.invalid?('login')

    u.login = ""
    assert !u.save
    assert u.errors.invalid?('login')

    u.login = "okbob"
    assert u.save  
    assert u.errors.empty?
      
  end


  def test_collision
    u = User.new
    u.login      = "existingbob"
    u.password = u.password_confirmation = "bobs_secure_password"
    assert !u.save
  end


  def test_create
    u = User.new
    u.login      = "nonexistingbob"
    u.password = u.password_confirmation = "bobs_secure_password"
      
    assert u.save  
    
  end
  
  def test_sha1
    u = User.new
    u.login      = "nonexistingbob"
    u.password = u.password_confirmation = "bobs_secure_password"
    assert u.save
        
    assert_equal '98740ff87bade6d895010bceebbd9f718e7856bb', u.password    
  end

  def test_lower_login
    u = User.new(:login => "BIGBOB")
    assert !u.valid?
    assert_equal "bigbob", u.login
  end
end

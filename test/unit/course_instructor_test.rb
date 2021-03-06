require 'test_helper'

class CourseInstructorTest < ActiveSupport::TestCase
  
  def test_should_create_course_instructor
    assert_difference 'CourseInstructor.count' do
      a = create_record
      assert !a.new_record?, "#{a.errors.full_messages.to_sentence}"
    end
  end
  
  def test_should_require_course_and_person
    assert_no_difference 'CourseInstructor.count' do
      a = create_record(:course_id => 5)
      assert a.errors.on(:course)
      a = create_record(:person_id => 5)
      assert a.errors.on(:person)
    end
  end
  
  def test_should_require_valid_role
    assert_no_difference 'CourseInstructor.count' do
      a = create_record(:role => 'asst')
      assert a.errors.on(:role)
    end
  end
  
  def test_should_find_instructors
    assert_equal 4, Course.find(1).instructors.count
  end

  private
  
  def create_record(options = {})
    record = CourseInstructor.new({ :course_id => 2, :person_id => people(:janedoe).id,
                                    :role => 'main' }.merge(options))
    record.save
    record
  end
end

require 'spec_helper'

describe "UserPages" do

  subject { page }

  let(:have_blank_password_error) { have_specific_error_message "Password can't be blank" }
  let(:have_blank_name_error) { have_specific_error_message "Name can't be blank" }
  let(:have_long_name_error) { have_specific_error_message "Name is too long" }
  let(:have_blank_email_error) { have_specific_error_message "Email can't be blank" }
  let(:have_invalid_email_error) { have_specific_error_message "Email is invalid" }
  let(:have_short_password_error) { have_specific_error_message "Password is too short" }
  let(:have_blank_confirmation_error) { have_specific_error_message "Password confirmation can't be blank" }
  let(:have_mismatch_password_error) { have_specific_error_message "Password doesn't match confirmation" }

  shared_examples_for "all invalid signups" do
    it "should not create a user" do
      expect { click_button submit }.not_to change(User, :count)
    end
  end#shared invalid signups

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    let!(:m1) { FactoryGirl.create(:micropost, user: user, content: "Foo") }
    let!(:m2) { FactoryGirl.create(:micropost, user: user, content: "Bar") }

    before { visit user_path(user) }

    it { should have_selector('h1',    text: user.name) }
    it { should have_selector('title', text: user.name) }

    describe "microposts" do
      it { should have_content(m1.content) }
      it { should have_content(m2.content) }
      it { should have_content(user.microposts.count) }
    end#microposts

    describe "follow/unfollow buttons" do
      let(:other_user) { FactoryGirl.create(:user) }
      before { valid_signin user }

      describe "following a user" do
        before { visit user_path(other_user) }

        it "should increment the followed user count" do
          expect do
            click_button "Follow"
          end.to change(user.followed_users, :count).by(1)
        end

        it "should increment the other user's followers count" do
          expect do
            click_button "Follow"
          end.to change(other_user.followers, :count).by(1)
        end

        describe "toggling the button" do
          before { click_button "Follow" }
          it { should have_selector('input', value: 'Unfollow') }
        end
      end#following

      describe "unfollowing a user" do
        before do
          user.follow!(other_user)
          visit user_path(other_user)
        end

        it "should decrement the followed user count" do
          expect do
            click_button "Unfollow"
          end.to change(user.followed_users, :count).by(-1)
        end

        it "should decrement the other user's followers count" do
          expect do
            click_button "Unfollow"
          end.to change(other_user.followers, :count).by(-1)
        end

        describe "toggling the button" do
          before { click_button "Unfollow" }
          it { should have_selector('input', value: 'Follow') }
        end

      end#unfollowing

    end#follow unfollow buttons



  end#profile

  describe "signup" do

    before { visit signup_path }

    describe "page" do
      it { should have_selector('h1', text:'Sign up') }
      it { should have_selector('title', text:full_title('Sign up')) }
    end#page

    let(:submit) { "Create my account"}

    describe "with empty form submission" do
      it_should_behave_like "all invalid signups"
      describe "after submission" do
        before { click_button submit }
        it { should have_error_message '6' }
        it { should have_blank_password_error }
        it { should have_blank_name_error }
        it { should have_blank_email_error }
        it { should have_invalid_email_error }
        it { should have_short_password_error }
        it { should have_blank_confirmation_error }
      end
    end#with empty form

    describe "with blank name submission" do
      before { blank_name }
      it_should_behave_like "all invalid signups"
      describe "after submission" do
        before { click_button submit }
        it { should have_error_message "1"}
        it { should have_blank_name_error }
      end
    end#with no name

    describe "with blank email submission" do
      before { blank_email }
      it_should_behave_like "all invalid signups"
      describe "after submission" do
        before { click_button submit }
        it { should have_error_message "2" }
        it { should have_blank_email_error }
        it { should have_invalid_email_error }
      end
    end#with no email

    describe "with blank passwords submission" do
      before { blank_passwords }
      it_should_behave_like "all invalid signups"
      describe "after submission" do
        before { click_button submit }
        it { should have_error_message "3" }
        it { should have_blank_password_error }
        it { should have_short_password_error }
        it { should have_blank_confirmation_error }
      end
    end#with no password

    describe "with mismatched passwords submission" do
      before { password_mismatch }
      it_should_behave_like "all invalid signups"
      describe "after submission" do
        before { click_button submit }
        it { should have_error_message "1" }
        it { should have_mismatch_password_error }
      end
    end#with password doesn't match

    describe "with too short password submission" do
      before { short_password }
      it_should_behave_like "all invalid signups"
      describe "after submission" do
        before { click_button submit }
        it { should have_error_message "1" }
        it { should have_short_password_error }
      end
    end#with password too short


    describe "with valid information submission" do
      before { valid }
      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end
      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by_email('user@example.com') }
        it { should have_selector('title',text: user.name) }
        it { should have_selector('div.alert.alert-success', text:'Welcome') }
        it { should have_link('Sign out') }
      end
    end#with valid

  end#signup

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      valid_signin user
      visit edit_user_path(user)
    end

    describe "page" do
      it { should have_selector('h1',    text: "Update your profile") }
      it { should have_selector('title', text: "Edit user") }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end#page



    let(:submit) { "Save changes"}

    describe "with empty form" do
      before { blank_all }
      describe "after submission" do
        before { click_button submit }
        it { should have_error_message '5' }
        it { should have_blank_name_error }
        it { should have_blank_email_error }
        it { should have_invalid_email_error }
        it { should have_short_password_error }
        it { should have_blank_confirmation_error }
      end
    end#with empty form

    describe "with blank name" do
      before { blank_name }
      describe "after submission" do
        before { click_button submit }
        it { should have_error_message '1'}
        it { should have_blank_name_error }
      end
    end#with no name

    describe "with long name" do
      before { long_name }
      describe "after submission" do
        before { click_button submit }
        it { should have_error_message '1'}
        it { should have_long_name_error }
      end
    end#with long name

    describe "with blank email" do
      before { blank_email }
      describe "after submission" do
        before { click_button submit }
        it { should have_error_message '2' }
        it { should have_blank_email_error }
        it { should have_invalid_email_error }
      end
    end#with no email

    describe "with blank passwords" do
      before { blank_passwords }
      describe "after submission" do
        before { click_button submit }
        it { should have_error_message '2' }
        it { should have_short_password_error }
        it { should have_blank_confirmation_error }
      end
    end#with no password

    describe "with mismatched passwords" do
      before { password_mismatch }
      describe "after submission" do
        before { click_button submit }
        it { should have_error_message '1' }
        it { should have_mismatch_password_error }
      end
    end#with password doesn't match

    describe "with short passwords" do
      before { short_password }
      describe "after submission" do
        before { click_button submit }
        it { should have_error_message '1' }
        it { should have_short_password_error }
      end
    end#with short passwords

    describe "with valid information" do
      let(:new_name)  { "New Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name",             with: new_name
        fill_in "Email",            with: new_email
        fill_in "Password",         with: user.password
        fill_in "Confirmation",     with: user.password
        click_button submit
      end

      it { should have_selector('title', text: new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { user.reload.name.should  == new_name }
      specify { user.reload.email.should == new_email }
    end#valid information
  end#edit


  describe "index" do

    let(:user) { FactoryGirl.create(:user) }

    before do
      valid_signin user
      visit users_path
    end

    it { should have_selector('title', text: 'All users') }
    it { should have_selector('h1',    text: 'All users') }

    describe "pagination" do
      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all)  { User.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          page.should have_selector('li', text: user.name)
        end
      end#list each user
    end#pagination

    describe "delete links" do

      describe "as normal user" do
        it { should have_selector('title', text: 'All users') }
        it { should have_selector('h1',    text: 'All users') }
        it { should_not have_link('delete') }
      end

      describe "as admin user" do

        let (:admin) { FactoryGirl.create(:admin) }
        before do
          click_link 'Sign out'
          valid_signin ( admin )
          visit users_path
        end
        it { should have_link('delete', href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect { click_link('delete') }.to change(User, :count).by(-1)
        end

        it "should not be able to delete admin" do
          expect { delete user_path(admin) }.to_not change(User, :count).by(-1)
        end

        it { should_not have_link('delete', href: user_path(admin)) }
      end#admin user

    end#delete

  end#index




end#UserPages

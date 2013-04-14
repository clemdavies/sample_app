require 'spec_helper'

describe "UserPages" do

  subject { page }

  let(:have_blank_password_error) { have_specific_error_message "Password can't be blank" }
  let(:have_blank_name_error) { have_specific_error_message "Name can't be blank" }
  let(:have_blank_email_error) { have_specific_error_message "Email can't be blank" }
  let(:have_invalid_email_error) { have_specific_error_message "Email is invalid" }
  let(:have_short_password_error) { have_specific_error_message "Password is too short" }
  let(:have_blank_confirmation_error) { have_specific_error_message "Password confirmation can't be blank" }
  let(:have_mismatch_password_error) { have_specific_error_message "Password doesn't match confirmation" }

  shared_examples_for "all invalid signups" do
    it "should not create a user" do
      expect { click_button submit }.not_to change(User, :count)
    end
  end#shared invalid

  describe "signup page" do
    before { visit signup_path }

    it { should have_selector('h1', text:'Sign up') }
    it { should have_selector('title', text:full_title('Sign up')) }
  end#signup

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    it { should have_selector('h1',    text: user.name) }
    it { should have_selector('title', text: user.name) }
  end#profile

  describe "signup" do
    before { visit signup_path}
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
      end#after submission
    end#with empty form

    describe "with blank name submission" do
      before { blank_name_signup }
      it_should_behave_like "all invalid signups"
      describe "after submission" do
        before { click_button submit }
        it { should have_error_message '1'}
        it { should have_blank_name_error }
      end#after submission
    end#with no name

    describe "with blank email submission" do
      before { blank_email_signup}
      it_should_behave_like "all invalid signups"
      describe "after submission" do
        before { click_button submit }
        it { should have_error_message "2" }
        it { should have_blank_email_error }
        it { should have_invalid_email_error }
      end#after submission
    end#with no email

    describe "with blank passwords submission" do
      before { blank_passwords_signup }
      it_should_behave_like "all invalid signups"
      describe "after submission" do
        before { click_button submit }
        it { should have_error_message "3" }
        it { should have_blank_password_error }
        it { should have_short_password_error }
        it { should have_blank_confirmation_error }
      end#after submission
    end#with no password

    describe "with mismatched passwords submission" do
      before { password_mismatch_signup }
      it_should_behave_like "all invalid signups"
      describe "after submission" do
        before { click_button submit }
        it { should have_error_message "1" }
        it { should have_mismatch_password_error }
      end#after submission
    end#with password doesn't match

    describe "with too short password submission" do
      before { short_password_signup }
      it_should_behave_like "all invalid signups"
      describe "after submission" do
        before { click_button submit }
        it { should have_error_message "1" }
        it { should have_short_password_error }
      end#after submission
    end#with password too short


    describe "with valid information submission" do
      before { valid_signup }
      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end
      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by_email('user@example.com') }
        it { should have_selector('title',text: user.name) }
        it { should have_selector('div.alert.alert-success', text:'Welcome') }
        it { should have_link('Sign out') }
      end#after saving
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

    describe "with invalid information" do
      before { click_button "Save changes" }
      it { should have_content('error') }
    end#invalid

    describe "with valid information" do
      let(:new_name)  { "New Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name",             with: new_name
        fill_in "Email",            with: new_email
        fill_in "Password",         with: user.password
        fill_in "Confirm Password", with: user.password
        click_button "Save changes"
      end

      it { should have_selector('title', text: new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { user.reload.name.should  == new_name }
      specify { user.reload.email.should == new_email }
    end#valid
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

      it { should_not have_link('delete') }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          valid_signin admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect { click_link('delete') }.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(admin)) }
      end
    end#delete

  end#index




end#UserPages

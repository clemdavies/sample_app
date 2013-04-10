require 'spec_helper'

describe "UserPages" do

  subject { page }

  describe "signup page" do
    before { visit signup_path }

    it { should have_selector('h1', text:'Sign up') }
    it { should have_selector('title', text:full_title('Sign up')) }
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    it { should have_selector('h1',    text: user.name) }
    it { should have_selector('title', text: user.name) }
  end

  describe "signup" do
    before { visit signup_path}
    let(:submit) { "Create my account"}

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button submit }
        it { should have_selector('title', text:'Sign up') }
        it { should have_content('error') }
      end #after submission

    end #with invalid general

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button submit }
        it { should have_selector('title', text:'Sign up') }
        it { should have_content('error') }
        let(:error_count) { page.find 'div.alert-error' }
        it { error_count.should have_content "6" }
        let(:error_messages) { page.find 'div#error_explanation ul' }
        it { error_messages.should have_content "Password can't be blank" }
        it { error_messages.should have_content "Name can't be blank" }
        it { error_messages.should have_content "Email can't be blank" }
        it { error_messages.should have_content "Email is invalid" }
        it { error_messages.should have_content "Password is too short" }
        it { error_messages.should have_content "Password confirmation can't be blank" }
      end #after submission

    end #with invalid specific all errors

    describe "with invalid information" do
      before do
        #fill_in "Name",         with: "Example User"
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end

      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button submit }
        it { should have_selector('title', text:'Sign up') }
        it { should have_content('error') }
        let(:error_count) { page.find 'div.alert-error' }
        it { error_count.should have_content "1" }
        let(:error_messages) { page.find 'div#error_explanation ul' }
        it { error_messages.should have_content "Name can't be blank" }
      end #after submission

    end #with invalid specific no name

    describe "with invalid information" do
      before do
        fill_in "Name",         with: "Example User"
        #fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end

      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button submit }
        it { should have_selector('title', text:'Sign up') }
        it { should have_content('error') }
        let(:error_count) { page.find 'div.alert-error' }
        it { error_count.should have_content "2" }
        let(:error_messages) { page.find 'div#error_explanation ul' }
        it { error_messages.should have_content "Email can't be blank" }
        it { error_messages.should have_content "Email is invalid" }
      end #after submission

    end #with invalid specific no email

    describe "with invalid information" do
      before do
        fill_in "Name",         with: "Example User"
        fill_in "Email",        with: "user@example.com"
        #fill_in "Password",     with: "foobar"
        #fill_in "Confirmation", with: "foobar"
      end

      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button submit }
        it { should have_selector('title', text:'Sign up') }
        it { should have_content('error') }
        let(:error_count) { page.find 'div.alert-error' }
        it { error_count.should have_content "3" }
        let(:error_messages) { page.find 'div#error_explanation ul' }
        it { error_messages.should have_content "Password can't be blank" }
        it { error_messages.should have_content "Password is too short" }
        it { error_messages.should have_content "Password confirmation can't be blank" }
      end #after submission

    end #with invalid specific no password

    describe "with invalid information" do
      before do
        fill_in "Name",         with: "Example User"
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirmation", with: "raboof"
      end

      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button submit }
        it { should have_selector('title', text:'Sign up') }
        it { should have_content('error') }
        let(:error_count) { page.find 'div.alert-error' }
        it { error_count.should have_content "1" }
        let(:error_messages) { page.find 'div#error_explanation ul' }
        it { error_messages.should have_content "Password doesn't match confirmation" }
      end #after submission

    end #with invalid specific password doesn't match

    describe "with invalid information" do
      before do
        fill_in "Name",         with: "Example User"
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foo"
        fill_in "Confirmation", with: "foo"
      end

      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button submit }
        it { should have_selector('title', text:'Sign up') }
        it { should have_content('error') }
        let(:error_count) { page.find 'div.alert-error' }
        it { error_count.should have_content "1" }
        let(:error_messages) { page.find 'div#error_explanation ul' }
        it { error_messages.should have_content "Password is too short" }
      end #after submission

    end #with invalid specific password too short


    describe "with valid information" do
      before do
        fill_in "Name",         with: "Example User"
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by_email('user@example.com') }
        it { should have_selector('title',text: user.name) }
        it { should have_selector('div.alert.alert-success', text:'Welcome') }
        it { should have_link('Sign out') }
      end #after saving

    end #with valid

  end #signup

end #UserPages

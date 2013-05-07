require 'spec_helper'

describe "AuthenticationPages" do

  subject { page }


  describe "signin" do
    before { visit signin_path }
    describe "page" do
      it { should have_selector('h1',    text: 'Sign in') }
      it { should have_selector('title', text: 'Sign in') }
    end#page

    describe "with invalid information" do
      before { click_button "Sign in" }

      it { should have_selector('title', text: 'Sign in') }
      it { should have_error_message 'Invalid' }

      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_error_message 'Invalid' }
      end

    end#invalid

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before { valid_signin(user) }

      it { should have_selector('title', text: user.name) }
      it { should have_link('Profile', href: user_path(user)) }

      it { should have_link('Users',    href: users_path) }
      it { should have_link('Settings', href: edit_user_path(user)) }

      it { should have_link('Sign out', href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }

      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link('Sign in') }
      end#signout

    end#valid

  end#signin


  describe "authorization" do

    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "the header links" do
        before { visit root_path }
        it { should have_link('Home') }
        it { should have_link('Help') }
        it { should have_link('Sign in') }
        it { should_not have_link('Settings') }
        it { should_not have_link('Profile') }
        it { should_not have_link('Sign out') }
        it { should_not have_link('Users') }
      end


      describe "in the Users controller" do

        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_selector('title', text: 'Sign in') }
        end

        describe "submitting to the update action" do
          before { put user_path(user) }
          specify { response.should redirect_to(signin_path) }
        end

        describe "visiting the user index" do
          before { visit users_path }
          it { should have_selector('title', text: 'Sign in') }
        end

        describe "visiting the following page" do
          before { visit following_user_path(user) }
          it { should have_selector('title', text: 'Sign in') }
        end

        describe "visiting the followers page" do
          before { visit followers_user_path(user) }
          it { should have_selector('title', text: 'Sign in') }
        end

      end#Users controller

      describe "in the Microposts controller" do

        describe "submitting to the create action" do
          before { post microposts_path }
          specify { response.should redirect_to(signin_path) }
        end

        describe "submitting to the destroy action" do
          before { delete micropost_path(FactoryGirl.create(:micropost)) }
          specify { response.should redirect_to(signin_path) }
        end
      end#Microposts controller

      describe "in the Relationships controller" do
        describe "submitting to the create action" do
          before { post relationships_path }
          specify { response.should redirect_to(signin_path) }
        end

        describe "submitting to the destroy action" do
          before { delete relationship_path(1) }
          specify { response.should redirect_to(signin_path) }
        end
      end#Relationships controller


      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          fill_in "Email",    with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        describe "after signing in" do

          it "should render the desired protected page" do
            page.should have_selector('title', text: 'Edit user')
          end

          describe "when signing in again" do
            before do
              click_link 'Sign out'
              valid_signin user
            end

            it "should render the default (profile) page" do
              page.should have_selector('title', text: user.name)
            end
          end#signing in again

        end#after signing in
      end#attempt visit protected
    end#non-signed-in

    describe "for signed in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "attempting to visit" do

        describe"sign in page" do
         before do
           valid_signin user
           get signin_path
         end
         specify { should redirect_to(root_path) }
        end
        describe"sign up page" do
         before do
           valid_signin user
           get signup_path
         end
         specify { should redirect_to(root_path) }
        end

      end#attempting visit

      describe "when attempting to post to sign up page" do
        before do
          valid_signin user
          post signup_path
        end
         specify { should redirect_to(root_path) }
      end#attempt post sign up

      describe "when attempting to destroy session" do
        before do
          valid_signin user
          delete signout_path
        end
         specify { should redirect_to(root_path) }
      end#attempt destroy session

    end#signed in users



    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { valid_signin user }

      describe "visiting Users#edit page" do
        before { visit edit_user_path(wrong_user) }
        it { should_not have_selector('title', text: full_title('Edit user')) }
      end#visit edit

      describe "submitting a PUT request to the Users#update action" do
        before { put user_path(wrong_user) }
        specify { response.should redirect_to(root_path) }

      end#put update

    end#wrong user


    describe "as non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before { valid_signin non_admin }

      describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(user) }
        specify { response.should redirect_to(root_path) }
      end
    end#non-admin


  end#authorization


  describe "following/followers" do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    before { user.follow!(other_user) }

    describe "followed users" do
      before do
        valid_signin user
        visit following_user_path(user)
      end

      it { should have_selector('title', text: full_title('Following')) }
      it { should have_selector('h3', text: 'Following') }
      it { should have_link(other_user.name, href: user_path(other_user)) }
    end#followed

    describe "followers" do
      before do
        valid_signin other_user
        visit followers_user_path(other_user)
      end

      it { should have_selector('title', text: full_title('Followers')) }
      it { should have_selector('h3', text: 'Followers') }
      it { should have_link(user.name, href: user_path(user)) }
    end#followers

  end#following/followers
end

require 'spec_helper'

feature "Homepage" do
  scenario "user can see homepage with register button" do
    visit "/"

    expect(page).to have_button("Register")

    click_button("Register")

    expect(page).to have_content("username", "password")

    fill_in("username", :with => "Ian")
    fill_in("password", :with => "123")

    click_button("Submit")


    expect(page).to have_content("Thank you for registering")

    visit "/"

    expect(page).to_not have_content("Thank you for registering")

    fill_in("username", :with => "Ian")
    fill_in("password", :with => "123")

    click_button("Login")

    expect(page).to have_content("Welcome, Ian!")

    expect(page).to_not have_button("Register", "Login")
    expect(page).to have_button("Logout")

    click_button("Logout")
    expect(page).to have_button("Register", "Login")
    expect(page).to_not have_content("Welcome, Ian!")

    click_button("Register")

    fill_in("username", :with => "Bob")
    click_button("Submit")

    expect(page).to have_content("Password is required")

    fill_in("password", :with => "whatever")

    click_button("Submit")
    expect(page).to have_content("Username is required")

    click_button("Submit")
    expect(page).to have_content("Username and password are required")

  end

  feature "Registration" do
    scenario "User cannot register with existing username" do


      visit "/register"

      fill_in("username", :with => "Ian")
      fill_in("password", :with => "kdkekfijef")

      click_button("Submit")
      expect(page).to have_content("Username already exists")

    end
  end

  feature "Homepage shows user list" do
    scenario "user logs in, sees user list" do

    end
  end
end

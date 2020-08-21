# README

# Setup project:
* Using docker:
  - run docker-compose up

* Setup manually:
  - Environments:
    - Ruby 2.5.1p57
    - Rails 5.2.1
    - bunlder 1.16.6
  - Update database config in config/database.yml
  - Commands:
    - bundle install
    - rake db:create
    - rake db:migrate
    - rake db:seed
    - rails s -p 3001

# Testing
  * using Rspec
    - rspec spec
  * Manually
    - go to http://localhost:3001/ to register new device
    - login with this user:
      - email: first_member@proda.com
      - password: empty
    - request to activate device (put to /piaweb/api/b2b/v1/devices/:device_name/jwk)
    - request to authentication api to get access token (post to /mga/sps/oauth/oauth20/token)
    - request to refresh api to update public key before it's expired (put to /piaweb/api/b2b/v1/orgs/:org_id/devices/device_name/jwk)
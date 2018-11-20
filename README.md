# Repairs management

## Getting started

Ensure that you have [Docker](https://www.docker.com/community-edition#/download) and [Docker Compose](https://docs.docker.com/compose/install/). Then run `./bin/setup`.

The following commands are available:

| Command        | Description |
| -------------- | ----------- |
| `./bin/setup`  | First-time project setup |
| `./bin/start`  | Run the Rails application at [localhost:3000](http://localhost:3000/) |
| `./bin/update` | Update gems, migrations and other dependencies |
| `./bin/migrate`| Run migrations |
| `./bin/test`   | Run RSpec |
| `./bin/test -f d path/to/file` | Run RSpec with options and files/directories |
| `rspec --tag ~db_connection`   | Run tests that aren't reliant on neo4j/postgres |

## Tips and Tricks for Docker

To get the server running, type `docker-compose up`.

To get a console running in Docker, first run `docker-compose up` and then in a separate terminal run `docker-compose run rails_app bash`.

To be able to use `binding.pry`, you'll need to run `docker-compose run -p 3000:3000 rails_app bash` and then `bundle exec rails s`.

When Docker starts going weird, stop the server, run `docker-compose down` and then start it up again. You might need to remove something in the `tmp` folder, but Docker will tell you about that.

## Environment variables

Create a `.env` file and update it as needed using the `.env.test` as a template.

## Rails credentials

To run the app locally, you’ll need to have the Rails master key set in the app directory. Copy the password from the Hackney folder in Unboxed’s 1Password and save it to a `master.key` file in the config directory.

## Testing

Test are configured two ways: (1) `./bin/test` will run all tests in Docker Compose, you should use this for a full test suite. (2) Some tests can be ran without Docker Compose, this is faster to run without Docker Compose, but it only covers a subset.

## Deployments

App is hosted on Unboxed's Heroku: [hackney-repairs pipeline](https://dashboard.heroku.com/pipelines/9820fae2-6834-4969-a4d6-774d00af55f1)

## GOV.UK Frontend

[https://github.com/alphagov/govuk-frontend](https://github.com/alphagov/govuk-frontend)

## Neo4j
The neo4j web interface is on http://localhost:7474 . Password should be `neo4j`

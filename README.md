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

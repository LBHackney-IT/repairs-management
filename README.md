# Repairs management

## Getting started

Ensure that you have [Docker](https://www.docker.com/community-edition#/download) and [Docker Compose](https://docs.docker.com/compose/install/). Then run `./bin/setup`.

To start the application, use `./bin/start`.

You'll need to create the database manually the first time you start. After running start, open another terminal and run the following:

```
docker-compose run rails_app bin/rails db:create db:migrate
```

## Deployments

App is hosted on Unboxed's Heroku: [hackney-repairs pipeline](https://dashboard.heroku.com/pipelines/9820fae2-6834-4969-a4d6-774d00af55f1)

## GOV.UK Frontend

[https://github.com/alphagov/govuk-frontend](https://github.com/alphagov/govuk-frontend)

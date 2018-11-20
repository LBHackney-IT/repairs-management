# Documentation

## Related repairs

To test with mocking the related repairs data, you will firstly need to run a docker container `docker-compose up` and then run a `rails console` within a `docker-compose run rails_app bash` in a seperate terminal.

This is the method you must run in the console to mock data relating job repairs with one another:

```ruby
def cite(references)
  pairs = references.zip(references.drop 1)
  pairs.each do |(r1, r2)|
    next unless r1 && r2
    from = Graph::WorkOrder.find_by(reference: r1) || Graph::WorkOrder.create!(reference: r1, created: Time.current, property_reference: '0', source: 'console')
    to = Graph::WorkOrder.find_by(reference: r2) || Graph::WorkOrder.create!(reference: r2, created: Time.current, property_reference: '0', source: 'console')
    Graph::Citation.create!(from_node: from, to_node: to, extra: from.related.include?(to), source: 'console')
  end
end

cite(['00118196', '00118197', '00118198',
     '00118199', '00118200', '00118201',
     '00118202', '00118203', '00118204',
     '00118205'])
```

Using job reference number "00118196" you should now be able to test related repairs locally compared to what should be the same as on https://hackney-repairs-staging.herokuapp.com/work_orders/00118196

## Performance monitoring - AppSignal

There is integration with AppSignal https://appsignal.com/ with the different environments. You will need the API key for this set inside your `.env` file e.g. `APPSIGNAL_PUSH_API_KEY=xxxxxxx` to test locally on your development environment

# geo_tasks

## Environment variables examples

Development:

```
RACK_ENV=development

MONGODB_URI=mongodb://localhost:27017/gt
```

Test:

```
MONGODB_TEST_URI=mongodb://localhost:27017/gt_test
```

## Rake-tasks

`db:create_indexes` - create MongoDB indexes

`db:seed` - create drivers and managers

`console` - run Pry

## Requests

```
curl -i -H "Accept: application/json" -H "Authorization: Bearer {{manager token}}" -X POST -d '{"pickup_point":{"lat":"44.106667","lng":"-73.935833"},"delivery_point":{"lat":"44.106668","lng":"-73.935834"}}' http://{{host}}:3000/tasks
curl -i -H "Accept: application/json" -H "Authorization: Bearer {{driver token}}" "http://{{host}}:3000/tasks?lat=44.106667&lng=-73.935833"
curl -i -H "Accept: application/json" -H "Authorization: Bearer {{driver token}}" -X PUT http://{{host}}:3000/tasks/584e9f9f558da50006f0e151/assign
curl -i -H "Accept: application/json" -H "Authorization: Bearer {{driver token}}" -X PUT http://{{host}}:3000/tasks/584e9f9f558da50006f0e151/finish
```

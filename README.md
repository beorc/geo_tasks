# geo-tasks
Geo based tasks tracker

Build a sinatra API to work with geo-based tasks. Use ruby 2.3 and mongoDB (recommended). All API endpoints should work with json body (not form-data). The result should be available as github repo with commit history and the code covered by specs. Please commit the significant step to git, we want to see how you evolved the code.

Each request will be **authorized by token**. You can use pre-defined tokens stored on backend side. Operate with tokens for two types of users:

1. Manager
2. Driver

Create tokens for more drivers and managers, not just 1-1.

Each task can be in 3 states

1. New (when the task is created)
2. Assigned (when a driver picks the task)
3. Done (when the driver marked the task as completed)

### Access

* Manager can create tasks with two geo locations pickup and delivery
* Driver can get list of tasks nearby (sorted by distance) by sending his current location 
* Driver can change status of task (to assigned/done). 
* Drivers can't create/delete tasks. 
* Managers can't change task status.

### Workflow:

1. Manager create task with location [lat1, long1]
2. Driver gets the list of the nearest tasks by submitting current location [lat2, long2]
3. Driver picks one task from the list (the task becomes assigned)
4. Driver finishes the task (becomes done)

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

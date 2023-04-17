
Trigger via change data capture?
- [ ] add a service to fact-service to post to a topic in a separate branch.
- [ ] sent all facts as the update message
- [ ] use profile service to receive messages and update the profile with extras like photos etc.
- [ ] This  demonstrates a java sending and go receiving
- []

## TODO

- [ ] allow fact service / pubsub to invoke cloud run service

https://cloud.google.com/blog/products/databases/you-can-now-use-cdc-from-cloudsql-for-postgresql

Demonstrate how to use service-to-service communication to retrieve data.

## Add to chapter
 - [ ] Differences in firestore and datastore mode: https://cloud.google.com/datastore/docs/firestore-or-datastore

Tests

```shell
curl -X POST http://localhost:8080/factschanged -H "Content-Type: application/json" -d '{
  "user": "v9qeph7MLBf5EgFYlUCKMTYwQ6i1",
  "facts": [
    {"skill": "Go", "level": "using"},
    {"skill": "Python", "level": "used"}
  ]
}'
```

```shell
curl -X GET "http://localhost:8080/profile?user=testuser"
```

```shell
curl -X POST http://localhost:8080/factschanged -H "Content-Type: application/json" -d '{
  "data": "eyJ1c2VyIjoidGVzdHVzZXIiLCJmYWN0cyI6W3siaWQiOjEsInRpbWVzdGFtcCI6IjIwMjMtMDQtMTVUMDk6MzA6MjIuMzQ2WiIsInVzZXIiOiJ0ZXN0dXNlciIsImxldmVsIjoidXNpbmciLCJza2lsbCI6IkdvIn0seyJpZCI6MiwidGltZXN0YW1wIjoiMjAyMy0wNC0xNVQwOTozMjoyMi4zNDZaIiwidXNlciI6InRlc3R1c2VyIiwibGV2ZWwiOiJ1c2VkIiwic2tpbGwiOiJQeXRob24ifV19"
}'
```

```shell
curl -X POST http://localhost:8080/factschanged -H "Content-Type: application/json" -d '{
  "data": "eyJ1c2VyIjoidjlxZXBpajdNTGJmNWVnRllsVUNLTVRTWXd6NmkxIiwiZmFjdHMiOlt7ImlkIjoxLCJ0aW1lc3RhbXAiOiIyMDIzLTA0LTE1VDA5OjMwOjIyLjM0NloiLCJ1c2VyIjoidjlxZXBpajdNTGJmNWVnRllcclVDL01UU1l3NmkxIiwibGV2ZWwiOiJ1c2luZyIsImNvbGxlY3Rpb24iOiJHaSJ9XX0="
}'
```

```json

"2023/04/16 20:34:55 body: {"deliveryAttempt":86,"message":{"attributes":{"replyChannel":"nullChannel"},"data":"eyJ1c2VyIjoidjlxZXBoN01MQmY1RWdGWWxVQ0tNVFl3UTZpMSIsImZhY3RzIjpbeyJpZCI6MSwidGltZXN0YW1wIjoiMjAyMy0wNC0xNlQyMDowNToxOS4xMTc4MDVaIiwidXNlciI6InY5cWVwaDdNTEJmNUVnRllsVUNLTVRZd1E2aTEiLCJsZXZlbCI6ImxlYXJuaW5nIiwic2tpbGwiOiJqYXZhIn0seyJpZCI6MiwidGltZXN0YW1wIjoiMjAyMy0wNC0xNlQyMDoxNjozNC42NzczMzRaIiwidXNlciI6InY5cWVwaDdNTEJmNUVnRllsVUNLTVRZd1E2aTEiLCJsZXZlbCI6ImxlYXJuaW5nIiwic2tpbGwiOiJqYXZhIn0seyJpZCI6MywidGltZXN0YW1wIjoiMjAyMy0wNC0xNlQyMDoyMTowMi43MTYyOFoiLCJ1c2VyIjoidjlxZXBoN01MQmY1RWdGWWxVQ0tNVFl3UTZpMSIsImxldmVsIjoibGVhcm5pbmciLCJza2lsbCI6ImphdmEifSx7ImlkIjo0LCJ0aW1lc3RhbXAiOiIyMDIzLTA0LTE2VDIwOjM0OjE1Ljg0Njg2MloiLCJ1c2VyIjoidjlxZXBoN01MQmY1RWdGWWxVQ0tNVFl3UTZpMSIsImxldmVsIjoibGVhcm5pbmciLCJza2lsbCI6ImphdmEifV0sInRpbWVzdGFtcCI6IjIwMjMtMDQtMTZUMjA6MzQ6MTUuODYyOTAxWiJ9","messageId":"7444674563021802","message_id":"7444674563021802","publishTime":"2023-04-16T20:34:15.968Z","publish_time":"2023-04-16T20:34:15.968Z"},"subscription":"projects/skillsmapper-org/subscriptions/fact_changed_subscription"}"
```

```json
{
  "user": "v9qeph7MLBf5EgFYlUCKMTYwQ6i1",
  "facts": [
    {
      "id": 1,
      "timestamp": "2023-04-16T20:05:19.117805Z",
      "user": "v9qeph7MLBf5EgFYlUCKMTYwQ6i1",
      "level": "learning",
      "skill": "java"
    },
    {
      "id": 2,
      "timestamp": "2023-04-16T20:16:34.677334Z",
      "user": "v9qeph7MLBf5EgFYlUCKMTYwQ6i1",
      "level": "learning",
      "skill": "java"
    },
    {
      "id": 3,
      "timestamp": "2023-04-16T20:21:02.71628Z",
      "user": "v9qeph7MLBf5EgFYlUCKMTYwQ6i1",
      "level": "learning",
      "skill": "java"
    },
    {
      "id": 4,
      "timestamp": "2023-04-16T20:34:15.846862Z",
      "user": "v9qeph7MLBf5EgFYlUCKMTYwQ6i"
    }
    ]}
}
      ```
      
```shell
curl -X POST http://localhost:8080/factschanged \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "attributes": {
        "replyChannel": "nullChannel"
      },
      "data": "eyJ1c2VyIjoidjlxZXBoN01MQmY1RWdGWWxVQ0tNVFl3UTZpMSIsImZhY3RzIjpbeyJpZCI6MSwidGltZXN0YW1wIjoiMjAyMy0wNC0xNlQyMDowNToxOS4xMTc4MDVaIiwidXNlciI6InY5cWVwaDdNTEJmNUVnRllsVUNLTVRZd1E2aTEiLCJsZXZlbCI6ImxlYXJuaW5nIiwic2tpbGwiOiJqYXZhIn1dLCJ0aW1lc3RhbXAiOiIyMDIzLTA0LTE2VDIwOjM0OjE1Ljg2MjkwMVoifQ==",
      "messageId": "7444674563021802",
      "publishTime": "2023-04-16T20:34:15.968Z"
    },
    "subscription": "projects/skillsmapper-org/subscriptions/fact_changed_subscription"
  }'
```

# broadcast-demo
Broadcast service that can be connected via websocket different number of users. 
All users who are connected will receive a random message from the list of messages. 
When a new message is added to the database, it will be received by all connected.

## Build & Run
Download the sources from the repository and run the service in the docker container.

*Before starting, make sure you have free ports 8080 and 5432*
```
git clone https://github.com/pshvedko/broadcast.git
cd broadcast
docker-compose up
```

## Client
Open http://localhost:8080 in browser

## Messages
Add records to the database using a connection
```
psql postgres://admin:admin@localhost/broadcast
```
Insert rows into table
```
insert into messages values ('some text there');
```

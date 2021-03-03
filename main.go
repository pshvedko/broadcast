package main

import (
	"context"
	"log"
	"net/http"
	"strings"
	"sync"
	"time"

	"github.com/gorilla/websocket"
	"github.com/jackc/pgx"
)

const html = `<!DOCTYPE html>
<html lang="en">
<head>
	<title>Messages</title>
	<meta charset="UTF-8">
</head>
<body>
<script>
	window.onload = function () {
		let messages = document.getElementById('messages')
		let socket = new WebSocket(location.origin.replace(/^http/, 'ws'))
		socket.onmessage = function (e) {
			messages.innerHTML += '<p>' + e.data + '</p>'
		}
	}
</script>
<div id="messages"></div>
</body>
</html>
`

func main() {

	db := make(chan *pgx.Conn, 10)

	for i := 0; i < 10; i++ {
		c, err := pgx.Connect(pgx.ConnConfig{
			Database: "broadcast",
			Host:     "postgres",
			User:     "admin",
			Password: "admin",
		})
		if err != nil {
			log.Fatal(err)
		}
		db <- c
	}

	b := map[*websocket.Conn]func(string){}
	m := sync.Mutex{}

	go func(c *pgx.Conn) {
		err := c.Listen("foo")
		if err != nil {
			log.Fatal(err)
		}
		for true {
			n, err := c.WaitForNotification(context.TODO())
			if err != nil {
				log.Fatal(err)
			}
			m.Lock()
			for _, f := range b {
				go f(n.Payload)
			}
			m.Unlock()
		}
	}(<-db)

	u := websocket.Upgrader{}
	t := time.Now()

	err := http.ListenAndServe(":8080", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if !strings.EqualFold(r.Header.Get("Connection"), "Upgrade") {
			http.ServeContent(w, r, "index.html", t, strings.NewReader(html))
		} else if !strings.EqualFold(r.Header.Get("Upgrade"), "Websocket") {
			http.NotFound(w, r)
		} else {
			c, err := u.Upgrade(w, r, http.Header{})
			if err != nil {
				return
			}

			q := make(chan bool, 1)
			q <- true

			defer func() {
				<-q
				close(q)
			}()

			var h string

			a := <-db
			a.QueryRow("select content from messages order by random() limit 1").Scan(&h)
			db <- a

			m.Lock()
			b[c] = func(s string) {
				if <-q {
					c.WriteMessage(websocket.TextMessage, []byte(s))
					q <- true
				}
			}
			b[c](h)
			m.Unlock()

			for true {
				_, _, err := c.ReadMessage()
				if err != nil {
					break
				}
			}

			m.Lock()
			delete(b, c)
			m.Unlock()
		}
	}))
	if err != nil {
		log.Fatal(err)
	}
}

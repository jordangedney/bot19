(import socket)
(import string)
(import hy.importer)

(setv HOST "irc.freenode.net")
(setv PORT "irc.freenode.net")
(setv PORT 6667)
(setv NICK "Bot19")
(setv IDENT "Testiee")
(setv REALNAME "Testertonn")
(setv readbuffer "")

(setv s (socket.socket))
(s.connect (, HOST PORT))
(s.send (% "NICK %s\r\n" NICK))
(s.send (% "USER %s %s bla :%s\r\n" (, IDENT HOST REALNAME)))
(s.send "JOIN #test-room\r\n")
(s.send (% "PRIVMSG #test-room :%s" "I am Bot 19\r\n"))

(defn get_expression [line]
    (setv start_index (+ (line.index ":Bot19:") 8))
    (setv end_index (len line))
    (setv indicies (range start_index end_index))
    (setv expr "")
    (for [each indicies]
        (setv expr (+ expr (get line each)))
    )
    expr
)

(defn eval_statement [line]
    (setv expr (get_expression line))
    (setv response (eval 
                    (first 
                    (hy.importer.import_buffer_to_hst expr))))
    (setv response (str response))
    (s.send (% "PRIVMSG #test-room :%s" (+ response "\r\n")))
)

(while True 
    (setv readbuffer (+ readbuffer (s.recv 1024)))
    (setv temp (string.split readbuffer "\n"))
    (setv readbuffer (temp.pop))


    (for [line temp]
        (print line)

        (if (in ":Bot19:" line)
            (eval_statement line)
        )

        (setv line (string.rstrip line))
        (setv line (string.split line))
        (if (= (first line) "PING")
            (s.send (% "PONG %s\r\n" line[1])))
    )
)

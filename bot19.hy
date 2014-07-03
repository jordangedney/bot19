(import socket)
(import string)
(import hy.importer)
(import [hy.lex.exceptions [LexException]])



(setv HOST "irc.freenode.net")
(setv PORT 6667)
(setv NICK "Bot21")
(setv IDENT "Testiee")
(setv REALNAME "Testertonn")
(setv ROOM "#encoded")

(setv s (socket.socket))
(s.connect (, HOST PORT))
(s.send (% "NICK %s\r\n" NICK))
(s.send (% "USER %s %s bla :%s\r\n" (, IDENT HOST REALNAME)))
(s.send (% "JOIN %s\r\n" ROOM))
(s.send (% "PRIVMSG %s :%s" (, ROOM (% "I am %s\r\n" NICK))))

(defn get_expression [line]
    (setv start_index (+ (line.index (+ ":" NICK ":")) 8))
    (setv end_index (len line))
    (setv indicies (range start_index end_index))
    (setv expr "")
    (for [each indicies]
        (setv expr (+ expr (get line each)))
    )
    expr
)

(defn main_loop []
    (setv readbuffer "")
    (while True 
        (setv readbuffer (+ readbuffer (s.recv 1024)))
        (setv temp (string.split readbuffer "\n"))
        (setv readbuffer (temp.pop))


        (for [line temp]
            (print line)

            (try
                (if (in (+ ":" NICK ":") line)
                    [(setv expr (get_expression line))
                     (eval (first (hy.importer.import_buffer_to_hst expr)))
                     (setv response (eval (first (hy.importer.import_buffer_to_hst expr))))
                     (setv response_str (str response))
                     (s.send (% "PRIVMSG %s :%s" (, ROOM (+ response_str "\r\n"))))
                    ]
                )
                (catch [e [NameError ValueError LexException]] (s.send 
                                        (% "PRIVMSG %s :%s" 
                                        (, ROOM "Syntax Error\r\n"))
                                     )
                )
            )

            (setv line (string.rstrip line))
            (setv line (string.split line))
            (if (= (first line) "PING")
                (s.send (% "PONG %s\r\n" line[1])))
        )
    )
)

(main_loop)

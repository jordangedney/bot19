(import socket)
(import string)
(import hy.importer)
(import [hy.lex.exceptions [LexException]])


(defn loop []

    ;; Load the Scripts 
    (setv file (open "scripts.hy" "rw"))
    (for [each file]
        (try
            (eval (first (hy.importer.import_buffer_to_hst each)))
        
        (catch [e [NameError ValueError 
                   LexException TypeError 
                   SyntaxError IndexError]]  (print each)
        ))
    )
    
    (defn minify [file_name] 
        (setv file (open file_name "r")) 
        (setv buff "") 
        (for [each file] 
            (setv buff (+ buff (+ (each.strip) " ")))
        ) 
        (file.close)
        buff 
    )

    (defn grab_url [url] (import os) 
        (os.system "rm temp_file.hy")
        (os.system (+ "curl " url " >> temp_file.hy"))
    )

    (defn parse_expression [line] 
        (setv start_index (+ (line.index (+ ":" NICK ":")) 8)) 
        (setv end_index (len line)) 
        (setv indicies (range start_index end_index)) 
        (setv expr "") 
        (for [each indicies] 
        (setv expr (+ expr (get line each)))) 
        expr 
    )

    (defn connect_to_room [s HOST PORT NICK IDENT REALNAME] 
        (s.connect (, HOST PORT)) 
        (s.send (% "NICK %s\r\n" NICK)) 
        (s.send (% "USER %s %s bla :%s\r\n" (, IDENT HOST REALNAME))) 
        (s.send (% "JOIN %s\r\n" ROOM)) 
        (s.send (% "PRIVMSG %s :%s" (, ROOM (% "I am %s\r\n" NICK))))
    )

    (setv HOST "irc.freenode.net")
    (setv PORT 6667)
    (setv NICK "Bot19")
    (setv IDENT "Testiee")
    (setv REALNAME "Testertonn")
    (setv ROOM "#test-room")
    (setv s (socket.socket))

    (connect_to_room s HOST PORT NICK IDENT REALNAME)

    (defn add_from_url [url]
        (grab_url url)
        (setv expr (minify "temp_file.hy"))
        expr
    )
    
    (defn get_expression [line]
        (setv expr (parse_expression line))
        (if (= (first (expr.split)) "(add_from_url")
            [
            (setv url (slice (second (expr.split)) 0 -1))
            (setv expr (add_from_url url))
            ]
        )
        expr
    )

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
                     (if (= (first (expr.split)) "(defn")
                        [
                            (setv file (open "scripts.hy" "a"))
                            (file.write (+ "\n" expr))
                            (file.close)
                        ]
                    )
                    ]
                )
                (catch [e [NameError ValueError LexException TypeError SyntaxError]] (s.send 
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

(while True
    (loop)
)
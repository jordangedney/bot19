(defn add_function [url]
	(import os)
	(os.system (+ "curl" url " >> temp_file.hy"))
	(try
		(import [temp_file [*]])
	(catch [e ImportError]
		(print "Error importing module")
	))
)



(defn add_function [url]
	(import os)
	(os.system (+ "curl" url " >> temp_file.hy"))
	(try
		(import [temp_file [*]])
	(catch [e ImportError]
		(print "Error importing module")
	))
)





  (try
                    (if (in (+ ":" NICK ":") line)
                        [(setv expr (get_expression line))
                         (eval (first (hy.importer.import_buffer_to_hst expr)))
                         (setv response (eval (first (hy.importer.import_buffer_to_hst expr))))
                         (setv response_str (str response))
                         (s.send (% "PRIVMSG %s :%s" (, ROOM (+ response_str "\r\n"))))
                        ]
                    )
                    (catch [e [NameError ValueError LexException TypeError]] (s.send 
                                            (% "PRIVMSG %s :%s" 
                                            (, ROOM "Syntax Error\r\n"))
                                         )
                    )
                )


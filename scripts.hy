(defn main_loop [] (setv readbuffer "") (while True  (setv readbuffer (+ readbuffer (s.recv 1024))) (setv temp (string.split readbuffer "\n")) (setv readbuffer (temp.pop) (for [line temp] (print line) (setv line (string.rstrip line)) (setv line (string.split line))(if (= (first line) "PING") (s.send (% "PONG %s\r\n" line[1]))))))



(defn ping [host] (nth [(import commands)(nth (commands.getstatusoutput (+ "ping -c1 " host)) 1)] 1))
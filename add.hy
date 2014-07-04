(defn add_function [url]
	(import os)
	(os.system (+ "curl" url " >> temp_file.hy"))
	(try
		(import [temp_file [*]])
	(catch [e ImportError]
		(print "Error importing module")
	))
)



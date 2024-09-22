package display

import "os"

func GetHostname() string {
	hostname, err := os.Hostname()
	if err != nil {
		return "Host: ERROR"
	}
	return "Host: " + hostname
}

package display

import "time"

func GetDate() string {
	return "Date: " + time.Now().Format("2006-01-02")
}

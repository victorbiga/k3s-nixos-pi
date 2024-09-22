package display

import "time"

func GetTime() string {
	return "Time: " + time.Now().Format("15:04:05")
}

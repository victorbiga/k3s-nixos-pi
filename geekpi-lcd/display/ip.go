package display

import (
	"os/exec"
	"strings"
)

func GetIP() string {
	cmd := exec.Command("ifconfig", "end0")
	output, err := cmd.Output()
	if err != nil {
		return "IP: ERROR"
	}

	outputStr := string(output)
	lines := strings.Split(outputStr, "\n")
	for _, line := range lines {
		if strings.Contains(line, "inet ") {
			fields := strings.Fields(line)
			for i, field := range fields {
				if field == "inet" {
					return "IP: " + fields[i+1]
				}
			}
		}
	}

	return "IP: NOT FOUND"
}

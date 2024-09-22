package main

import (
	"fmt"
	"log"
	"net"
	"os"
	"os/exec"
	"strings"
	"time"

	device "github.com/adrianh-za/go-hd44780-rpi"
	i2c "github.com/d2r2/go-i2c"
)

func check(err error) {
	if err != nil {
		log.Fatal(err)
	}
}

// Function to get CPU temperature
func getTemperature() string {
	cmd := exec.Command("vcgencmd", "measure_temp")
	output, err := cmd.Output()
	if err != nil {
		return "Temp: ERROR"
	}
	// Trim the output and format it
	temp := strings.TrimSpace(string(output))
	return "Temp: " + temp[5:] // Skip "temp=" prefix
}

func getHostname() string {
	hostname, err := os.Hostname()
	if err != nil {
		return "Host: ERROR"
	}
	return "Host: " + hostname
}

func getMAC() string {
	ifaces, err := net.Interfaces()
	if err != nil {
		return "MAC: ERROR"
	}
	for _, iface := range ifaces {
		if iface.Flags&net.FlagUp != 0 && iface.Flags&net.FlagLoopback == 0 {
			address := iface.HardwareAddr
			return "MAC: " + address.String()
		}
	}
	return "MAC: NOT FOUND"
}

func getIP() string {
    cmd := exec.Command("ifconfig", "end0")
    output, err := cmd.Output()
    if err != nil {
        return "IP: ERROR"
    }

    // Extract the IP address from the command output
    outputStr := string(output)
    lines := strings.Split(outputStr, "\n")
    for _, line := range lines {
        if strings.Contains(line, "inet ") {
            // The line containing "inet " will have the IP address
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


// Helper function to clear and pad strings
func clearLine(text string, length int) string {
	if len(text) > length {
		return text[:length]
	}
	return text + strings.Repeat(" ", length-len(text))
}

func main() {
	i2c, err := i2c.NewI2C(0x27, 1)
	check(err)
	defer i2c.Close()

	lcd, err := device.NewLcd(i2c, device.LCD_20x4)
	check(err)
	lcd.BacklightOn()
	lcd.Clear()

	for {
		lcd.Home()

		// Line 1: Temperature
		lcd.SetPosition(0, 0)
		fmt.Fprint(lcd, clearLine(getTemperature(), 20))

		// Line 2: Hostname
		lcd.SetPosition(1, 0)
		hostname := getHostname()
		fmt.Println("Hostname:", hostname) // Debug print
		fmt.Fprint(lcd, clearLine(hostname, 20))

		// Line 3: MAC Address
		lcd.SetPosition(2, 0)
		fmt.Fprint(lcd, clearLine(getMAC(), 20))

		// Line 4: IP Address
		lcd.SetPosition(3, 0)
		fmt.Fprint(lcd, clearLine(getIP(), 20))

		time.Sleep(5 * time.Second) // Update every 5 seconds
	}
}

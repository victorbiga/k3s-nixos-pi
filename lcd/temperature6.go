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

// DisplayLine holds the configuration for each display line
type DisplayLine struct {
	enabled  bool
	interval time.Duration
	functions []func() string
}

// Function to get CPU temperature
func getTemperature() string {
	cmd := exec.Command("vcgencmd", "measure_temp")
	output, err := cmd.Output()
	if err != nil {
		return "Temp: ERROR"
	}
	temp := strings.TrimSpace(string(output))
	return "Temp: " + temp[5:] // Skip "temp=" prefix
}

// Function to get the hostname
func getHostname() string {
	hostname, err := os.Hostname()
	if err != nil {
		return "Host: ERROR"
	}
	return "Host: " + hostname
}

// Function to get the MAC address
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

// Function to get the IP address using ifconfig
func getIP() string {
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

// Function to get the current date
func getDate() string {
	return "Date: " + time.Now().Format("Monday Jan 2")
}

// Function to get the current time
func getTime() string {
	return "Time: " + time.Now().Format("15:04:05")
}

// Helper function to clear and pad strings
func clearLine(text string, length int) string {
	if len(text) > length {
		return text[:length]
	}
	return text + strings.Repeat(" ", length-len(text))
}

func main() {
	// Configuration for each line
	lineOne := DisplayLine{
		enabled: true,
		interval: 5 * time.Second,
		functions: []func() string{getTemperature, getHostname},
	}

	lineTwo := DisplayLine{
		enabled: true,
		interval: 10 * time.Second,
		functions: []func() string{getMAC, getIP},
	}

	lineThree := DisplayLine{
		enabled: true,
		interval: 15 * time.Second,
		functions: []func() string{getDate, getTime},
	}

	lineFour := DisplayLine{
		enabled: true,
		interval: 5 * time.Second,
		functions: []func() string{getDate, getTime},
	}

	// LCD initialization
	i2c, err := i2c.NewI2C(0x27, 1)
	check(err)
	defer i2c.Close()

	lcd, err := device.NewLcd(i2c, device.LCD_20x4)
	check(err)
	lcd.BacklightOn()
	lcd.Clear()

	// Start a single goroutine to handle display updates
	go func() {
		for {
			if lineOne.enabled {
				for _, fn := range lineOne.functions {
					message := clearLine(fn(), 20)
					lcd.SetPosition(0, 0)
					fmt.Fprint(lcd, message)
					time.Sleep(lineOne.interval)
				}
			}
			
			if lineTwo.enabled {
				for _, fn := range lineTwo.functions {
					message := clearLine(fn(), 20)
					lcd.SetPosition(1, 0)
					fmt.Fprint(lcd, message)
					time.Sleep(lineTwo.interval)
				}
			}

			if lineThree.enabled {
				for _, fn := range lineThree.functions {
					message := clearLine(fn(), 20)
					lcd.SetPosition(2, 0)
					fmt.Fprint(lcd, message)
					time.Sleep(lineThree.interval)
				}
			}

			if lineFour.enabled {
				for _, fn := range lineFour.functions {
					message := clearLine(fn(), 20)
					lcd.SetPosition(3, 0)
					fmt.Fprint(lcd, message)
					time.Sleep(lineFour.interval)
				}
			}
		}
	}()

	// Keep the main goroutine alive
	select {}
}

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

// DisplayConfig holds the configuration for each display function
type DisplayConfig struct {
	enabled  bool
	line     int
	interval time.Duration
	function func() string
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
	// Configuration map
	configs := map[string]DisplayConfig{
		"temperature": {enabled: true, line: 0, interval: 5 * time.Second, function: getTemperature},
		"hostname":    {enabled: true, line: 1, interval: 10 * time.Second, function: getHostname},
		"mac":         {enabled: true, line: 2, interval: 15 * time.Second, function: getMAC},
		"ip":          {enabled: true, line: 3, interval: 5 * time.Second, function: getIP},
		"date":        {enabled: true, line: 3, interval: 10 * time.Second, function: getDate},
		"time":        {enabled: true, line: 3, interval: 10 * time.Second, function: getTime},
	}

	// LCD initialization
	i2c, err := i2c.NewI2C(0x27, 1)
	check(err)
	defer i2c.Close()

	lcd, err := device.NewLcd(i2c, device.LCD_20x4)
	check(err)
	lcd.BacklightOn()
	lcd.Clear()

	// Channel for sending updates to the LCD
	updateChan := make(chan struct {
		line    int
		message string
	})

	// Start goroutines for each enabled configuration
	for _, config := range configs {
		if config.enabled {
			go func(cfg DisplayConfig) {
				for {
					message := cfg.function()
					updateChan <- struct {
						line    int
						message string
					}{line: cfg.line, message: clearLine(message, 20)}
					time.Sleep(cfg.interval)
				}
			}(config)
		}
	}

	// Listen for updates from display functions and update the LCD
	for update := range updateChan {
		lcd.SetPosition(update.line, 0)
		fmt.Fprint(lcd, update.message)
	}
}

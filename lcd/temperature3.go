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

// Helper function to clear and pad strings
func clearLine(text string, length int) string {
	if len(text) > length {
		return text[:length]
	}
	return text + strings.Repeat(" ", length-len(text))
}

// Configuration struct to hold function settings
type DisplayConfig struct {
	enabled  bool          // Is the function enabled?
	line     int           // Which line to display on (0-3)
	interval time.Duration // Refresh interval for the function
}

// Struct to pass updates from each function to the display
type LCDUpdate struct {
	line    int    // Line number to update
	message string // Message to display
}

// Function to run each configured display function
func runDisplayFunction(getDataFunc func() string, config DisplayConfig, updateChan chan<- LCDUpdate) {
	if !config.enabled {
		return
	}
	for {
		message := getDataFunc()
		updateChan <- LCDUpdate{line: config.line, message: clearLine(message, 20)}
		time.Sleep(config.interval)
	}
}

func main() {
	// LCD initialization
	i2c, err := i2c.NewI2C(0x27, 1)
	check(err)
	defer i2c.Close()

	lcd, err := device.NewLcd(i2c, device.LCD_20x4)
	check(err)
	lcd.BacklightOn()
	lcd.Clear()

	// Channel for sending updates to the LCD
	updateChan := make(chan LCDUpdate)

	// Configuration map
	configs := map[string]DisplayConfig{
		"temperature": {enabled: true, line: 0, interval: 5 * time.Second},
		"hostname":    {enabled: true, line: 1, interval: 10 * time.Second},
		"mac":         {enabled: false, line: 2, interval: 15 * time.Second},
		"ip":          {enabled: true, line: 3, interval: 5 * time.Second},
	}

	// Start goroutines for each enabled function
	go runDisplayFunction(getTemperature, configs["temperature"], updateChan)
	go runDisplayFunction(getHostname, configs["hostname"], updateChan)
	go runDisplayFunction(getMAC, configs["mac"], updateChan)
	go runDisplayFunction(getIP, configs["ip"], updateChan)

	// Listen for updates from display functions and update the LCD
	for update := range updateChan {
		lcd.SetPosition(update.line, 0)
		fmt.Fprint(lcd, update.message)
	}
}

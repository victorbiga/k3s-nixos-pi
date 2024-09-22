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
	addrs, err := net.InterfaceAddrs()
	if err != nil {
		return "IP: ERROR"
	}
	for _, addr := range addrs {
		if ipnet, ok := addr.(*net.IPNet); ok && ipnet.IP.To4() != nil {
			return "IP: " + ipnet.IP.String()
		}
	}
	return "IP: NOT FOUND"
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
		lcd.SetPosition(0, 0)
		fmt.Fprint(lcd, getTemperature())
		lcd.SetPosition(1, 0)
		fmt.Fprint(lcd, getHostname())
		lcd.SetPosition(2, 0)
		fmt.Fprint(lcd, getMAC())
		lcd.SetPosition(3, 0)
		fmt.Fprint(lcd, getIP())

		time.Sleep(5 * time.Second) // Update every 5 seconds
	}
}

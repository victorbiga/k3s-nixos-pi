package main

import (
	"bufio"
	"fmt"
	"net"
	"os"
	"strings"
	"time"

	"github.com/d2r2/go-i2c"
)

const (
	LCD_CMD_CLEAR       = 0x01
	LCD_CMD_HOME        = 0x02
	LCD_CMD_SET_CURSOR  = 0x80
	LCD_CMD_FUNCTIONSET = 0x20
	RS_COMMAND          = 0x00 // Register Select: Command
	RS_DATA             = 0x01 // Register Select: Data
)

type LCD struct {
	i2c *i2c.I2C
}

func NewLCD(addr uint8) (*LCD, error) {
	i2c, err := i2c.NewI2C(addr, 1)
	if err != nil {
		return nil, err
	}
	lcd := &LCD{i2c: i2c}
	lcd.Init()
	return lcd, nil
}

func (lcd *LCD) Init() {
	lcd.WriteByte(LCD_CMD_FUNCTIONSET | 0x08) // Set to 8-bit mode
	time.Sleep(5 * time.Millisecond)
	lcd.WriteByte(LCD_CMD_FUNCTIONSET | 0x0C) // Display on
	time.Sleep(5 * time.Millisecond)
	lcd.WriteByte(LCD_CMD_CLEAR)               // Clear display
	time.Sleep(5 * time.Millisecond)
}

func (lcd *LCD) WriteByte(data byte) {
	lcd.i2c.WriteBytes([]byte{data})
}

func (lcd *LCD) WriteCommand(cmd byte) {
	lcd.WriteByte(RS_COMMAND) // Send command
	lcd.WriteByte(cmd)
}

func (lcd *LCD) WriteData(data byte) {
	lcd.WriteByte(RS_DATA) // Send data
	lcd.WriteByte(data)
}

func (lcd *LCD) Print(s string) {
	for _, c := range s {
		lcd.WriteData(byte(c)) // Send character data
	}
}

func getSerial() string {
	file, err := os.Open("/proc/cpuinfo")
	if err != nil {
		return "ERROR"
	}
	defer file.Close()

	var serial string
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		if strings.HasPrefix(scanner.Text(), "Serial") {
			serial = strings.TrimSpace(strings.Split(scanner.Text(), ":")[1])
			break
		}
	}

	if err := scanner.Err(); err != nil {
		return "ERROR"
	}
	return serial
}

func getHostname() string {
	hn, err := os.Hostname()
	if err != nil {
		return "ERROR"
	}
	return hn
}

func getIP(ifname string) string {
	interfaces, err := net.Interfaces()
	if err != nil {
		return "ERROR"
	}

	for _, iface := range interfaces {
		if iface.Name == ifname {
			addrs, err := iface.Addrs()
			if err == nil {
				for _, addr := range addrs {
					if ipnet, ok := addr.(*net.IPNet); ok && ipnet.IP.IsGlobalUnicast() {
						return ipnet.IP.String()
					}
				}
			}
		}
	}
	return "ERROR"
}

func main() {
	lcd, err := NewLCD(0x27) // Replace with your I2C address
	if err != nil {
		fmt.Println("Error initializing I2C:", err)
		return
	}
	defer lcd.i2c.Close()

	// Display information on LCD
	lcd.Print("SN: " + getSerial())
	lcd.WriteCommand(LCD_CMD_SET_CURSOR | 0x40) // Move to second line
	lcd.Print("HN: " + getHostname())
}

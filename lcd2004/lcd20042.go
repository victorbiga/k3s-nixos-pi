package main

import (
	"log"
	"net"
	"os"
	"os/exec"
	"strings"
	"time"

	"github.com/d2r2/go-i2c"
)

const (
	LCD_CMD_CLEAR       = 0x01
	LCD_CMD_RETURN_HOME = 0x02
	LCD_CMD_ENTRY_MODE  = 0x06
	LCD_CMD_DISPLAY_ON  = 0x0C
	LCD_CMD_FUNCTION_SET = 0x28 // 4 lines, 5x8 dots
	RS_COMMAND          = 0x00   // Register Select: Command
	RS_DATA             = 0x01   // Register Select: Data
)

type LCD struct {
	i2c *i2c.I2C
}

func NewLCD(addr uint8) (*LCD, error) {
	i2c, err := i2c.NewI2C(addr, 1) // Use /dev/i2c-1
	if err != nil {
		return nil, err
	}
	lcd := &LCD{i2c: i2c}
	lcd.Init()
	return lcd, nil
}

func (lcd *LCD) Init() {
	lcd.WriteCommand(LCD_CMD_FUNCTION_SET) // 4 lines, 5x8 dots
	time.Sleep(50 * time.Millisecond)
	lcd.WriteCommand(LCD_CMD_DISPLAY_ON)    // Display on, cursor off
	time.Sleep(50 * time.Millisecond)
	lcd.WriteCommand(LCD_CMD_CLEAR)          // Clear display
	time.Sleep(50 * time.Millisecond)
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

func (lcd *LCD) SetCursor(line, col int) {
	var address byte
	if col > 19 {
		col = 19 // Limit to 20 characters
	}
	switch line {
	case 0:
		address = 0x00 + byte(col)
	case 1:
		address = 0x40 + byte(col)
	case 2:
		address = 0x14 + byte(col)
	case 3:
		address = 0x54 + byte(col)
	}
	lcd.WriteCommand(address | RS_COMMAND) // Set cursor position
}

func getSerialNumber() string {
	cmd := exec.Command("cat", "/proc/cpuinfo")
	out, err := cmd.Output()
	if err != nil {
		return "ERROR"
	}
	lines := string(out)
	for _, line := range splitLines(lines) {
		if len(line) >= 6 && line[:6] == "Serial" {
			return line[10:26]
		}
	}
	return "0000000000000000"
}

func splitLines(s string) []string {
	return strings.Split(s, "\n")
}

func getHostname() string {
	hostname, err := os.Hostname()
	if err != nil {
		return "ERROR"
	}
	return hostname
}

func getIP(ifname string) string {
	interfaces, err := net.Interfaces()
	if err != nil {
		return "ERROR"
	}
	for _, intf := range interfaces {
		if intf.Name == ifname {
			addrs, err := intf.Addrs()
			if err == nil && len(addrs) > 0 {
				if ipNet, ok := addrs[0].(*net.IPNet); ok {
					return ipNet.IP.String()
				}
			}
		}
	}
	return "ERROR"
}

func main() {
	lcd, err := NewLCD(0x27) // Initialize the LCD
	if err != nil {
		log.Fatal(err)
	}

	// Clear the display before writing
	lcd.WriteCommand(LCD_CMD_CLEAR)

	// Display Serial Number
	lcd.SetCursor(0, 0)
	lcd.Print("SN: " + getSerialNumber())

	// Display Hostname
	lcd.SetCursor(1, 0)
	lcd.Print("HN: " + getHostname())

	// Display Ethernet Info
	if _, err := os.Stat("/sys/class/net/eth0/carrier"); err == nil {
		lcd.SetCursor(2, 0)
		lcd.Print("EM: " + getIP("eth0"))
	} else if _, err := os.Stat("/sys/class/net/wlan0/carrier"); err == nil {
		lcd.SetCursor(2, 0)
		lcd.Print("WM: " + getIP("wlan0"))
	}

	// Wait to see the output
	time.Sleep(10 * time.Second)
	lcd.WriteCommand(LCD_CMD_CLEAR) // Clear again if needed
}

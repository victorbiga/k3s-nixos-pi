package main

import (
	"fmt"
	"log"
	"strings"
	"time"

	device "github.com/adrianh-za/go-hd44780-rpi"
	i2c "github.com/d2r2/go-i2c"
	"geekpi-lcd/display"
)

func check(err error) {
	if err != nil {
		log.Fatal(err)
	}
}

// DisplayLine holds the configuration for each display line
type DisplayLine struct {
	enabled   bool
	interval  time.Duration
	functions []func() string
}

func clearLine(text string, length int) string {
	if len(text) > length {
		return text[:length]
	}
	return text + strings.Repeat(" ", length-len(text))
}

// Function to update a specific line
func updateLine(lcd *device.Lcd, lineNum int, displayLine DisplayLine) {
	for {
		if displayLine.enabled {
			for _, fn := range displayLine.functions {
				message := clearLine(fn(), 20)

				// Debugging output
				fmt.Printf("Updating line %d: %s\n", lineNum, message)

				lcd.SetPosition(lineNum, 0)
				fmt.Fprint(lcd, message)

				// Sleep for the line's interval
				time.Sleep(displayLine.interval)
			}
		} else {
			time.Sleep(1 * time.Second)
		}
	}
}

func main() {
	i2c, err := i2c.NewI2C(0x27, 1)
	check(err)
	defer i2c.Close()

	lcd, err := device.NewLcd(i2c, device.LCD_20x4)
	check(err)
	lcd.BacklightOn()
	lcd.Clear() // Clear the LCD at startup

	lineOne := DisplayLine{
		enabled:  true,
		interval: 5 * time.Second,
		functions: []func() string{display.GetTemperature, display.GetHostname},
	}

	lineTwo := DisplayLine{
		enabled:  true,
		interval: 10 * time.Second,
		functions: []func() string{display.GetMAC, display.GetIP},
	}

	lineThree := DisplayLine{
		enabled:  true,
		interval: 15 * time.Second,
		functions: []func() string{display.GetDate, display.GetTime},
	}

	lineFour := DisplayLine{
		enabled:  true,
		interval: 5 * time.Second,
		functions: []func() string{display.GetDate, display.GetTime},
	}

	// Start a separate goroutine for each display line
	go updateLine(lcd, 0, lineOne)
	go updateLine(lcd, 1, lineTwo)
	go updateLine(lcd, 2, lineThree)
	go updateLine(lcd, 3, lineFour)

	// Keep the main goroutine alive
	select {}
}

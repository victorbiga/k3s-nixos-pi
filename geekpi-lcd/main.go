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

// Clear the entire LCD
func clearLCD(lcd *device.Lcd) {
	lcd.Clear()
}

func main() {
	lineOne := DisplayLine{
		enabled:  true,
		interval: 1 * time.Second,
		functions: []func() string{display.GetTime},
	}

	lineTwo := DisplayLine{
		enabled:  true,
		interval: 1 * time.Second,
		functions: []func() string{display.GetTemperature},
	}

	lineThree := DisplayLine{
		enabled:  true,
		interval: 1 * time.Second,
		functions: []func() string{display.GetMAC, display.GetIP, display.GetHostname},
	}

	lineFour := DisplayLine{
		enabled:  true,
		interval: 1 * time.Second,
		functions: []func() string{display.GetDate},
	}

	i2c, err := i2c.NewI2C(0x27, 1)
	check(err)
	defer i2c.Close()

	lcd, err := device.NewLcd(i2c, device.LCD_20x4)
	check(err)
	lcd.BacklightOn()
	clearLCD(lcd)

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

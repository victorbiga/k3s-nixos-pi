package main

import (
	"fmt"
	"time"

	"github.com/d2r2/go-i2c"
)

const (
	LCD_CMD_CLEAR      = 0x01
	LCD_CMD_RETURN_HOME = 0x02
	LCD_CMD_ENTRY_MODE = 0x06
	LCD_CMD_DISPLAY_ON = 0x0C
	LCD_CMD_FUNCTION_SET = 0x28 // 4 lines, 5x8 dots
	RS_COMMAND         = 0x00 // Register Select: Command
	RS_DATA            = 0x01 // Register Select: Data
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
	lcd.WriteCommand(LCD_CMD_FUNCTION_SET) // 4 lines, 5x8 dots
	time.Sleep(50 * time.Millisecond)
	lcd.WriteCommand(LCD_CMD_DISPLAY_ON)    // Display on, cursor off
	time.Sleep(50 * time.Millisecond)
	lcd.WriteCommand(LCD_CMD_ENTRY_MODE)     // Entry mode
	time.Sleep(50 * time.Millisecond)
	lcd.WriteCommand(LCD_CMD_CLEAR)           // Clear display
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

func main() {
	lcd, err := NewLCD(0x27) // Replace with your I2C address
	if err != nil {
		fmt.Println("Error initializing I2C:", err)
		return
	}
	defer lcd.i2c.Close()

	// Clear the display before writing
	lcd.WriteCommand(LCD_CMD_CLEAR)

	// Print simple static text
	lcd.Print("Hello, World!")
	time.Sleep(5 * time.Second) // Wait to see the output
	lcd.WriteCommand(LCD_CMD_CLEAR) // Clear again if needed
}

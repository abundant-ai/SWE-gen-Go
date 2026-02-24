package main

import (
	"github.com/labstack/echo"
	"github.com/labstack/echo/engine/standard"
)

func main() {
	// Create Echo instance
	e := echo.New()

	// Create standard server
	s := standard.New(":0")

	// Start server in goroutine
	go func() {
		e.Run(s)
	}()

	// Stop server - this will fail to compile if Stop() doesn't exist
	e.Stop()
}
